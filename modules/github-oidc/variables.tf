variable "name_prefix" {
  type = string
}

variable "github_org" {
  type    = string
  default = "IITC-College"
}

variable "backend_repo_name" {
  type    = string
  default = "three-tier-backend"
}

variable "frontend_repo_name" {
  type    = string
  default = "three-tier-frontend"
}

variable "deploy_branch" {
  type    = string
  default = "main"
}

variable "ecr_repository_arn" {
  type = string
}

variable "ecs_cluster_arn" {
  type = string
}

variable "ecs_service_arn" {
  type = string
}

variable "task_execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "frontend_bucket_arn" {
  type = string
}

variable "cloudfront_distribution_arn" {
  type = string
}
