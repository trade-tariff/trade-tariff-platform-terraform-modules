# ECS Service

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.93.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.execution_role_additional_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_role_additional_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_service_discovery_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_log_group) | data source |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_iam_policy_document.ecs_tasks_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_service_discovery_dns_namespace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/service_discovery_dns_namespace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaling_metrics"></a> [autoscaling\_metrics](#input\_autoscaling\_metrics) | A map of autoscaling metrics. | <pre>map(object({<br/>    metric_type  = string<br/>    target_value = number<br/>  }))</pre> | <pre>{<br/>  "cpu": {<br/>    "metric_type": "ECSServiceAverageCPUUtilization",<br/>    "target_value": 40<br/>  },<br/>  "memory": {<br/>    "metric_type": "ECSServiceAverageMemoryUtilization",<br/>    "target_value": 40<br/>  }<br/>}</pre> | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | CloudWatch log group to use with the service. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the ECS Cluster to deploy the service into. | `string` | n/a | yes |
| <a name="input_container_command"></a> [container\_command](#input\_container\_command) | String array representing the command to run in the container. First argument should be the shell to use, if required. Defaults to `null`, that is, no command override. | `list(string)` | `null` | no |
| <a name="input_container_definition_kind"></a> [container\_definition\_kind](#input\_container\_definition\_kind) | The kind of task to run.<br/><br/>  Can be either `db-backed` or `job` or `web`. Defaults to `web`.<br/><br/>  - `db-backed` - A task that is backed by a database and typically drives database migrations.<br/>  - `job` - A task that runs any arbitrary job with the priveleges of the task role and stops.<br/>  - `web` - A task that runs a web service and is backed by a load balancer. | `string` | `"web"` | no |
| <a name="input_container_entrypoint"></a> [container\_entrypoint](#input\_container\_entrypoint) | String array representing the entrypoint of the container. Supply to override the Dockerfile. Defaults to `null`, that is, not overriding the Dockerfile. | `list(string)` | `null` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port the container should expose. | `number` | `80` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU limits for container. | `number` | `256` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | Maximum deployment as a percentage of `service_count`. Defaults to 200 for zero downtime deploys.. | `number` | `200` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | Minimum healthy percentage for a deployment. Defaults to 100 for zero downtime deploys. | `number` | `100` | no |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Base docker image to use. | `string` | n/a | yes |
| <a name="input_docker_tag"></a> [docker\_tag](#input\_docker\_tag) | Tag of the docker image to use. | `string` | n/a | yes |
| <a name="input_enable_ecs_exec"></a> [enable\_ecs\_exec](#input\_enable\_ecs\_exec) | Whether to enable AWS ECS Exec for the task. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_enable_rollback"></a> [enable\_rollback](#input\_enable\_rollback) | Whether to enable circuit breaker rollbacks. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_execution_role_policy_arns"></a> [execution\_role\_policy\_arns](#input\_execution\_role\_policy\_arns) | A list of additional policy ARNs to attach to the service's execution role. | `list(string)` | `[]` | no |
| <a name="input_init_container_command"></a> [init\_container\_command](#input\_init\_container\_command) | String array representing the command to run in the init container. First argument should be the shell to use, if required. Defaults to `null`, that is, no command override. | `list(string)` | `null` | no |
| <a name="input_init_container_entrypoint"></a> [init\_container\_entrypoint](#input\_init\_container\_entrypoint) | String array representing the entrypoint of the init container. Supply to override the Dockerfile. Defaults to `null`, that is, not overriding the Dockerfile. | `list(string)` | `null` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | A maximum capacity for autoscaling. | `number` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory limits for container. | `number` | `512` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | A minimum capacity for autoscaling. Defaults to 1. | `number` | `1` | no |
| <a name="input_private_dns_namespace"></a> [private\_dns\_namespace](#input\_private\_dns\_namespace) | Private DNS namespace name. If provided, enables service discovery. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of security group IDs to asssociate with the service. | `list(string)` | n/a | yes |
| <a name="input_service_count"></a> [service\_count](#input\_service\_count) | Number of replicas of the service to create. Defaults to 1. | `number` | `1` | no |
| <a name="input_service_environment_config"></a> [service\_environment\_config](#input\_service\_environment\_config) | Service specific environment config | `list(map(string))` | `[]` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service to create. | `string` | n/a | yes |
| <a name="input_service_secrets_config"></a> [service\_secrets\_config](#input\_service\_secrets\_config) | Service specific environment secrets | `list(map(string))` | `[]` | no |
| <a name="input_skip_destroy"></a> [skip\_destroy](#input\_skip\_destroy) | (Optional) Whether to retain the old revision when the resource is destroyed or replacement is necessary. Default is false. | `bool` | `false` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs to place the service into. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources in this module. | `map(string)` | `{}` | no |
| <a name="input_target_group_arn"></a> [target\_group\_arn](#input\_target\_group\_arn) | ARN of the load balancer target group. | `string` | `null` | no |
| <a name="input_task_role_policy_arns"></a> [task\_role\_policy\_arns](#input\_task\_role\_policy\_arns) | A list of additional policy ARNs to attach to the service's task role. | `list(string)` | `[]` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout time for the ECS service to become stable before producing a Terraform error. | `string` | `"15m"` | no |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | Whether to wait for the service to become stable akin to `aws ecs wait services-stable`. Defaults to true. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_task_execution_role_arn"></a> [task\_execution\_role\_arn](#output\_task\_execution\_role\_arn) | Task execution role ARN. |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | Task role ARN. |
<!-- END_TF_DOCS -->
