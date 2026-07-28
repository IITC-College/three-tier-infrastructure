module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.name_prefix}-vpc"
  cidr = var.vpc_cidr
  azs  = var.azs

  public_subnets   = var.public_subnet_cidrs
  private_subnets  = var.app_subnet_cidrs
  database_subnets = var.db_subnet_cidrs

  create_database_subnet_group = true

  map_public_ip_on_launch = true

  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}
