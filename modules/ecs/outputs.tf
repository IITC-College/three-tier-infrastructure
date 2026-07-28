output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  value = aws_ecs_service.backend.name
}

output "task_execution_role_arn" {
  value = aws_iam_role.task_execution.arn
}

output "task_definition_family" {
  value = aws_ecs_task_definition.backend.family
}
