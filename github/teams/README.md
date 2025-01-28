# teams

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.7 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 4.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 4.23.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_team.parent_team](https://registry.terraform.io/providers/integrations/github/4.23.0/docs/resources/team) | resource |
| [github_team.this](https://registry.terraform.io/providers/integrations/github/4.23.0/docs/resources/team) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_default_maintainer"></a> [create\_default\_maintainer](#input\_create\_default\_maintainer) | Adds the creating user to the team when set to `true`. | `string` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | A description of the team. | `string` | `""` | no |
| <a name="input_parent_team_description"></a> [parent\_team\_description](#input\_parent\_team\_description) | The description of the parent team. | `string` | `""` | no |
| <a name="input_parent_team_name"></a> [parent\_team\_name](#input\_parent\_team\_name) | The name of the parent team. | `string` | n/a | yes |
| <a name="input_privacy"></a> [privacy](#input\_privacy) | The level of privacy for the team. Must be one of secret or closed. | `string` | `"secret"` | no |
| <a name="input_sub_teams"></a> [sub\_teams](#input\_sub\_teams) | A list of sub teams to add to the parent team. | `set(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_teams"></a> [teams](#output\_teams) | n/a |
<!-- END_TF_DOCS -->
