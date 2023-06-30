resource "aws_ecs_service" "this" {
  name             = "${var.service_name}-${var.environment}"
  cluster          = local.cluster_arn
  task_definition  = aws_ecs_task_definition.this.arn
  desired_count    = var.service_count
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  load_balancer {
    container_name   = var.service_name
    container_port   = var.container_port
    target_group_arn = var.target_group_arn
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = var.security_groups
    subnets          = var.subnet_ids
  }

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  wait_for_steady_state              = var.wait_for_steady_state

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = local.tags
}

resource "aws_ecs_task_definition" "this" {
  family             = "${var.service_name}-${var.environment}-${local.account_id}"
  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.execution_role.arn
  task_role_arn      = aws_iam_role.task_role.arn
  skip_destroy       = var.skip_destroy

  container_definitions = jsonencode([
    {
      name        = var.service_name
      image       = "${var.docker_image}:${var.docker_tag}"
      cpu         = var.cpu
      memory      = var.memory
      essential   = true
      environment = local.merged_environment
      secrets     = local.merged_secrets

      portMappings = [{
        protocol      = "tcp"
        containerPort = var.container_port
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.region
          awslogs-create-group  = true
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

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
