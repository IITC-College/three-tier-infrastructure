output "backend_deploy_role_arn" {
  value = aws_iam_role.backend_deploy.arn
}

output "frontend_deploy_role_arn" {
  value = aws_iam_role.frontend_deploy.arn
}
