variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "db_name" {
  type    = string
  default = "app"
}

variable "db_master_username" {
  type    = string
  default = "postgres"
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "engine_version" {
  description = "Major Postgres version only (e.g. \"16\")."
  type        = string
  default     = "16"
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  type    = bool
  default = false
}
