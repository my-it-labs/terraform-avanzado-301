terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
	  Project     = var.project
	  Environment = var.environment
	  Owner       = "equipo-dev"	
  }
}

output "name_prefix" {
  value = local.name_prefix
}

module "naming" {
  source      = "../../modules/naming"
  project     = var.project
  environment = var.environment
}

module "tags" {
  source      = "../../modules/tagging"
  project     = var.project
  environment = var.environment
}

output "dev_name_prefix" { value = module.naming.prefix }
output "common_tags" { value = module.tags.tags }

module "bucket" {
  # Usando HTTPS (ya que tu repositorio es Public):
  source = "git::https://github.com/fvlazaro/terraform-avanzado-301.git//modules/s3?ref=v1.0.0"
  bucket_name = "${var.project}-${var.environment}-data"
  tags        = { ManagedBy = "terraform" }
}

output "bucket_id" { value = module.bucket.bucket_id }