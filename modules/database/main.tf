# The ECS task security group lives in modules/ecs (created by the
# terraform-aws-modules ECS service submodule) and modules/ecs depends on
# this module's DB endpoint/secret - so the reverse SG ingress rule can't
# live in either module without a cycle. It's declared as a standalone
# resource in environments/dev, once both modules exist.
resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-db-sg"
  description = "RDS Postgres - only reachable from ECS tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-db-sg"
  }
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 7.0"

  identifier = "${var.name_prefix}-db"

  engine               = "postgres"
  engine_version       = var.engine_version
  family               = "postgres${var.engine_version}"
  major_engine_version = var.engine_version

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  db_name  = var.db_name
  username = var.db_master_username

  # Native RDS-managed master password: generated and stored in Secrets
  # Manager by AWS itself, never in Terraform code/state or GitHub Secrets.
  manage_master_user_password = true

  create_db_subnet_group = true
  subnet_ids             = var.db_subnet_ids
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az            = var.multi_az
  publicly_accessible = false
  deletion_protection = var.deletion_protection
  skip_final_snapshot = true

  create_db_option_group    = false
  create_db_parameter_group = false
}
