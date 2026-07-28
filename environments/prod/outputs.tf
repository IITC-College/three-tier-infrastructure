output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "app_subnet_ids" {
  value = module.network.app_subnet_ids
}

output "db_subnet_ids" {
  value = module.network.db_subnet_ids
}

output "db_instance_endpoint" {
  value = module.database.db_instance_endpoint
}

output "db_master_user_secret_arn" {
  value = module.database.db_master_user_secret_arn
}

output "alb_dns_name" {
  value = module.ecs.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecs.ecr_repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  value = module.ecs.ecs_service_name
}

output "ecs_task_family" {
  value = module.ecs.task_definition_family
}

output "frontend_bucket_name" {
  value = module.frontend.bucket_name
}

output "cloudfront_domain_name" {
  value = module.frontend.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  value = module.frontend.cloudfront_distribution_id
}

output "backend_deploy_role_arn" {
  value = module.github_oidc.backend_deploy_role_arn
}

output "frontend_deploy_role_arn" {
  value = module.github_oidc.frontend_deploy_role_arn
}

output "sns_alerts_topic_arn" {
  value = module.monitoring.sns_topic_arn
}

output "app_url" {
  value = "https://${module.domain.app_fqdn}"
}

output "api_url" {
  value = "https://${module.domain.api_fqdn}"
}
