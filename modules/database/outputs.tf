output "ecs_tasks_security_group_id" {
  value = aws_security_group.ecs_tasks.id
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}

output "db_instance_endpoint" {
  value = aws_db_instance.this.address
}

output "db_instance_port" {
  value = aws_db_instance.this.port
}

output "db_name" {
  value = aws_db_instance.this.db_name
}

output "db_master_username" {
  value = aws_db_instance.this.username
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_master_password.arn
}
