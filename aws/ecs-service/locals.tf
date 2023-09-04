locals {
  account_id  = data.aws_caller_identity.current.account_id
  cluster_arn = data.aws_ecs_cluster.this.arn

  tags = merge(
    {
      Terraform = "true"
    },
    var.tags,
  )

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
        condition     = "COMPLETE"
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
}

data "aws_caller_identity" "current" {}

data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}

data "aws_cloudwatch_log_group" "this" {
  name = var.cloudwatch_log_group_name
}

data "aws_service_discovery_dns_namespace" "this" {
  count = var.private_dns_namespace != null ? 1 : 0
  name  = var.private_dns_namespace
  type  = "DNS_PRIVATE"
}
