# =============================================================================
# Snapshot M06-01 — for_each + count (referencia; no ejecutar directamente)
# =============================================================================

variable "project" {
  type    = string
  default = "tfadv"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "create_inventory" {
  type    = bool
  default = false
}

locals {
  prefix = "${var.project}-${var.environment}"
  buckets = {
    logs = { versioning = false }
    data = { versioning = true }
    tmp  = { versioning = false }
  }
}

resource "aws_s3_bucket" "this" {
  for_each = local.buckets
  bucket   = "${local.prefix}-${each.key}"
}

resource "aws_s3_bucket" "inventory" {
  count  = var.create_inventory ? 1 : 0
  bucket = "${local.prefix}-inventory"
}
