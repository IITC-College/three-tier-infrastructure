variable "name_prefix" {
  type = string
}

variable "enable_https" {
  description = "Stage 12 (prod only). Must be a plan-time-known literal, not derived from another resource - the ALB listener map's key set (http-only vs http+https) can't depend on a value that's still unknown at plan time."
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM cert (regional) for the ALB's HTTPS listener. Only used when enable_https = true; its value may still be unknown at plan time (e.g. a not-yet-validated ACM cert) since it only ever appears as a map *value*, never as a for_each key."
  type        = string
  default     = null
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

variable "db_master_user_secret_arn" {
  description = "Secrets Manager ARN of the RDS-managed master credentials (Stage 4 output, JSON: {username, password})."
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
  default = 14
}
