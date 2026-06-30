# =============================================================================
# Snapshot M07-01 paso 3 — recurso renombrado a "primary" (referencia)
# =============================================================================
# Sustituye el bloque "data" de main.tf por este y ejecuta:
#   terraform plan                                      # propone destruir+crear (NO aplicar)
#   terraform state mv aws_s3_bucket.data aws_s3_bucket.primary
#   terraform plan                                      # ahora "No changes"
# =============================================================================

resource "aws_s3_bucket" "primary" {
  bucket = "curso-${var.lab_user}-state-demo"
}
