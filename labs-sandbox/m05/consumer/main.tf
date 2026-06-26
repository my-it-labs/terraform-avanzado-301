# =============================================================================
# Consumidor del módulo S3 — M05
# =============================================================================
# Este directorio simula un *entorno* (dev) que NO es dueño del módulo: solo lo
# referencia, le pasa inputs y usa outputs.
#
# Idea clave: el consumidor controla QUÉ VERSIÓN descarga con source + ref.
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

# --- Referencia al módulo ------------------------------------------------------
# El argumento `source` es la dirección del módulo + la versión (ref).
#
#  ┌─────────────────────────────────────────────────────────────────────────┐
#  │  git::URL//subcarpeta?ref=TAG                                           │
#  │       │      │            └── tag SemVer: congela el código             │
#  │       │      └── doble slash: subcarpeta del módulo dentro del repo     │
#  │       └── protocolo Git (HTTPS o SSH)                                   │
#  └─────────────────────────────────────────────────────────────────────────┘

module "bucket" {
  # OPCIÓN A — Demo en aula (inmediata, sin tags ni push):
  source = "../publisher/s3"

  # OPCIÓN B — Tras publicar tags en GitHub (descomenta y comenta la opción A):
  # source = "git::https://github.com/my-it-labs/terraform-avanzado-301.git//labs-sandbox/m05/publisher/s3?ref=m05-s3-v1.0.0"
  #
  # Para actualizar a v1.1.0 de forma controlada:
  #   1. Cambia ref=m05-s3-v1.1.0
  #   2. terraform init -upgrade
  #   3. terraform plan
  #
  # ⚠️  NUNCA uses ref=main en producción: cualquier commit del autor te afecta.

  bucket_name = "${var.project}-${var.environment}-data"
  tags        = var.common_tags

  # [v1.1.0] Solo disponible si el ref apunta a una versión que declare force_destroy.
  # Con ref=v1.0.0, Terraform ignora este argumento si no existe en el módulo remoto
  # (o falla validate si lo pasas y el módulo no lo declara — depende del flujo).
  force_destroy = var.force_destroy
}

# --- Outputs del entorno: reexportamos lo que devuelve el módulo ---------------

output "bucket_id" {
  description = "ID del bucket creado por el módulo remoto."
  value       = module.bucket.bucket_id
}

output "module_source" {
  description = "Ayuda didáctica: muestra de dónde viene el módulo (revisar en main.tf)."
  value       = "../publisher/s3 (local) o git + ?ref= en remoto"
}
