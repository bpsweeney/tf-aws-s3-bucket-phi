locals {
  s3_read_only_actions = [
    "s3:ListBucket",
    "s3:ListTagsForResource",
    "s3:GetObject",
    "s3:GetObjectAcl",
    "s3:GetObjectVersion",
    "s3:GetObjectVersionAcl",
  ]
}
