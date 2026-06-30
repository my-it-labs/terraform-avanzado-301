# =============================================================================
# Variables del sandbox M07-drift — análisis de drift
# =============================================================================

variable "aws_region" {
  type        = string
  description = "Región del provider."
  default     = "us-east-2"
}

variable "lab_user" {
  type        = string
  description = "Identificador del alumno; el bucket usa prefijo curso-<lab_user>-."
  default     = "alumno"
}
