# Variables del *consumidor* — distintas de las del módulo publicado.
# Aquí defines el contexto del entorno (proyecto, entorno, región).

variable "project" {
  type        = string
  description = "Nombre corto del proyecto consumidor."
}

variable "environment" {
  type        = string
  description = "Entorno: dev, test, prod."
}

variable "aws_region" {
  type        = string
  description = "Región AWS del provider."
  default     = "us-east-2"
}

variable "common_tags" {
  type        = map(string)
  description = "Etiquetas que el consumidor pasa al módulo (contrato de entrada)."
  default = {
    ManagedBy = "terraform"
    Lab       = "M05"
  }
}

variable "force_destroy" {
  type        = bool
  description = "Reenviado al módulo; solo tiene efecto con ref >= v1.1.0."
  default     = false
}
