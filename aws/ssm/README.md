# ssm

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.59.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_ssm_parameter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Whether to create a KMS key to encrypt the SSM parameters at rest. | `bool` | `false` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ID of the KMS key to use to encrypt the parameters at rest. If supplying a key external to the module, this takes precedence over the key created using `create_kms_key`. | `string` | `null` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | List of SSM parameter objects to create. | <pre>list(object(<br>    {<br>      name  = string<br>      value = any<br>      tier  = optional(string)<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to pass on to the module resources. | `object({})` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | KMS key ID, if `var.create_kms_key` is `true`. |
| <a name="output_parameter_arns"></a> [parameter\_arns](#output\_parameter\_arns) | A map of the ARNs of the supplied parameters. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->