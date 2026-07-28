variable "name_prefix" {
  type = string
}

variable "aliases" {
  description = "Custom domain(s) for CloudFront (Stage 12). Empty = use the default *.cloudfront.net domain only."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM cert (us-east-1) for the aliases above. Required if aliases is non-empty."
  type        = string
  default     = null
}
