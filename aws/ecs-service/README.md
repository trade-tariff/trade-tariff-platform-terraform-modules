# ECS Service

## Container hardening

The module can render task definitions with a **read-only root filesystem**
(`readonly_root_filesystem`, default `true`). This closes the attack path Amazon
Inspector and Security Hub report as _"the container can access the host root
filesystem"_ (Security Hub control **ECS.5**), and stops an exploited image
vulnerability turning into a persistent foothold or a crypto-miner.

Paths the process still needs to write to are declared in `writable_paths`. Each is
backed by an ephemeral, task-scoped Fargate volume, destroyed when the task stops.

### This conflicts with ECS Exec — read before enabling

AWS **does not support** combining ECS Exec with a read-only root filesystem. From the
[ECS Exec considerations](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html):

> The SSM agent requires that the container file system can be written to in order to
> create the required directories and files. Therefore, making the root file system
> read-only using the `readonlyRootFilesystem` task definition parameter, or any other
> method, isn't supported.

When `enable_ecs_exec` and `readonly_root_filesystem` are both true, this module mounts
writable volumes over `/var/lib/amazon/ssm`, `/var/log/amazon/ssm` and `/managed-agents`
so the agent can still start — the last of these is where ECS itself bind-mounts the
exec agent binary into the container, so without it present and writable the task can
fail to start at all, not just `execute-command`. This is the community workaround, not
a supported configuration — AWS may change the agent's paths without notice, and the
failure mode is that exec breaks *silently*, discovered only when someone needs
break-glass access during an incident.

Verify `aws ecs execute-command` actually works in development after any bump, and treat
it as a check that can regress. Tracked upstream at
[containers-roadmap#1359](https://github.com/aws/containers-roadmap/issues/1359).

Note also that exec sessions run as **root inside the container** regardless of
`container_user`, so leaving exec enabled materially limits what the read-only root
filesystem buys you.

### Non-root images must set `container_user`

Fargate mounts these ephemeral volumes **root-owned, mode `0755`**, and gives no way to
set the mount owner. It offers no `tmpfs` either, so a writable volume is the only
option under a read-only root filesystem. An image that runs as a non-root user (all our
Rails images declare `USER tariff`) therefore cannot write into its own mounted `tmp`
and `log` directories, and crash-loops on boot with `Permission denied`.

To fix this the module prepends a small **init container** (`<service>-volume-permissions`)
when `container_user` is set: it reuses the application image, runs as root, `chown -R`s
the `writable_paths` mounts to `container_user`, and exits. The application container
declares `dependsOn … condition = SUCCESS` on it, so it will not start until the chown
has completed. The SSM agent paths are deliberately left out of this — that agent runs
as root regardless.

So for any non-root image you **must** pass `container_user` matching the image's
runtime user, e.g.:

```hcl
writable_paths = ["/tmp", "/home/tariff/tmp", "/home/tariff/log"]
container_user = "1000:1000"
```

Pin the id in the image (`adduser -u 1000 -g 1000 …`) so the value is stable rather than
whatever `adduser -S` happened to pick. Leave `container_user` unset only for an image
that genuinely runs as root — then no init container is added and root can write to the
mounts directly.

`bootsnap` (loaded in `config/boot.rb` on backend and frontend) writes to `tmp/cache`
during boot, so the app `tmp` path is not optional for those services. The frontend runs
from `/home/tariff`, not `/app` — check each image's `WORKDIR` rather than copying these
values. If a service writes somewhere unexpected, add that path rather than setting
`readonly_root_filesystem = false`; the failure is a clear `Read-only file system` or
`Permission denied` error naming the path.

## Upgrading to v4

`readonly_root_filesystem` defaults to `true`, so bumping the pinned `ref` changes
behaviour. Consumers pin refs, so merging and tagging alone changes nothing running.
Per service:

1. Pin a fixed uid/gid in the image if it runs non-root, rebuild and deploy it.
2. Bump the ref, setting `writable_paths` for the image's `WORKDIR` and `container_user`
   to its uid/gid.
3. Confirm a steady state **and** a working `execute-command` in development and staging
   before production.

Start with a low-traffic service (`mcp`, `dev-hub`) rather than backend.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_appautoscaling_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_scheduled_action.scheduled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_metric_alarm.ecs_capacity_loss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ecs_high_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.service_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
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
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_autoscaling_metrics"></a> [autoscaling\_metrics](#input\_autoscaling\_metrics) | A map of autoscaling metrics. | <pre>map(object({<br/>    metric_type  = string<br/>    target_value = number<br/>  }))</pre> | <pre>{<br/>  "cpu": {<br/>    "metric_type": "ECSServiceAverageCPUUtilization",<br/>    "target_value": 55<br/>  },<br/>  "memory": {<br/>    "metric_type": "ECSServiceAverageMemoryUtilization",<br/>    "target_value": 70<br/>  }<br/>}</pre> | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | CloudWatch log group to use with the service. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the ECS Cluster to deploy the service into. | `string` | n/a | yes |
| <a name="input_container_command"></a> [container\_command](#input\_container\_command) | String array representing the command to run in the container. First argument should be the shell to use, if required. Defaults to `null`, that is, no command override. | `list(string)` | `null` | no |
| <a name="input_container_definition_kind"></a> [container\_definition\_kind](#input\_container\_definition\_kind) | The kind of task to run.<br/><br/>  Can be either `job` or `web`. Defaults to `web`.<br/><br/>  - `web` - A task that runs a web service and is backed by a load balancer.<br/>  - `job` - A task that runs any arbitrary job with the priveleges of the task role and stops. | `string` | `"web"` | no |
| <a name="input_container_entrypoint"></a> [container\_entrypoint](#input\_container\_entrypoint) | String array representing the entrypoint of the container. Supply to override the Dockerfile. Defaults to `null`, that is, not overriding the Dockerfile. | `list(string)` | `null` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port the container should expose. | `number` | `80` | no |
| <a name="input_container_user"></a> [container\_user](#input\_container\_user) | The user the container process runs as, in any form the ECS `user` field accepts<br/>  (`user`, `uid`, `user:group`, `uid:gid`). Defaults to `null`, deferring to the<br/>  `USER` directive in the image's Dockerfile.<br/><br/>  Set this when the image has no `USER` directive, so the task is never recorded as<br/>  running as root.<br/><br/>  It is also REQUIRED when `readonly_root_filesystem` is true and the image runs as a<br/>  non-root user: Fargate mounts the writable volumes root-owned, so the module adds an<br/>  init container that chowns them to this user before the app container starts. Without<br/>  it, a non-root app crash-loops on boot with `Permission denied`. Prefer `uid:gid`<br/>  form and pin the ids in the image. See the module README. | `string` | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU limits for container. | `number` | `256` | no |
| <a name="input_cpu_alarm_threshold"></a> [cpu\_alarm\_threshold](#input\_cpu\_alarm\_threshold) | CPU % at which to alarm — should be ~25% above autoscaling target | `number` | `null` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | Maximum deployment as a percentage of `service_count`. Defaults to 200 for zero downtime deploys.. | `number` | `200` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | Minimum healthy percentage for a deployment. Defaults to 100 for zero downtime deploys. | `number` | `100` | no |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Base docker image to use. | `string` | n/a | yes |
| <a name="input_docker_tag"></a> [docker\_tag](#input\_docker\_tag) | Tag of the docker image to use. | `string` | n/a | yes |
| <a name="input_ecs_capacity_loss_topic_arns"></a> [ecs\_capacity\_loss\_topic\_arns](#input\_ecs\_capacity\_loss\_topic\_arns) | SNS topic ARNs for ECS capacity loss alarms | `list(string)` | `null` | no |
| <a name="input_enable_alarms"></a> [enable\_alarms](#input\_enable\_alarms) | Whether to enable CloudWatch alarms for the service. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_enable_ecs_exec"></a> [enable\_ecs\_exec](#input\_enable\_ecs\_exec) | Whether to enable AWS ECS Exec for the task. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_enable_rollback"></a> [enable\_rollback](#input\_enable\_rollback) | Whether to enable circuit breaker rollbacks. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_execution_role_policy_arns"></a> [execution\_role\_policy\_arns](#input\_execution\_role\_policy\_arns) | A list of additional policy ARNs to attach to the service's execution role. | `list(string)` | `[]` | no |
| <a name="input_has_autoscaler"></a> [has\_autoscaler](#input\_has\_autoscaler) | Whether the service has an autoscaler. Defaults to `false`. | `bool` | `true` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | A maximum capacity for autoscaling. | `number` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory limits for container. | `number` | `512` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | A minimum capacity for autoscaling. Defaults to 1. | `number` | `1` | no |
| <a name="input_observability_sns_topic_arns"></a> [observability\_sns\_topic\_arns](#input\_observability\_sns\_topic\_arns) | SNS topic ARNs for lower-urgency observability alarms (high CPU) | `list(string)` | `null` | no |
| <a name="input_private_dns_namespace"></a> [private\_dns\_namespace](#input\_private\_dns\_namespace) | Private DNS namespace name. If provided, enables service discovery. | `string` | `null` | no |
| <a name="input_readonly_root_filesystem"></a> [readonly\_root\_filesystem](#input\_readonly\_root\_filesystem) | Whether the container's root filesystem is mounted read-only. Defaults to `true`.<br/><br/>  This closes the "container has root access to the host filesystem" attack path<br/>  reported by Amazon Inspector / Security Hub (control ECS.5). A read-only root<br/>  filesystem means a threat actor who exploits a vulnerability in the image cannot<br/>  persist a payload (miner, webshell, modified binary) onto the container filesystem.<br/><br/>  Rails/Puma services need writable `tmp`, `log` and `/tmp` paths — declare those in<br/>  `writable_paths` rather than turning this off.<br/><br/>  NOTE: AWS does not support combining this with ECS Exec. When `enable_ecs_exec` is<br/>  also true the module mounts the SSM agent's paths writable as a workaround — see the<br/>  module README before relying on break-glass access. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_scale_in_cooldown"></a> [scale\_in\_cooldown](#input\_scale\_in\_cooldown) | Prevents aggressive scale-in by enforcing a waiting period after tasks are removed. | `number` | `300` | no |
| <a name="input_scale_out_cooldown"></a> [scale\_out\_cooldown](#input\_scale\_out\_cooldown) | Minimum time to wait after a scale-out before allowing another scale-out, giving new tasks time to start contributing capacity. | `number` | `60` | no |
| <a name="input_scheduled_actions_enabled"></a> [scheduled\_actions\_enabled](#input\_scheduled\_actions\_enabled) | Enables scheduled scaling to proactively increase or reduce capacity during predictable traffic patterns. | `bool` | `false` | no |
| <a name="input_scheduled_scaling_actions"></a> [scheduled\_scaling\_actions](#input\_scheduled\_scaling\_actions) | Map of scheduled scaling actions keyed by a unique name. Each value must include:<br/>- schedule     : AWS cron expression in UTC, e.g. 'cron(0 7 ? * MON-FRI *)'<br/>- min\_capacity : minimum desired tasks at schedule time<br/>- max\_capacity : maximum desired tasks at schedule time | <pre>map(object({<br/>    schedule     = string<br/>    min_capacity = number<br/>    max_capacity = number<br/>  }))</pre> | `{}` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of security group IDs to asssociate with the service. | `list(string)` | n/a | yes |
| <a name="input_service_count"></a> [service\_count](#input\_service\_count) | Number of replicas of the service to create. Defaults to 1. | `number` | `1` | no |
| <a name="input_service_environment_config"></a> [service\_environment\_config](#input\_service\_environment\_config) | Service specific environment config | `list(map(string))` | `[]` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service to create. | `string` | n/a | yes |
| <a name="input_service_secrets_config"></a> [service\_secrets\_config](#input\_service\_secrets\_config) | Service specific environment secrets | `list(map(string))` | `[]` | no |
| <a name="input_skip_destroy"></a> [skip\_destroy](#input\_skip\_destroy) | (Optional) Whether to retain the old revision when the resource is destroyed or replacement is necessary. Default is false. | `bool` | `false` | no |
| <a name="input_sns_topic_arns"></a> [sns\_topic\_arns](#input\_sns\_topic\_arns) | List of SNS topic ARNs for alarm notifications | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs to place the service into. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources in this module. | `map(string)` | `{}` | no |
| <a name="input_target_group_arn"></a> [target\_group\_arn](#input\_target\_group\_arn) | ARN of the load balancer target group. | `string` | `null` | no |
| <a name="input_target_group_mappings"></a> [target\_group\_mappings](#input\_target\_group\_mappings) | Explicit load balancer target group to container port mappings. Takes precedence over `target_group_arn` when set. | <pre>list(object({<br/>    target_group_arn = string<br/>    container_port   = number<br/>  }))</pre> | `[]` | no |
| <a name="input_task_role_policy_arns"></a> [task\_role\_policy\_arns](#input\_task\_role\_policy\_arns) | A list of additional policy ARNs to attach to the service's task role. | `list(string)` | `[]` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout time for the ECS service to become stable before producing a Terraform error. | `string` | `"15m"` | no |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | Whether to wait for the service to become stable akin to `aws ecs wait services-stable`. Defaults to true. | `bool` | `true` | no |
| <a name="input_writable_paths"></a> [writable\_paths](#input\_writable\_paths) | Absolute container paths that must stay writable when `readonly_root_filesystem` is<br/>  enabled. Each path is backed by an ephemeral Fargate volume mounted at that path.<br/><br/>  Defaults to `["/tmp"]`. Rails services typically need their app tmp and log<br/>  directories too, e.g. `["/tmp", "/app/tmp", "/app/log"]`. | `list(string)` | <pre>[<br/>  "/tmp"<br/>]</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_task_execution_role_arn"></a> [task\_execution\_role\_arn](#output\_task\_execution\_role\_arn) | Task execution role ARN. |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | Task role ARN. |
<!-- END_TF_DOCS -->
