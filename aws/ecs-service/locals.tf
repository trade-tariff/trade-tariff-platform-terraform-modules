locals {
  account_id  = data.aws_caller_identity.current.account_id
  cluster_arn = data.aws_ecs_cluster.this.arn
  tags = merge(
    {
      Terraform = "true"
    },
    var.tags,
  )

  actual_container_definition = jsonencode(local.container_definition_kinds[var.container_definition_kind])

  container_definition_kinds = {
    "web"       = local.container_definition
    "db-backed" = local.init_container_definition
    "job"       = local.job_container_definition
  }

  init_container_definition = [
    {
      name        = "${var.service_name}-init"
      image       = "${var.docker_image}:${var.docker_tag}"
      essential   = false
      environment = var.service_environment_config
      secrets     = var.service_secrets_config
      entryPoint  = var.init_container_entrypoint
      command     = var.init_container_command

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
          awslogs-group         = data.aws_cloudwatch_log_group.this.name
        }
      }
    },
    {
      name        = var.service_name
      image       = "${var.docker_image}:${var.docker_tag}"
      essential   = true
      environment = var.service_environment_config
      secrets     = var.service_secrets_config
      entryPoint  = var.container_entrypoint
      command     = var.container_command

      portMappings = [{
        protocol      = "tcp"
        containerPort = var.container_port
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
          awslogs-group         = data.aws_cloudwatch_log_group.this.name
        }
      }

      dependsOn = [{
        containerName = "${var.service_name}-init"
        condition     = "SUCCESS"
      }]
    }
  ]

  container_definition = [{
    name        = var.service_name
    image       = "${var.docker_image}:${var.docker_tag}"
    essential   = true
    environment = var.service_environment_config
    secrets     = var.service_secrets_config
    entryPoint  = var.container_entrypoint
    command     = var.container_command

    portMappings = [{
      protocol      = "tcp"
      containerPort = var.container_port
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
        awslogs-group         = data.aws_cloudwatch_log_group.this.name
      }
    }
  }]

  job_container_definition = [{
    name        = var.service_name
    image       = "${var.docker_image}:${var.docker_tag}"
    essential   = true
    command     = var.container_command
    environment = var.service_environment_config
    secrets     = var.service_secrets_config

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
        awslogs-group         = data.aws_cloudwatch_log_group.this.name
      }
    }
  }]

  # NOTE: Jobs that are ran on a schedule should not use an autoscaling policy and should instead start/stop as per the run-task command.
  has_autoscaler = var.container_definition_kind != "job" ? true : false

  autoscaling_metrics = local.has_autoscaler ? var.autoscaling_metrics : {}
}
