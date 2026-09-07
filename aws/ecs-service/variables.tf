variable "region" {
  description = "AWS region."
  type        = string
}

variable "docker_image" {
  description = "Base docker image to use."
  type        = string
}

variable "docker_tag" {
  description = "Tag of the docker image to use."
  type        = string
}

variable "cpu" {
  description = "CPU limits for container."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory limits for container."
  type        = number
  default     = 512
}

variable "skip_destroy" {
  description = "(Optional) Whether to retain the old revision when the resource is destroyed or replacement is necessary. Default is false."
  type        = bool
  default     = false
}

variable "service_environment_config" {
  description = "Service specific environment config"
  type        = list(map(string))
  default     = []
}

variable "service_secrets_config" {
  description = "Service specific environment secrets"
  type        = list(map(string))
  default     = []
}

variable "service_name" {
  description = "Name of the service to create."
  type        = string
}

variable "service_count" {
  description = "Number of replicas of the service to create. Defaults to 1."
  type        = number
  default     = 1
}

variable "deployment_maximum_percent" {
  description = "Maximum deployment as a percentage of `service_count`. Defaults to 200 for zero downtime deploys.."
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percentage for a deployment. Defaults to 100 for zero downtime deploys."
  type        = number
  default     = 100
}

variable "container_port" {
  description = "Port the container should expose."
  type        = number
  default     = 80
}

variable "cluster_name" {
  description = "Name of the ECS Cluster to deploy the service into."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to place the service into."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to apply to all resources in this module."
  type        = map(string)
  default     = {}
}

variable "wait_for_steady_state" {
  description = "Whether to wait for the service to become stable akin to `aws ecs wait services-stable`. Defaults to true."
  type        = bool
  default     = true
}

variable "max_capacity" {
  description = "A maximum capacity for autoscaling."
  type        = number
}

variable "min_capacity" {
  description = "A minimum capacity for autoscaling. Defaults to 1."
  type        = number
  default     = 1
}

variable "autoscaling_metrics" {
  description = "A map of autoscaling metrics."
  type = map(object({
    metric_type  = string
    target_value = number
  }))
  default = {
    cpu = {
      metric_type  = "ECSServiceAverageCPUUtilization"
      target_value = 55
    },
    memory = {
      metric_type  = "ECSServiceAverageMemoryUtilization"
      target_value = 70
    }
  }
}

variable "scale_in_cooldown" {
  description = "Prevents aggressive scale-in by enforcing a waiting period after tasks are removed."
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Minimum time to wait after a scale-out before allowing another scale-out, giving new tasks time to start contributing capacity."
  type        = number
  default     = 60
}

variable "scheduled_actions_enabled" {
  description = "Enables scheduled scaling to proactively increase or reduce capacity during predictable traffic patterns."
  type        = bool
  default     = false
}

variable "scheduled_scaling_actions" {
  description = <<EOT
Map of scheduled scaling actions keyed by a unique name. Each value must include:
- schedule     : AWS cron expression in UTC, e.g. 'cron(0 7 ? * MON-FRI *)'
- min_capacity : minimum desired tasks at schedule time
- max_capacity : maximum desired tasks at schedule time
EOT
  type = map(object({
    schedule     = string
    min_capacity = number
    max_capacity = number
  }))
  default = {}
}

variable "target_group_arn" {
  description = "ARN of the load balancer target group."
  type        = string
  default     = null
}

variable "target_group_mappings" {
  description = "Explicit load balancer target group to container port mappings. Takes precedence over `target_group_arn` when set."
  type = list(object({
    target_group_arn = string
    container_port   = number
  }))
  default = []
}

variable "security_groups" {
  description = "A list of security group IDs to asssociate with the service."
  type        = list(string)
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group to use with the service."
  type        = string
}

variable "execution_role_policy_arns" {
  description = "A list of additional policy ARNs to attach to the service's execution role."
  type        = list(string)
  default     = []
}

variable "task_role_policy_arns" {
  description = "A list of additional policy ARNs to attach to the service's task role."
  type        = list(string)
  default     = []
}

variable "timeout" {
  description = "Timeout time for the ECS service to become stable before producing a Terraform error."
  type        = string
  default     = "15m"
}

variable "private_dns_namespace" {
  description = "Private DNS namespace name. If provided, enables service discovery."
  type        = string
  default     = null
}

variable "enable_ecs_exec" {
  description = "Whether to enable AWS ECS Exec for the task. Defaults to `false`."
  type        = bool
  default     = false
}

variable "container_command" {
  description = "String array representing the command to run in the container. First argument should be the shell to use, if required. Defaults to `null`, that is, no command override."
  type        = list(string)
  default     = null
}

variable "container_entrypoint" {
  description = "String array representing the entrypoint of the container. Supply to override the Dockerfile. Defaults to `null`, that is, not overriding the Dockerfile."
  type        = list(string)
  default     = null
}

variable "enable_rollback" {
  description = "Whether to enable circuit breaker rollbacks. Defaults to `true`."
  type        = bool
  default     = true
}

variable "container_definition_kind" {
  description = <<EOT
  The kind of task to run.

  Can be either `job` or `web`. Defaults to `web`.

  - `web` - A task that runs a web service and is backed by a load balancer.
  - `job` - A task that runs any arbitrary job with the priveleges of the task role and stops.
  EOT
  type        = string
  default     = "web"

  validation {
    condition     = contains(["web", "job"], var.container_definition_kind)
    error_message = "container_definition_kind must be either 'web' or 'job'."
  }
}

variable "has_autoscaler" {
  description = "Whether the service has an autoscaler. Defaults to `false`."
  type        = bool
  default     = true
}

variable "enable_alarms" {
  description = "Whether to enable CloudWatch alarms for the service. Defaults to `true`."
  type        = bool
  default     = true
}

variable "sns_topic_arns" {
  description = "List of SNS topic ARNs for alarm notifications"
  type        = list(string)
  default     = []
}

variable "observability_sns_topic_arns" {
  description = "SNS topic ARNs for lower-urgency observability alarms (high CPU)"
  type        = list(string)
  default     = null
}

variable "ecs_capacity_loss_topic_arns" {
  description = "SNS topic ARNs for ECS capacity loss alarms"
  type        = list(string)
  default     = null
}

variable "cpu_alarm_threshold" {
  type        = number
  description = "CPU % at which to alarm — should be ~25% above autoscaling target"
  default     = null
}

variable "readonly_root_filesystem" {
  description = <<EOT
  Whether the container's root filesystem is mounted read-only. Defaults to `false`.

  Satisfies Security Hub control ECS.5 ("ECS containers should be limited to read-only
  access to root filesystems"). It stops a threat actor who exploits a vulnerability in
  the image from tampering with the image's own binaries and config, and confines any
  write to the paths declared in `writable_paths` — which are ephemeral, so nothing
  survives the task. It does NOT restrict access to the host filesystem, and it does not
  prevent a payload being written to and run from a writable path such as `/tmp`.

  Defaults to `false` because the module cannot know which paths a given image writes
  to: enabling it without the matching `writable_paths` and `container_user` will
  crash-loop the service on boot, or break it later at runtime. Opt in per service, and
  verify in development first — see the module README.
  EOT
  type        = bool
  default     = false
}

variable "writable_paths" {
  description = <<EOT
  Absolute container paths that must stay writable when `readonly_root_filesystem` is
  enabled. Each path is backed by an ephemeral Fargate volume mounted at that path.

  Defaults to `["/tmp"]`. Rails services typically need their app tmp and log
  directories too, e.g. `["/tmp", "/app/tmp", "/app/log"]`. Check the image's `WORKDIR`
  rather than assuming `/app`.
  EOT
  type        = list(string)
  default     = ["/tmp"]

  validation {
    condition     = alltrue([for path in var.writable_paths : startswith(path, "/")])
    error_message = "Every entry in writable_paths must be an absolute path beginning with '/'."
  }

  validation {
    condition     = alltrue([for path in var.writable_paths : trim(path, "/") != ""])
    error_message = "writable_paths cannot contain the root path '/': mounting a volume over '/' would mask the image filesystem."
  }

  validation {
    condition     = alltrue([for path in var.writable_paths : !endswith(path, "/")])
    error_message = "Entries in writable_paths must not have a trailing slash, so that '/app/tmp' and '/app/tmp/' cannot become two volumes for the same mount point."
  }

  # Volume names are derived from the path (see locals.tf). Distinct paths can collide
  # once separators and unsupported characters are folded to '-' (e.g. '/app/tmp' and
  # '/app-tmp'), which would otherwise surface as an opaque duplicate-key error.
  validation {
    condition = length(distinct([
      for path in var.writable_paths :
      lower(replace(trim(path, "/"), "/[^a-zA-Z0-9_-]+/", "-"))
    ])) == length(var.writable_paths)
    error_message = "Two entries in writable_paths derive the same volume name once '/' and unsupported characters are replaced with '-'. Rename or drop one of them."
  }
}

variable "container_user" {
  description = <<EOT
  The user the container process runs as, in any form the ECS `user` field accepts
  (`user`, `uid`, `user:group`, `uid:gid`). Defaults to `null`, deferring to the
  `USER` directive in the image's Dockerfile.

  Set this when the image has no `USER` directive, so the task is never recorded as
  running as root.

  It is also REQUIRED when `readonly_root_filesystem` is true and the image runs as a
  non-root user: Fargate mounts the writable volumes root-owned, so the module adds an
  init container that chowns them to this user before the app container starts. Without
  it, a non-root app crash-loops on boot with `Permission denied`. Prefer `uid:gid`
  form and pin the ids in the image so the value cannot drift. See the module README.
  EOT
  type        = string
  default     = null
}
