# cdn

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/acm | v0.0.2 |
| <a name="module_cdn"></a> [cdn](#module\_cdn) | git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront | aws/cloudfront-v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_cache_policy.cache_all_qsa](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_origin_request_policy.forward_all_qsa](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/resources/cloudfront_origin_request_policy) | resource |
| [aws_cloudfront_cache_policy.caching_disabled](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/3.72.0/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_domain_name"></a> [base\_domain\_name](#input\_base\_domain\_name) | n/a | `string` | `"trade-tariff.service.gov.uk."` | no |
| <a name="input_cdn_aliases"></a> [cdn\_aliases](#input\_cdn\_aliases) | n/a | `list(string)` | n/a | yes |
| <a name="input_environment_key"></a> [environment\_key](#input\_environment\_key) | n/a | `any` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | n/a | `any` | n/a | yes |
| <a name="input_origin_endpoint"></a> [origin\_endpoint](#input\_origin\_endpoint) | n/a | `any` | n/a | yes |
| <a name="input_web_acl_id"></a> [web\_acl\_id](#input\_web\_acl\_id) | If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution. The WAF Web ACL must exist in the WAF Global (CloudFront) region and the credentials configuring this argument must have waf:GetWebACL permissions assigned. If using WAFv2, provide the ARN of the web ACL. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
