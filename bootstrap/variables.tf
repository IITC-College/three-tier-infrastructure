variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "tfc_hostname" {
  type    = string
  default = "app.terraform.io"
}

variable "tfc_aws_audience" {
  description = "Must match TFC_AWS_WORKLOAD_IDENTITY_AUDIENCE on each workspace (defaults to aws.workload.identity if unset)."
  type        = string
  default     = "aws.workload.identity"
}

variable "tfc_organization" {
  type    = string
  default = "lironefitoussi"
}

variable "tfc_workspace_names" {
  type    = list(string)
  default = ["three-tier-dev", "three-tier-prod"]
}
