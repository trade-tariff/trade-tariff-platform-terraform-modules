# teams

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 6.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_team.parent_team](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |
| [github_team.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_default_maintainer"></a> [create\_default\_maintainer](#input\_create\_default\_maintainer) | Adds the creating user to the team when set to `true`. | `string` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | A description of the team. | `string` | `""` | no |
| <a name="input_parent_team_description"></a> [parent\_team\_description](#input\_parent\_team\_description) | The description of the parent team. | `string` | `""` | no |
| <a name="input_parent_team_name"></a> [parent\_team\_name](#input\_parent\_team\_name) | The name of the parent team. | `string` | n/a | yes |
| <a name="input_privacy"></a> [privacy](#input\_privacy) | The level of privacy for the team. Must be one of `secret` or `closed`. | `string` | `"secret"` | no |
| <a name="input_sub_teams"></a> [sub\_teams](#input\_sub\_teams) | A list of sub teams to add to the parent team. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sub_team_ids"></a> [sub\_team\_ids](#output\_sub\_team\_ids) | List of IDs of created sub-teams. |
| <a name="output_sub_teams"></a> [sub\_teams](#output\_sub\_teams) | Map of sub-team slug and ID. |
| <a name="output_team_id"></a> [team\_id](#output\_team\_id) | ID of the parent team. |
| <a name="output_team_slug"></a> [team\_slug](#output\_team\_slug) | Slug of the parent team. |
<!-- END_TF_DOCS -->
