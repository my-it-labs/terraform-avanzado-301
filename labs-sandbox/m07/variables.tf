# =============================================================================
# Variables del sandbox M07 — operar el estado
# =============================================================================

variable "aws_region" {
  type        = string
  description = "Región del provider."
  default     = "us-east-2"
}

variable "lab_user" {
  type        = string
  description = "Identificador del alumno; los buckets usan prefijo curso-<lab_user>-."
  default     = "alumno"
}
