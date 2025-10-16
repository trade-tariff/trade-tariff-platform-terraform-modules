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
      target_value = 75
    },
    memory = {
      metric_type  = "ECSServiceAverageMemoryUtilization"
      target_value = 70
    }
  }
}

variable "target_group_arn" {
  description = "ARN of the load balancer target group."
  type        = string
  default     = null
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

variable "init_container_entrypoint" {
  description = "String array representing the entrypoint of the init container. Supply to override the Dockerfile. Defaults to `null`, that is, not overriding the Dockerfile."
  type        = list(string)
  default     = null
}

variable "init_container_command" {
  description = "String array representing the command to run in the init container. First argument should be the shell to use, if required. Defaults to `null`, that is, no command override."
  type        = list(string)
  default     = null
}

variable "container_definition_kind" {
  description = <<EOT
  The kind of task to run.

  Can be either `db-backed` or `job` or `web`. Defaults to `web`.

  - `db-backed` - A task that is backed by a database and typically drives database migrations.
  - `job` - A task that runs any arbitrary job with the priveleges of the task role and stops.
  - `web` - A task that runs a web service and is backed by a load balancer.
  EOT
  type        = string
  default     = "web"
}

variable "has_autoscaler" {
  description = "Whether the service has an autoscaler. Defaults to `false`."
  type        = bool
  default     = true
}

variable "enable_service_count_alarm" {
  description = "Whether to create a CloudWatch alarm for the service that alarms when there are no running tasks for the service. Defaults to `true`."
  type        = bool
  default     = true
}

variable "slack_topic_arn" {
  description = "SNS topic ARN for Slack notifications"
  type        = string
}
