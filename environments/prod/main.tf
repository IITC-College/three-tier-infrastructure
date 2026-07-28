terraform {
  cloud {
    organization = "lironefitoussi"
    workspaces {
      name = "three-tier-prod"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  name_prefix            = var.name_prefix
  vpc_cidr                = var.vpc_cidr
  azs                     = var.azs
  public_subnet_cidrs     = var.public_subnet_cidrs
  app_subnet_cidrs        = var.app_subnet_cidrs
  db_subnet_cidrs         = var.db_subnet_cidrs
  single_nat_gateway      = false
  one_nat_gateway_per_az  = true
}

module "database" {
  source = "./modules/database"

  name_prefix          = var.name_prefix
  vpc_id               = module.network.vpc_id
  db_subnet_ids        = module.network.db_subnet_ids
  db_name              = var.db_name
  instance_class       = var.db_instance_class
  multi_az             = true
  deletion_protection  = true
}

module "ecs" {
  source = "./modules/ecs"

  name_prefix       = var.name_prefix
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  app_subnet_ids    = module.network.app_subnet_ids

  db_master_user_secret_arn = module.database.db_master_user_secret_arn
  db_instance_endpoint      = module.database.db_instance_endpoint
  db_instance_port          = module.database.db_instance_port
  db_name                   = module.database.db_name
  db_master_username        = module.database.db_master_username
}

resource "aws_security_group_rule" "db_from_ecs_tasks" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.database.db_security_group_id
  source_security_group_id = module.ecs.ecs_tasks_security_group_id
  description               = "Postgres from ECS tasks"
}

module "frontend" {
  source = "./modules/frontend"

  name_prefix = var.name_prefix
}

module "github_oidc" {
  source = "./modules/github-oidc"

  name_prefix = var.name_prefix

  github_org         = var.github_org
  backend_repo_name  = var.backend_repo_name
  frontend_repo_name = var.frontend_repo_name
  deploy_branch      = var.deploy_branch

  ecr_repository_arn = module.ecs.ecr_repository_arn
  ecs_cluster_arn    = module.ecs.ecs_cluster_arn
  ecs_service_arn    = module.ecs.ecs_service_arn

  task_execution_role_arn = module.ecs.task_execution_role_arn
  task_role_arn           = module.ecs.task_role_arn

  frontend_bucket_arn         = module.frontend.bucket_arn
  cloudfront_distribution_arn = module.frontend.cloudfront_distribution_arn
}
