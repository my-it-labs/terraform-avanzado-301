# =============================================================================
# Snapshot M06-02 — locals, merge, lookup, for con if (referencia)
# =============================================================================

locals {
  versioned_buckets = {
    for name, cfg in local.buckets : name => cfg
    if cfg.versioning
  }

  base_tags = {
    Project   = var.project
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket" "this" {
  for_each = local.buckets
  bucket   = "${local.prefix}-${each.key}"
  tags = merge(local.base_tags, {
    Role       = each.key
    Versioning = lookup(each.value, "versioning", false) ? "on" : "off"
  })
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = local.versioned_buckets
  bucket   = aws_s3_bucket.this[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}
