# ECS task security group is defined here (not in modules/ecs) because the
# DB security group's ingress rule needs to reference it, and Stage 5
# builds on top of this same SG rather than redefining it.
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.name_prefix}-ecs-tasks-sg"
  description = "ECS backend tasks"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-ecs-tasks-sg"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-db-sg"
  description = "RDS Postgres - only reachable from ECS tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-db-sg"
  }
}

resource "aws_security_group_rule" "db_from_ecs_tasks" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.ecs_tasks.id
  description               = "Postgres from ECS tasks"
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.name_prefix}-db-subnet-group"
  }
}

resource "random_password" "master" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "db_master_password" {
  name = "${var.name_prefix}-db-master-password"
}

resource "aws_secretsmanager_secret_version" "db_master_password" {
  secret_id     = aws_secretsmanager_secret.db_master_password.id
  secret_string = random_password.master.result
}

resource "aws_db_instance" "this" {
  identifier     = "${var.name_prefix}-db"
  engine         = "postgres"
  engine_version = var.engine_version

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  db_name  = var.db_name
  username = var.db_master_username
  password = random_password.master.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az             = var.multi_az
  publicly_accessible  = false
  skip_final_snapshot  = true
  deletion_protection  = var.deletion_protection

  tags = {
    Name = "${var.name_prefix}-db"
  }
}
