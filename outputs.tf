output "bucket_arn" {
  description = <<-EOT
    Full ARN of the PHI bucket. May be used in IAM permissions policies to grant
    access to additional principals in the same account.
    EOT
  value       = aws_s3_bucket.s3_bucket.arn
}

output "bucket_name" {
  description = <<-EOT
    Name (ID) of the bucket. This should be passed to the CloudFront origin
    access config if this bucket will be used as a CloudFront origin.
    EOT
  value       = aws_s3_bucket.s3_bucket.id
}

output "bucket_policy" {
  description = <<-EOT
    Bucket policy document JSON. This may be useful in troubleshooting access
    issues, especially if there is an issue reading the bucket policy from AWS.
    EOT
  value       = data.aws_iam_policy_document.s3_bucket.json
}
