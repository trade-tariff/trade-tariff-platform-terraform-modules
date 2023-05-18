# common

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 3.72.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | = 3.72.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.rule](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.docker](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/ecr_repository) | resource |
| [aws_iam_access_key.ci-account](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_access_key) | resource |
| [aws_iam_access_key.dit-database-backups-account](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_access_key) | resource |
| [aws_iam_access_key.service-account](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_access_key) | resource |
| [aws_iam_access_key.trade-tariff-bot-account](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_access_key) | resource |
| [aws_iam_policy.database-backups-read](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.database-backups-read-write](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecr_policy](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.es_policy](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.opensearch-package](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.persistence](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.reporting](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.search-configuration](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ses_policy](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_policy) | resource |
| [aws_iam_policy.terragrunt-state](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecr_access](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_role) | resource |
| [aws_iam_user.ci-account](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_user) | resource |
| [aws_iam_user.dit-database-backups-account](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_user) | resource |
| [aws_iam_user.service-account](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_user) | resource |
| [aws_iam_user.trade-tariff-bot-account](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.ses-policy](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_user_policy) | resource |
| [aws_iam_user_policy_attachment.ci-account-s3-attachments](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.ci-ecr](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.ci-es](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.ci-ses](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.dit-database-backups-account-s3-attachments](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.service-account-s3-attachments](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.trade-tariff-bot-terragrunt-state-s3-attachment](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_route53_record.google_validation](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/route53_record) | resource |
| [aws_route53_record.tariff_domain_verification_record](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/route53_record) | resource |
| [aws_s3_bucket.database-backups](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.opensearch_packages](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.persistence](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.reporting](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.search_configuration](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.terragrunt-state](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.database-backups](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.opensearch-packages](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.persistence](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.reporting](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.search-configuration](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_ses_domain_identity.tariff_domain](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/ses_domain_identity) | resource |
| [aws_ses_domain_identity_verification.tariff-domain-verification](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/ses_domain_identity_verification) | resource |
| [aws_ses_email_identity.notify_email](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/ses_email_identity) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ecr](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.es](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3-database-backups-read-policy](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3-database-backups-read-write-policy](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3-persistence-policy](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3-reporting-policy](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3-search-configuration-policy](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3-search-package-policy](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3-terragrunt-state-policy](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ses](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ses-policy](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.s3_kms_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/kms_key) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_docker_repositories"></a> [docker\_repositories](#input\_docker\_repositories) | List of repositories to create | `list(string)` | <pre>[<br>  "tariff-backend",<br>  "tariff-frontend",<br>  "tariff-dutycalculator",<br>  "tariff-admin",<br>  "tariff-search-query-parser",<br>  "signon"<br>]</pre> | no |
| <a name="input_environments"></a> [environments](#input\_environments) | list of environment name keys to use in environment interpolations | `list(any)` | <pre>[<br>  "development",<br>  "staging",<br>  "production"<br>]</pre> | no |
| <a name="input_notification_email"></a> [notification\_email](#input\_notification\_email) | Email address from where to send worker reports | `string` | `"trade-tariff-support@enginegroup.com"` | no |
| <a name="input_project-key"></a> [project-key](#input\_project-key) | The project key to use in prefixing resources | `string` | `"trade-tariff"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ci_iam_id"></a> [ci\_iam\_id](#output\_ci\_iam\_id) | n/a |
| <a name="output_ci_secret"></a> [ci\_secret](#output\_ci\_secret) | n/a |
| <a name="output_service_iam_id"></a> [service\_iam\_id](#output\_service\_iam\_id) | n/a |
| <a name="output_service_secret"></a> [service\_secret](#output\_service\_secret) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
