output "zone_id" {
  value = data.aws_route53_zone.this.zone_id
}

output "app_fqdn" {
  value = "${var.app_subdomain}.${var.domain_name}"
}

output "api_fqdn" {
  value = "${var.api_subdomain}.${var.domain_name}"
}

output "cloudfront_certificate_arn" {
  value = aws_acm_certificate_validation.cloudfront.certificate_arn
}

output "alb_certificate_arn" {
  value = aws_acm_certificate_validation.alb.certificate_arn
}
