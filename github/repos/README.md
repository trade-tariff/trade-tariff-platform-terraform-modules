# repos

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | 6.2.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [github_branch_protection.repo_protect_main](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_repository.repo](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_team_repository.repo_team_admin](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |
| [github_team_repository.repo_team_maintain](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |
| [github_team_repository.repo_team_pull](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |
| [github_team_repository.repo_team_push](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_teams"></a> [admin\_teams](#input\_admin\_teams) | n/a | `list(any)` | `[]` | no |
| <a name="input_allow_push_to_main"></a> [allow\_push\_to\_main](#input\_allow\_push\_to\_main) | n/a | `string` | `"true"` | no |
| <a name="input_allow_rebase_merge"></a> [allow\_rebase\_merge](#input\_allow\_rebase\_merge) | n/a | `bool` | `false` | no |
| <a name="input_allow_squash_merge"></a> [allow\_squash\_merge](#input\_allow\_squash\_merge) | n/a | `bool` | `false` | no |
| <a name="input_archived"></a> [archived](#input\_archived) | n/a | `bool` | `false` | no |
| <a name="input_default_branch_name"></a> [default\_branch\_name](#input\_default\_branch\_name) | n/a | `string` | `"main"` | no |
| <a name="input_delete_branch_on_merge"></a> [delete\_branch\_on\_merge](#input\_delete\_branch\_on\_merge) | n/a | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | n/a | yes |
| <a name="input_enforce_admins"></a> [enforce\_admins](#input\_enforce\_admins) | Whether to enforce branch protection against admins e.g. no push to main, no merge without approvals | `bool` | `false` | no |
| <a name="input_has_downloads"></a> [has\_downloads](#input\_has\_downloads) | n/a | `bool` | `true` | no |
| <a name="input_has_issues"></a> [has\_issues](#input\_has\_issues) | n/a | `bool` | `false` | no |
| <a name="input_has_projects"></a> [has\_projects](#input\_has\_projects) | n/a | `bool` | `false` | no |
| <a name="input_has_wiki"></a> [has\_wiki](#input\_has\_wiki) | n/a | `bool` | `false` | no |
| <a name="input_homepage_url"></a> [homepage\_url](#input\_homepage\_url) | n/a | `string` | `""` | no |
| <a name="input_is_template"></a> [is\_template](#input\_is\_template) | Set to true to tell GitHub that this is a template repository. | `bool` | `null` | no |
| <a name="input_maintain_teams"></a> [maintain\_teams](#input\_maintain\_teams) | n/a | `list(any)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_pages"></a> [pages](#input\_pages) | (Optional) The repository's GitHub Pages configuration. (Default: {}) | `any` | `null` | no |
| <a name="input_push_teams"></a> [push\_teams](#input\_push\_teams) | n/a | `list(any)` | `[]` | no |
| <a name="input_read_teams"></a> [read\_teams](#input\_read\_teams) | n/a | `list(any)` | `[]` | no |
| <a name="input_require_code_owner_reviews"></a> [require\_code\_owner\_reviews](#input\_require\_code\_owner\_reviews) | n/a | `bool` | `false` | no |
| <a name="input_require_signed_commits"></a> [require\_signed\_commits](#input\_require\_signed\_commits) | Whether this branch requires all commits to be signed before push or merge. | `bool` | `false` | no |
| <a name="input_required_approving_review_count"></a> [required\_approving\_review\_count](#input\_required\_approving\_review\_count) | n/a | `number` | `2` | no |
| <a name="input_required_status_check_contexts"></a> [required\_status\_check\_contexts](#input\_required\_status\_check\_contexts) | List of status checks which need to pass before a pull-request can be merged. | `list(any)` | `[]` | no |
| <a name="input_strict_status_check"></a> [strict\_status\_check](#input\_strict\_status\_check) | Whether to require branches to be up-to-date before merging. | `bool` | `true` | no |
| <a name="input_template"></a> [template](#input\_template) | Template repository and owner to use | `list(map(string))` | `[]` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | n/a | `string` | `"private"` | no |
| <a name="input_vulnerability_alerts"></a> [vulnerability\_alerts](#input\_vulnerability\_alerts) | GitHub vulnerability alerts | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repo_node_id"></a> [repo\_node\_id](#output\_repo\_node\_id) | n/a |
<!-- END_TF_DOCS -->
