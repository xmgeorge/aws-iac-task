# Bootstrap: creates the S3 bucket that stores the main configuration's remote
# state. This config uses LOCAL state itself (chicken-and-egg — the backend
# can't store its own bucket), so it is applied once, by hand, before the
# infrastructure/ config is initialised against S3.
#
# State locking is handled by the S3 backend's native lockfile (use_lockfile,
# Terraform >= 1.10), so no DynamoDB table is needed.

data "aws_caller_identity" "current" {}

locals {
  # Account id makes the globally-unique bucket name deterministic.
  state_bucket_name = "${var.project}-tfstate-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "state" {
  bucket = local.state_bucket_name

  tags = {
    Name = "${var.project}-tfstate"
  }
}

# Keep every state revision so a bad apply can be rolled back.
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt state at rest (state can contain sensitive values).
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# State must never be public.
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
