# Terraform AWS S3 Bucket for PHI

This module provisions AWS S3 buckets configured to securely store and access
PHI.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) (resource)
- [aws_s3_bucket_lifecycle_configuration.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) (resource)
- [aws_s3_bucket_logging.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) (resource)
- [aws_s3_bucket_object_lock_configuration.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) (resource)
- [aws_s3_bucket_ownership_controls.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) (resource)
- [aws_s3_bucket_policy.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) (resource)
- [aws_s3_bucket_public_access_block.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) (resource)
- [aws_s3_bucket_server_side_encryption_configuration.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) (resource)
- [aws_s3_bucket_versioning.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) (resource)
- [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
- [aws_iam_policy_document.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_trusted_read_only_arns"></a> [trusted\_read\_only\_arns](#input\_trusted\_read\_only\_arns)

Description: ARNs of principals that should have read-only access to the bucket. These
entities will have limited list and read permissions on the bucket and its
objects.

Type: `list(string)`

### <a name="input_trusted_read_write_arns"></a> [trusted\_read\_write\_arns](#input\_trusted\_read\_write\_arns)

Description: ARNs of principals that should have read/write access to the bucket. These
entities will have the same limited list and read actions as read-only
principals, and they will have limited write and tagging permissions.

Type: `list(string)`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_bucket_name_prefix"></a> [bucket\_name\_prefix](#input\_bucket\_name\_prefix)

Description: Optional prefix for the name of the s3 bucket. Terraform will prefix this
before a procedurally generated ID that has a very high likelihood of being
unique. The provided prefix must follow the requirements of an S3 bucket
name with the additional restriction that it must not exceed 37 characters,
as the ID provided by Terraform consumes 26 of the 63 character limit. The
prefix should end in a non-alphanumeric character to make it easier to
distinguish from the unique ID.

Type: `string`

Default: `"phi-"`

### <a name="input_cloudfront_distribuiton_arn"></a> [cloudfront\_distribuiton\_arn](#input\_cloudfront\_distribuiton\_arn)

Description: ARN of a CloudFront distribution for Origin Access Control. AWS recommends
that OAC be set in the bucket policy before it is applied to the CloudFront
distribution. The documentation does not indicate whether Terraform will
apply the correct order of operations, so this variable may need to be
applied before creating an `aws_cloudfront_origin_access_control` resource.
resource.

Type: `string`

Default: `null`

### <a name="input_disable_lifecycle_configuration"></a> [disable\_lifecycle\_configuration](#input\_disable\_lifecycle\_configuration)

Description: Disable the default lifecycle configuration. If left at the default, this
value allows for a lifecycle configuration with *reasonable* settings for
PHI to be created. Set this to `true` if the lifecycle configuration is not
desired.

Type: `bool`

Default: `false`

### <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn)

Description: Optional KMS key ARN. By default, objects added to this bucket will be
encrypted with the AWS KMS service key for S3. Provide the ARN of a customer
managed KMS key if the default key does not meet your requirements.

Type: `string`

Default: `"aws/s3"`

### <a name="input_logging_bucket_id"></a> [logging\_bucket\_id](#input\_logging\_bucket\_id)

Description: Optional name of a logging destination bucket. This should be provided if
server access logs need to be collected for this bucket. The destination
bucket must be in the same account and region where this bucket will be
deployed.

Type: `string`

Default: `null`

### <a name="input_logging_prefix"></a> [logging\_prefix](#input\_logging\_prefix)

Description: Optional prefix for log objects. This is the root prefix of the object key
(path) for objects put into the logging destination bucket.

Type: `string`

Default: `"logs/"`

### <a name="input_object_lock_days"></a> [object\_lock\_days](#input\_object\_lock\_days)

Description: Optional number of days to apply S3 object lock to new objects. Object lock
is disabled by default. Setting this number to a positive value will cause
object lock to be enabled in compliance mode and set to the specified number
of days. Be careful with high values, because objects that have been locked
in compliance mode cannot be removed without closing the owning AWS account
and allowing the suspension period to lapse.

Type: `number`

Default: `0`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Optional tags to set on the bucket. These will be merged with a set of tags
defined in the module. The modue's default tag values can be overridden by
providing tags with the same keys here.

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn)

Description: Full ARN of the PHI bucket. May be used in IAM permissions policies to grant
access to additional principals in the same account.

### <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name)

Description: Name (ID) of the bucket. This should be passed to the CloudFront origin
access config if this bucket will be used as a CloudFront origin.

### <a name="output_bucket_policy"></a> [bucket\_policy](#output\_bucket\_policy)

Description: Bucket policy document JSON. This may be useful in troubleshooting access
issues, especially if there is an issue reading the bucket policy from AWS.
<!-- END_TF_DOCS -->
