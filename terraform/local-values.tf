# Define Local Values in Terraform
locals {
  owners      = var.project
  environment = var.environment
  name        = "${var.environment}-${var.cluster_name}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
} 