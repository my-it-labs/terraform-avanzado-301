# =============================================================================
# Snapshot v1.0.0 — primera versión publicada (referencia para la demo)
# =============================================================================
# NO es el módulo activo: vive aquí para que el formador compare con s3/main.tf.
# Al etiquetar v1.0.0 en Git, el árbol del repo en ese commit se parecía a esto.
# =============================================================================

variable "bucket_name" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}

variable "versioning" {
  type    = bool
  default = true
}

# Nota: en v1.0.0 NO existía force_destroy.

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning ? "Enabled" : "Suspended"
  }
}

output "bucket_id"  { value = aws_s3_bucket.this.id }
output "bucket_arn" { value = aws_s3_bucket.this.arn }
