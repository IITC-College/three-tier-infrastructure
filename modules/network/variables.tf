variable "name_prefix" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "app_subnet_cidrs" {
  type = list(string)
}

variable "db_subnet_cidrs" {
  type = list(string)
}

variable "single_nat_gateway" {
  description = "Dev cost-saving default: one shared NAT for all AZs."
  type        = bool
  default     = true
}

variable "one_nat_gateway_per_az" {
  description = "Prod hardening (Stage 12): one NAT per AZ instead of a single shared one."
  type        = bool
  default     = false
}
