
# AWS Availability Zones Datasource
data "aws_availability_zones" "available" {
  state = "available"
}


# Create VPC Terraform Module

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  version = "5.5.0"

  # VPC Basic Details
  name            = "${local.name}-vpc"
  cidr            = var.vpc_cidr_block
  azs             = data.aws_availability_zones.available.names
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = false

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags     = local.common_tags
  vpc_tags = local.common_tags

  # Additional Tags to Subnets
  public_subnet_tags = {
    Type                                  = "Public Subnets"
    "kubernetes.io/role/elb"              = 1
    "kubernetes.io/cluster/${local.name}" = "owned"
  }
  private_subnet_tags = {
    Type                                  = "private-subnets"
    "kubernetes.io/role/internal-elb"     = 1
    "kubernetes.io/cluster/${local.name}" = "owned"
  }

  map_public_ip_on_launch = true
}