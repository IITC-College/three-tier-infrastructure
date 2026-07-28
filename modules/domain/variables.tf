variable "domain_name" {
  description = "Existing Route 53 hosted zone (not created by this module)."
  type        = string
}

variable "app_subdomain" {
  type = string
}

variable "api_subdomain" {
  type = string
}
