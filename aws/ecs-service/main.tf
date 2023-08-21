resource "aws_ecs_service" "this" {
  name             = "${var.service_name}-${var.environment}"
  cluster          = local.cluster_arn
  task_definition  = aws_ecs_task_definition.this.arn
  desired_count    = var.service_count
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  enable_execute_command = var.enable_ecs_exec

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? [1] : []
    content {
      container_name   = var.service_name
      container_port   = var.container_port
      target_group_arn = var.target_group_arn
    }
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = var.security_groups
    subnets          = var.subnet_ids
  }

  dynamic "service_registries" {
    for_each = var.private_dns_namespace != null ? [true] : []
    content {
      registry_arn = aws_service_discovery_service.this[0].arn
    }
  }

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  wait_for_steady_state              = var.wait_for_steady_state

  timeouts {
    create = var.timeout
    update = var.timeout
    delete = var.timeout
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = local.tags
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.service_name}-${var.environment}-${local.account_id}"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  skip_destroy             = var.skip_destroy
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = jsonencode([
    {
      name        = var.service_name
      image       = "${var.docker_image}:${var.docker_tag}"
      essential   = true
      environment = local.merged_environment
      secrets     = local.merged_secrets

      entryPoint = var.container_entrypoint
      command    = var.container_command

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
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = local.tags
}

resource "aws_appautoscaling_target" "this" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "this" {
  for_each           = var.autoscaling_metrics
  name               = "${aws_ecs_service.this.name}-scaling-policy-${each.key}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = each.value.metric_type
    }
    target_value = each.value.target_value
  }

  depends_on = [aws_appautoscaling_target.this]
}

resource "aws_service_discovery_service" "this" {
  count = var.private_dns_namespace != null ? 1 : 0
  name  = var.service_name

  dns_config {
    namespace_id   = data.aws_service_discovery_dns_namespace.this[0].id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_codedeploy_app" "this" {
  count            = var.enable_blue_green ? 1 : 0
  compute_platform = "ECS"
  name             = var.service_name
  tags             = local.tags
}

resource "aws_codedeploy_deployment_group" "this" {
  count                  = var.enable_blue_green ? 1 : 0
  app_name               = aws_codedeploy_app.this[0].name
  deployment_config_name = var.deployment_configuration
  deployment_group_name  = var.service_name
  service_role_arn       = aws_iam_role.execution_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = data.aws_ecs_cluster.this.cluster_name
    service_name = aws_ecs_service.this.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.listener_arn]
      }

      target_group {
        name = var.blue_target_group_name
      }

      target_group {
        name = var.green_target_group_name
      }
    }
  }
}
