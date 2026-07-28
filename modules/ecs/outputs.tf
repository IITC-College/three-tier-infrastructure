output "alb_dns_name" {
  value = module.alb.dns_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "ecr_repository_arn" {
  value = aws_ecr_repository.backend.arn
}

output "ecs_cluster_name" {
  value = module.ecs_cluster.name
}

output "ecs_cluster_arn" {
  value = module.ecs_cluster.arn
}

output "ecs_service_name" {
  value = module.ecs_service.name
}

output "ecs_service_arn" {
  value = module.ecs_service.id
}

output "ecs_tasks_security_group_id" {
  value = module.ecs_service.security_group_id
}

output "task_execution_role_arn" {
  value = module.ecs_service.task_exec_iam_role_arn
}

output "task_role_arn" {
  value = module.ecs_service.tasks_iam_role_arn
}

output "task_definition_family" {
  value = module.ecs_service.task_definition_family
}
