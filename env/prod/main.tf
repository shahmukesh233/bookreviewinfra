# Production Environment Configuration
# This file configures the production environment using the modules

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "bookreview-terraform-state-prod"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}

# Shared infrastructure (VPC, S3 state bucket)
module "shared" {
  source = "../../modules/shared"

  name_prefix       = var.name_prefix
  state_bucket_name = var.state_bucket_name
  availability_zone = var.availability_zone
  tags             = var.default_tags
}

# Backend infrastructure (EC2 + PostgreSQL)
module "backend" {
  source = "../../modules/backend"

  name_prefix    = var.name_prefix
  vpc_id         = module.shared.vpc_id
  subnet_id      = module.shared.public_subnet_id
  instance_type  = var.backend_instance_type
  key_name       = var.key_name
  allowed_ips    = var.allowed_ips
  db_name        = var.db_name
  db_user        = var.db_user
  db_password    = var.db_password
  tags           = var.default_tags

  depends_on = [module.shared]
}

# Frontend infrastructure (S3 + CloudFront)
module "frontend" {
  source = "../../modules/frontend"

  name_prefix = var.name_prefix
  bucket_name = var.frontend_bucket_name
  tags        = var.default_tags

  depends_on = [module.shared]
}

