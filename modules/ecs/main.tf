data "aws_region" "current" {}

resource "aws_ecr_repository" "backend" {
  name                 = "${var.name_prefix}-backend"
  image_tag_mutability = "MUTABLE"
  # Otherwise `terraform destroy` fails outright once any image has been
  # pushed (RepositoryNotEmptyException) - hit this for real tearing dev down.
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.name_prefix}-backend"
  retention_in_days = var.log_retention_days
}

# --- DATABASE_URL assembly ---
# The backend only reads one DATABASE_URL env var; ECS `secrets` can only
# inject one raw value per key. Stage 4's RDS-managed secret holds
# {"username":"...","password":"..."} JSON - decoded here and reassembled
# into a full connection string, stored in a new secret the task
# definition actually consumes.

data "aws_secretsmanager_secret_version" "db_master" {
  secret_id = var.db_master_user_secret_arn
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_master.secret_string)
}

resource "aws_secretsmanager_secret" "database_url" {
  name = "${var.name_prefix}-database-url"
}

resource "aws_secretsmanager_secret_version" "database_url" {
  secret_id     = aws_secretsmanager_secret.database_url.id
  secret_string = "postgresql+psycopg2://${var.db_master_username}:${local.db_creds.password}@${var.db_instance_endpoint}:${var.db_instance_port}/${var.db_name}"
}

# --- Public ALB ---

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.0"

  name               = "${var.name_prefix}-alb"
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.public_subnet_ids

  # terraform-aws-modules/alb defaults this true; without it explicitly
  # false, `terraform destroy` fails outright
  # (OperationNotPermitted: deletion protection is enabled) - hit this
  # for real tearing dev down. Stage 12 could still add its own explicit
  # override for prod if that's ever wanted there.
  enable_deletion_protection = false

  security_group_ingress_rules = merge(
    {
      http = {
        from_port   = 80
        to_port     = 80
        ip_protocol = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
      }
    },
    var.enable_https ? {
      https = {
        from_port   = 443
        to_port     = 443
        ip_protocol = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
      }
    } : {}
  )
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  # Stage 12 (prod only): HTTP redirects to HTTPS when enable_https = true.
  # Dev leaves enable_https at its default (false), keeping the plain
  # HTTP-forward listener from Stage 5. `merge()` (not a ternary over the
  # whole map) avoids Terraform's object-type-consistency requirement
  # between the two possible shapes; certificate_arn only ever appears as
  # a map *value* (fine if still unknown at plan time), never decides
  # which map *keys* exist (which must be known at plan time).
  listeners = merge(
    {
      http = {
        port     = 80
        protocol = "HTTP"
        forward = var.enable_https ? null : {
          target_group_key = "backend"
        }
        redirect = var.enable_https ? {
          port        = "443"
          protocol    = "HTTPS"
          status_code = "HTTP_301"
        } : null
      }
    },
    var.enable_https ? {
      https = {
        port            = 443
        protocol        = "HTTPS"
        certificate_arn = var.certificate_arn
        forward = {
          target_group_key = "backend"
        }
      }
    } : {}
  )

  target_groups = {
    backend = {
      port        = var.container_port
      protocol    = "HTTP"
      target_type = "ip"
      # ECS-managed target attachments, not static targets.
      create_attachment = false

      health_check = {
        enabled             = true
        path                = "/health"
        protocol            = "HTTP"
        matcher             = "200"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        interval            = 15
        timeout             = 5
      }
    }
  }
}

# --- ECS cluster + Fargate service ---

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 7.0"

  name = "${var.name_prefix}-cluster"

  # Container Insights: Stage 11's ECS running-task-count alarm needs the
  # ECS/ContainerInsights RunningTaskCount metric, which only publishes
  # when this is enabled.
  setting = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]

  cluster_capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 100
    }
  }
}

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 7.0"

  name        = "${var.name_prefix}-backend"
  cluster_arn = module.ecs_cluster.arn

  cpu    = var.cpu
  memory = var.memory

  container_definitions = {
    backend = {
      image     = "${aws_ecr_repository.backend.repository_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = aws_secretsmanager_secret.database_url.arn
        }
      ]

      enable_cloudwatch_logging = false
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = data.aws_region.current.region
          "awslogs-stream-prefix" = "backend"
        }
      }

      readonlyRootFilesystem = false
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.app_subnet_ids

  security_group_ingress_rules = {
    alb = {
      from_port                    = var.container_port
      to_port                      = var.container_port
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.alb.security_group_id
      description                  = "Backend container port from ALB"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["backend"].arn
      container_name   = "backend"
      container_port   = var.container_port
    }
  }

  desired_count = var.desired_count

  # Module defaults (min=1) would let target-tracking scale below the
  # dev floor of desired_count=2 the moment CPU/memory is idle.
  autoscaling_min_capacity = var.desired_count
  autoscaling_max_capacity = var.desired_count * 2

  create_task_exec_iam_role = true
  task_exec_secret_arns     = [aws_secretsmanager_secret.database_url.arn]

  # So Stage 8's CI-driven task-definition updates aren't reverted by the
  # next `terraform apply`.
  ignore_task_definition_changes = true
}
