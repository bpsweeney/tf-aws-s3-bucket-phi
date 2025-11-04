output "bucket_arn" {
  description = "ARN of the bucket."
  value       = aws_s3_bucket.s3_bucket.arn
}

output "bucket_name" {
  description = "Name (ID) of the bucket."
  value       = aws_s3_bucket.s3_bucket.id
}

output "bucket_policy" {
  description = "Bucket policy document JSON."
  value       = data.aws_iam_policy_document.s3_bucket.json
}
