variable "environment" {
  description = "Environment name, i.e. `development`, `staging`, `production`."
  type        = string
}

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
  description = "Maximum deployment as a percentage of `service_count`. Defaults to 100."
  type        = number
  default     = 100
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percentage for a deployment. Defaults to 0, disabling this check."
  type        = number
  default     = 0
}

variable "container_port" {
  description = "Port the container should expose."
  type        = number
  default     = 80
}

variable "task_role_arn" {
  description = "ARN of the task role to use for the service."
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the execution role to use for the service."
  type        = string
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
      target_value = 75
    }
  }
}

variable "target_group_arn" {
  description = "ARN of the load balancer target group."
  type        = string
}

variable "security_groups" {
  description = "A list of security group IDs to asssociate with the service."
  type        = list(string)
}

variable "container_instance_policy" {
  description = "ECS instance policy"
  type        = string
  default     = "container-instances-policy"
}

variable "task_name" {
  description = "ECS Task name"
  type        = string
}

variable "service_role_namee" {
  description = "Service role name"
  type        = string
}