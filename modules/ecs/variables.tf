variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "app_subnet_ids" {
  type = list(string)
}

variable "ecs_tasks_security_group_id" {
  type = string
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN holding the raw DB master password (Stage 4 output)."
  type        = string
}

variable "db_instance_endpoint" {
  type = string
}

variable "db_instance_port" {
  type = number
}

variable "db_name" {
  type = string
}

variable "db_master_username" {
  type = string
}

variable "container_port" {
  type    = number
  default = 8000
}

variable "image_tag" {
  description = "Placeholder tag for the initial task definition; Stage 8's CI pushes real revisions after this."
  type        = string
  default     = "latest"
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "log_retention_days" {
  type    = number
  default = 7
}
