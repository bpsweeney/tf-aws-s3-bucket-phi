resource "aws_s3_bucket" "s3_bucket" {
  bucket_prefix       = var.bucket_name_prefix
  object_lock_enabled = var.object_lock_days > 0

  tags = merge(
    var.tags,
    {
      "data_classification" = "phi"
      "managed_by"          = "terraform"
    }
  )
}

data "aws_iam_policy_document" "s3_bucket" {
  version = "2012-10-17"

  statement {
    sid     = "ReadGetObject"
    effect  = "Allow"
    actions = local.s3_read_only_actions
    resources = [
      aws_s3_bucket.s3_bucket.arn,
      "${aws_s3_bucket.s3_bucket.arn}/*",
    ]

    principals {
      identifiers = var.trusted_read_only_arns
      type        = "AWS"
    }
  }

  statement {
    sid    = "WritePutObject"
    effect = "Allow"
    actions = concat(
      local.s3_read_only_actions,
      [
        "s3:PutObject",
        "s3:PutObjectTagging",
        "s3:PutObjectVersionTagging",
      ]
    )
    resources = [
      aws_s3_bucket.s3_bucket.arn,
      "${aws_s3_bucket.s3_bucket.arn}/*",
    ]

    principals {
      identifiers = var.trusted_read_write_arns
      type        = "AWS"
    }
  }

  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.s3_bucket.arn,
      "${aws_s3_bucket.s3_bucket.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [false]
    }
  }

  dynamic "statement" {
    for_each = var.cloudfront_distribuiton_arn == null ? [] : [1]

    content {
      sid       = "AllowCloudFrontServicePrincipalReadOnly"
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["${aws_s3_bucket.s3_bucket.arn}/*"]

      condition {
        test     = "StringEquals"
        variable = "AWS:SourceArn"
        values   = [var.cloudfront_distribuiton_arn]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.s3_bucket.json
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket" {
  count  = var.disable_lifecycle_configuration ? 0 : 1
  bucket = aws_s3_bucket.s3_bucket.id

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  rule {
    id     = "CleanUpStaleMarkers"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    expiration {
      expired_object_delete_marker = true
    }
  }

  rule {
    id     = "TransitionToLowCostStorage"
    status = "Enabled"

    filter {}

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }

  rule {
    id     = "ExpireOldObjects"
    status = "Enabled"

    filter {}

    expiration {
      days = 2556
    }

    noncurrent_version_expiration {
      noncurrent_days = 2556
    }
  }
}

resource "aws_s3_bucket_logging" "s3_bucket" {
  count  = var.logging_bucket_id == null ? 0 : 1
  bucket = aws_s3_bucket.s3_bucket.id

  target_bucket = var.logging_bucket_id
  target_prefix = var.logging_prefix

  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "EventTime"
    }
  }
}

resource "aws_s3_bucket_object_lock_configuration" "s3_bucket" {
  count  = var.object_lock_days > 0 ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id

  expected_bucket_owner = data.aws_caller_identity.current.account_id
  object_lock_enabled   = "Enabled"

  rule {
    default_retention {
      days = var.object_lock_days
      mode = "COMPLIANCE"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  versioning_configuration {
    status = "Enabled"
  }
}
