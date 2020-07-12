resource "aws_s3_bucket" "s3" {
  count = var.create && var.resource_create ? 1 : 0
  bucket_prefix = var.bucket_prefix
  acl           = "private"
  force_destroy = var.s3_bucket_force_destroy

  versioning {
    enabled = var.versioning
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
        kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_arn : null
      }
    }
  }
  tags = var.tags
}

resource "aws_s3_bucket_policy" "b" {
  count = var.create && var.resource_create ? 1 : 0
  bucket = element(aws_s3_bucket.s3.*.id, count.index)
  policy = try(var.policy, null)
}