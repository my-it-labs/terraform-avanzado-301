# =============================================================================
# Variables del sandbox M06
# =============================================================================

variable "project" {
  type        = string
  description = "Nombre corto del proyecto."
  default     = "tfadv"
}

variable "environment" {
  type        = string
  description = "Entorno: dev, test, prod."
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "Región del provider (solo para plan; no apply en M06)."
  default     = "us-east-2"
}

variable "lab_user" {
  type        = string
  description = "Identificador alumno; prefijo curso-<usuario> (M06-03 precondition)."
  default     = "alumno"
}

variable "create_inventory" {
  type        = bool
  description = "M06-01: count = 1 crea bucket inventory; count = 0 no lo crea."
  default     = false
}

variable "buckets" {
  description = "Mapa de buckets lógicos; clave estable para for_each (M06-01+)."
  type = map(object({
    versioning   = bool
    expire_days  = optional(number, 0)
    glacier_days = optional(number, 0)
    tags         = optional(map(string), {})
  }))
  default = {
    logs = { versioning = false }
    data = {
      versioning  = true
      expire_days = 90 # M06-03: dynamic lifecycle solo si > 0
    }
    tmp = { versioning = false }
  }
}
