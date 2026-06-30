# =============================================================================
# M07 — Operar el estado (sandbox)
# =============================================================================
# Lab M07-01: terraform state list / show / mv
# Requiere AWS real: terraform init + apply (crea un bucket S3).
# Recuerda destruir al terminar: terraform destroy.
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
# M07-01 — recurso mínimo para inspeccionar y mover en el estado.
# Paso 3 del lab: renombra el nombre lógico (data -> primary) y reconcilia con:
#   terraform state mv aws_s3_bucket.data aws_s3_bucket.primary
# El nombre real del bucket NO cambia; solo su dirección en el estado.
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "data" {
  bucket = "curso-${var.lab_user}-state-demo"
}

output "bucket_name" {
  description = "Nombre real del bucket (no cambia al hacer state mv)."
  value       = aws_s3_bucket.data.bucket
}
