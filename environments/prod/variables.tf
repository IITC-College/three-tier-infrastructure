variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "name_prefix" {
  type    = string
  default = "three-tier-prod"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.1.0.0/24", "10.1.1.0/24"]
}

variable "app_subnet_cidrs" {
  type    = list(string)
  default = ["10.1.10.0/24", "10.1.11.0/24"]
}

variable "db_subnet_cidrs" {
  type    = list(string)
  default = ["10.1.20.0/24", "10.1.21.0/24"]
}

variable "db_name" {
  type    = string
  default = "app"
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
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

variable "alarm_email" {
  type    = string
  default = "lironefitoussi@gmail.com"
}

variable "ecs_desired_count" {
  type    = number
  default = 2
}

variable "domain_name" {
  type    = string
  default = "iitc-course.com"
}

variable "app_subdomain" {
  type    = string
  default = "lirone-app"
}

variable "api_subdomain" {
  type    = string
  default = "lirone-api"
}
