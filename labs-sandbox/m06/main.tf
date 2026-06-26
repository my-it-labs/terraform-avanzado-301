# =============================================================================
# M06 — Expresiones avanzadas (sandbox completo)
# =============================================================================
# Labs: M06-01 for_each/count · M06-02 locals/merge/lookup · M06-03 dynamic/try/precondition
# Solo plan/validate — no apply.
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
# M06-02 — locals: valores calculados una vez, reutilizados en muchos recursos
# -----------------------------------------------------------------------------

locals {
  prefix = "${var.project}-${var.environment}"

  # M06-02 — for con if: solo buckets con versioning = true
  versioned_buckets = {
    for name, cfg in var.buckets : name => cfg
    if cfg.versioning
  }

  # M06-02 — etiquetas base compartidas
  base_tags = {
    Project   = var.project
    ManagedBy = "terraform"
    Lab       = "M06"
  }

  # M06-03 — try: cfg.tags puede no existir; merge combina base + específicas
  bucket_tags = {
    for name, cfg in var.buckets : name => merge(
      local.base_tags,
      {
        Role       = name
        Versioning = lookup(cfg, "versioning", false) ? "on" : "off"
      },
      try(cfg.tags, {})
    )
  }
}

# -----------------------------------------------------------------------------
# M06-01 — for_each: un bloque → N recursos identificados por clave (no por índice)
# M06-03 — precondition: falla en plan si el nombre no cumple convención del curso
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "this" {
  for_each = var.buckets
  bucket   = "curso-${var.lab_user}-${each.key}"
  tags     = local.bucket_tags[each.key]

  lifecycle {
    precondition {
      condition     = can(regex("^curso-", "curso-${var.lab_user}-${each.key}"))
      error_message = "Los buckets del curso deben usar el prefijo curso-<usuario>-."
    }
  }
}

# -----------------------------------------------------------------------------
# M06-02 — versionado solo en local.versioned_buckets (filtrado con for/if)
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "this" {
  for_each = local.versioned_buckets
  bucket   = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

# -----------------------------------------------------------------------------
# M06-01 — count: patrón on/off (0 o 1 recurso). NO uses count sobre listas reordenables.
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "inventory" {
  count  = var.create_inventory ? 1 : 0
  bucket = "${local.prefix}-inventory"
}

# -----------------------------------------------------------------------------
# M06-03 — dynamic: bloques hijos generados solo cuando hace falta (expire_days > 0)
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  dynamic "rule" {
    for_each = each.value.expire_days > 0 ? [each.value] : []
    content {
      id     = "expire-${each.key}"
      status = "Enabled"
      expiration {
        days = rule.value.expire_days
      }
    }
  }

  # Reto M06-03: segunda regla dynamic (Glacier) si glacier_days > 0
  dynamic "rule" {
    for_each = try(each.value.glacier_days, 0) > 0 ? [each.value] : []
    content {
      id     = "glacier-${each.key}"
      status = "Enabled"
      transition {
        days          = rule.value.glacier_days
        storage_class = "GLACIER"
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Outputs — útiles en plan para ver claves for_each y efecto de count
# -----------------------------------------------------------------------------

output "bucket_keys" {
  description = "Claves del mapa for_each (identidad estable)."
  value       = keys(aws_s3_bucket.this)
}

output "versioned_only" {
  description = "Buckets que reciben versionado (M06-02 filtro)."
  value       = keys(local.versioned_buckets)
}

output "inventory_created" {
  description = "true si count creó el bucket inventory (M06-01)."
  value       = var.create_inventory
}
