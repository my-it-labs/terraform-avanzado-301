# =============================================================================
# Módulo S3 — versión 1.1.0 (MINOR)
# =============================================================================
# Publicado por el *autor* del módulo. Los consumidores lo referencian con:
#   git::https://github.com/ORG/REPO.git//ruta/al/modulo?ref=v1.1.0
#
# Historial:
#   v1.0.0 — bucket + versionado + tags (ver ../snippets/main.v1.0.0.tf)
#   v1.1.0 — añade force_destroy (input opcional, default false) → MINOR SemVer
#
# Regla SemVer para autores:
#   - Input nuevo con default  → MINOR (los consumidores actuales no se rompen)
#   - Quitar/renombrar input   → MAJOR (rompe la interfaz)
# =============================================================================

# --- Inputs: contrato público del módulo -------------------------------------
# Todo lo que declares aquí es lo que el consumidor puede (o debe) pasar.

variable "bucket_name" {
  type        = string
  description = "Nombre global único del bucket S3."
}

variable "tags" {
  type        = map(string)
  description = "Etiquetas AWS aplicadas al bucket."
  default     = {} # default = el input es opcional para quien consume el módulo
}

variable "versioning" {
  type        = bool
  description = "Activa (true) o suspende (false) el versionado del bucket."
  default     = true
}

# [v1.1.0] Nuevo input opcional: no obliga al consumidor a cambiar su código.
# Quien ya usaba v1.0.0 sigue funcionando; quien quiera vaciar al destroy pasa true.
variable "force_destroy" {
  type        = bool
  description = "Permite borrar el bucket aunque tenga objetos (útil en labs)."
  default     = false
}

# --- Recursos: detalle interno oculto al consumidor ---------------------------
# El consumidor solo ve inputs/outputs; no necesita saber cómo montamos el bucket.

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags

  # [v1.1.0] Expuesto vía variable; en v1.0.0 no existía (Terraform usaba false implícito).
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning ? "Enabled" : "Suspended"
  }
}

# --- Outputs: lo que el módulo devuelve al caller ----------------------------

output "bucket_id" {
  description = "ID del bucket (nombre)."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN del bucket; útil para políticas IAM u otros módulos."
  value       = aws_s3_bucket.this.arn
}
