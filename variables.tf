variable "bucket_name_prefix" {
  default     = "phi-"
  description = <<-EOT
    Optional prefix for the name of the s3 bucket. Terraform will prefix this
    before a procedurally generated ID that has a very high likelihood of being
    unique. The provided prefix must follow the requirements of an S3 bucket
    name with the additional restriction that it must not exceed 37 characters,
    as the ID provided by Terraform consumes 26 of the 63 character limit. The
    prefix should end in a non-alphanumeric character to make it easier to
    distinguish from the unique ID.
    EOT
  type        = string
}

variable "cloudfront_distribuiton_arn" {
  default     = null
  description = <<-EOT
    ARN of a CloudFront distribution for Origin Access Control. AWS recommends
    that OAC be set in the bucket policy before it is applied to the CloudFront
    distribution. The documentation does not indicate whether Terraform will
    apply the correct order of operations, so this variable may need to be
    applied before creating an `aws_cloudfront_origin_access_control` resource.
    resource.
    EOT
  type        = string
}

variable "disable_lifecycle_configuration" {
  default     = false
  description = <<-EOT
    Disable the default lifecycle configuration. If left at the default, this
    value allows for a lifecycle configuration with *reasonable* settings for
    PHI to be created. Set this to `true` if the lifecycle configuration is not
    desired.
    EOT
  type        = bool
}

variable "kms_key_arn" {
  description = <<-EOT
    Optional KMS key ARN. By default, objects added to this bucket will be
    encrypted with the AWS KMS service key for S3. Provide the ARN of a customer
    managed KMS key if the default key does not meet your requirements.
    EOT
  type        = string
  default     = "aws/s3"
}

variable "logging_bucket_id" {
  default     = null
  description = <<-EOT
    Optional name of a logging destination bucket. This should be provided if
    server access logs need to be collected for this bucket. The destination
    bucket must be in the same account and region where this bucket will be
    deployed.
    EOT
  type        = string
}

variable "logging_prefix" {
  default     = "logs/"
  description = <<-EOT
    Optional prefix for log objects. This is the root prefix of the object key
    (path) for objects put into the logging destination bucket.
    EOT
  type        = string

  validation {
    condition     = endswith(var.logging_prefix, "/")
    error_message = "Logging prefix must end with '/'."
  }
}

variable "object_lock_days" {
  default     = 0
  description = <<-EOT
    Optional number of days to apply S3 object lock to new objects. Object lock
    is disabled by default. Setting this number to a positive value will cause
    object lock to be enabled in compliance mode and set to the specified number
    of days. Be careful with high values, because objects that have been locked
    in compliance mode cannot be removed without closing the owning AWS account
    and allowing the suspension period to lapse.
    EOT
  type        = number

  validation {
    condition     = var.object_lock_days <= 2555
    error_message = "Object locking not allowed to exceed seven years."
  }
}

variable "tags" {
  description = <<-EOT
    Optional tags to set on the bucket. These will be merged with a set of tags
    defined in the module. The modue's default tag values can be overridden by
    providing tags with the same keys here.
    EOT
  type        = map(string)
  default     = {}
}

variable "trusted_read_write_arns" {
  description = <<-EOT
    ARNs of principals that should have read/write access to the bucket. These
    entities will have the same limited list and read actions as read-only
    principals, and they will have limited write and tagging permissions.
    EOT
  nullable    = false
  type        = list(string)

  validation {
    condition     = length(var.trusted_read_write_arns) > 0
    error_message = "There must be at least one ARN."
  }
}
