# =============================================================================
# M07-02 — Análisis de drift (sandbox)
# =============================================================================
# Crea un bucket con una etiqueta gestionada. Luego se cambia FUERA de Terraform
# (consola o AWS CLI) y "terraform plan" detecta el drift.
# Requiere AWS real: terraform init + apply. Destruye al terminar.
# =============================================================================

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

# -----------------------------------------------------------------------------
# Recurso con etiqueta gestionada por Terraform.
# Provocar drift (elige una opción):
#   A) Consola AWS: S3 -> bucket -> Properties/Tags -> Owner = manual
#   B) AWS CLI:
#        aws s3api put-bucket-tagging \
#          --bucket curso-<lab_user>-drift-demo \
#          --tagging 'TagSet=[{Key=Owner,Value=manual}]'
# Después: terraform plan  -> propone volver Owner a "terraform" (revierte el drift).
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "demo" {
  bucket = "curso-${var.lab_user}-drift-demo"

  tags = {
    Owner = "terraform"
  }
}

output "bucket_name" {
  description = "Bucket sobre el que se provoca el drift."
  value       = aws_s3_bucket.demo.bucket
}
