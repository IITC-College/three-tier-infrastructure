output "db_security_group_id" {
  value = aws_security_group.db.id
}

output "db_instance_endpoint" {
  value = module.rds.db_instance_address
}

output "db_instance_port" {
  value = module.rds.db_instance_port
}

output "db_name" {
  value = var.db_name
}

output "db_master_username" {
  value = var.db_master_username
}

output "db_master_user_secret_arn" {
  description = "Secrets Manager ARN of the AWS-managed master credentials (JSON: {username, password})."
  value       = module.rds.db_instance_master_user_secret_arn
}
