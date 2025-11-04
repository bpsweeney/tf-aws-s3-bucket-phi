variable "bucket_name_prefix" {
  default     = "phi-"
  description = "Optional prefix for the name of the s3 bucket."
  type        = string
}

variable "cloudfront_distribuiton_arn" {
  default     = null
  description = "ARN of a CloudFront distribution for Origin Access Control."
  type        = string
}

variable "disable_lifecycle_configuration" {
  default     = false
  description = "Disable the default lifecycle configuration."
  type        = bool
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN."
  type        = string
  default     = "aws/s3"
}

variable "logging_bucket_id" {
  default     = null
  description = "Optional name of a logging destination bucket."
  type        = string
}

variable "logging_prefix" {
  default     = "logs/"
  description = "Optional prefix for log objects."
  type        = string

  validation {
    condition     = endswith(var.logging_prefix, "/")
    error_message = "Logging prefix must end with '/'."
  }
}

variable "object_lock_days" {
  default     = 0
  description = "Number of days to apply S3 object lock to new objects."
  type        = number

  validation {
    condition     = var.object_lock_days <= 2555
    error_message = "Objects cannot be locked for more than seven years."
  }
}

variable "tags" {
  description = "Tags to set on the bucket."
  type        = map(string)
  default     = {}
}

variable "trusted_read_only_arns" {
  description = "ARNs of principals that should have read-only access to the bucket."
  nullable    = false
  type        = list(string)

  validation {
    condition     = length(var.trusted_read_only_arns) > 0
    error_message = "There must be at least one ARN."
  }
}

variable "trusted_read_write_arns" {
  description = "ARNs of principals that should have read/write access to the bucket."
  nullable    = false
  type        = list(string)

  validation {
    condition     = length(var.trusted_read_write_arns) > 0
    error_message = "There must be at least one ARN."
  }
}
