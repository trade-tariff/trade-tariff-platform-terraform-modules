mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

mock_provider "random" {}

variables {
  region                    = "eu-west-2"
  docker_image              = "example/frontend"
  docker_tag                = "latest"
  service_name              = "frontend"
  cluster_name              = "trade-tariff-cluster-test"
  subnet_ids                = ["subnet-1"]
  max_capacity              = 10
  security_groups           = ["sg-1"]
  cloudwatch_log_group_name = "platform-logs-test"

  metric_step_scaling = {
    puma-backlog = {
      namespace          = "TradeTariff/Puma"
      metric_name        = "BacklogMax"
      statistic          = "Maximum"
      dimensions         = { Environment = "test", Service = "frontend" }
      threshold          = 50
      scaling_adjustment = 3
    }
  }
}

run "metric_step_scaling_alarm_watches_the_given_metric" {
  command = plan

  assert {
    condition     = aws_cloudwatch_metric_alarm.metric_step_scale_out["puma-backlog"].namespace == "TradeTariff/Puma" && aws_cloudwatch_metric_alarm.metric_step_scale_out["puma-backlog"].metric_name == "BacklogMax"
    error_message = "alarm must watch the metric given in metric_step_scaling"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.metric_step_scale_out["puma-backlog"].statistic == "Maximum"
    error_message = "alarm statistic did not match metric_step_scaling.statistic"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.metric_step_scale_out["puma-backlog"].dimensions["Service"] == "frontend" && aws_cloudwatch_metric_alarm.metric_step_scale_out["puma-backlog"].dimensions["Environment"] == "test"
    error_message = "alarm dimensions did not match metric_step_scaling.dimensions"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.metric_step_scale_out["puma-backlog"].threshold == 50 && aws_cloudwatch_metric_alarm.metric_step_scale_out["puma-backlog"].comparison_operator == "GreaterThanOrEqualToThreshold"
    error_message = "alarm must fire when the metric is at or above the threshold"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.metric_step_scale_out["puma-backlog"].period == 60 && aws_cloudwatch_metric_alarm.metric_step_scale_out["puma-backlog"].evaluation_periods == 1
    error_message = "alarm must default to one 60 second period"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.metric_step_scale_out["puma-backlog"].treat_missing_data == "notBreaching"
    error_message = "missing data must not breach, so a busy task that stops reporting does not flap the alarm"
  }
}

run "metric_step_scaling_policy_adds_tasks" {
  command = plan

  assert {
    condition     = aws_appautoscaling_policy.metric_step_scale_out["puma-backlog"].policy_type == "StepScaling"
    error_message = "policy must use step scaling"
  }

  assert {
    condition     = one(aws_appautoscaling_policy.metric_step_scale_out["puma-backlog"].step_scaling_policy_configuration[0].step_adjustment).scaling_adjustment == 3
    error_message = "step adjustment did not match metric_step_scaling.scaling_adjustment"
  }

  assert {
    condition     = aws_appautoscaling_policy.metric_step_scale_out["puma-backlog"].step_scaling_policy_configuration[0].metric_aggregation_type == "Maximum"
    error_message = "policy aggregation must follow the Maximum statistic"
  }

  assert {
    condition     = aws_appautoscaling_policy.metric_step_scale_out["puma-backlog"].step_scaling_policy_configuration[0].cooldown == 180
    error_message = "cooldown must default to 180 seconds"
  }
}

run "metric_step_scaling_empty_creates_nothing" {
  command = plan

  variables {
    metric_step_scaling = {}
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.metric_step_scale_out) == 0 && length(aws_appautoscaling_policy.metric_step_scale_out) == 0
    error_message = "expected no step scaling resources when metric_step_scaling is empty"
  }
}

run "metric_step_scaling_needs_autoscaler" {
  command = plan

  variables {
    has_autoscaler = false
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.metric_step_scale_out) == 0 && length(aws_appautoscaling_policy.metric_step_scale_out) == 0
    error_message = "expected no step scaling resources when has_autoscaler is false"
  }
}

run "metric_step_scaling_rejects_unknown_statistic" {
  command = plan

  variables {
    metric_step_scaling = {
      puma-backlog = {
        namespace          = "TradeTariff/Puma"
        metric_name        = "BacklogMax"
        statistic          = "p99"
        dimensions         = {}
        threshold          = 50
        scaling_adjustment = 3
      }
    }
  }

  expect_failures = [var.metric_step_scaling]
}

run "metric_step_scaling_rejects_period_not_multiple_of_60" {
  command = plan

  variables {
    metric_step_scaling = {
      puma-backlog = {
        namespace          = "TradeTariff/Puma"
        metric_name        = "BacklogMax"
        statistic          = "Maximum"
        dimensions         = {}
        threshold          = 50
        scaling_adjustment = 3
        period             = 90
      }
    }
  }

  expect_failures = [var.metric_step_scaling]
}

run "metric_step_scaling_rejects_non_positive_adjustment" {
  command = plan

  variables {
    metric_step_scaling = {
      puma-backlog = {
        namespace          = "TradeTariff/Puma"
        metric_name        = "BacklogMax"
        statistic          = "Maximum"
        dimensions         = {}
        threshold          = 50
        scaling_adjustment = 0
      }
    }
  }

  expect_failures = [var.metric_step_scaling]
}

run "metric_step_scaling_rejects_cooldown_below_60" {
  command = plan

  variables {
    metric_step_scaling = {
      puma-backlog = {
        namespace          = "TradeTariff/Puma"
        metric_name        = "BacklogMax"
        statistic          = "Maximum"
        dimensions         = {}
        threshold          = 50
        scaling_adjustment = 3
        cooldown           = 30
      }
    }
  }

  expect_failures = [var.metric_step_scaling]
}

run "alb_request_count_target_tracking_passes_resource_label" {
  command = plan

  variables {
    metric_step_scaling = {}
    autoscaling_metrics = {
      requests = {
        metric_type    = "ALBRequestCountPerTarget"
        target_value   = 1000
        resource_label = "app/test-alb/abc123/targetgroup/frontend-https/def456"
      }
    }
  }

  assert {
    condition     = aws_appautoscaling_policy.this["requests"].target_tracking_scaling_policy_configuration[0].predefined_metric_specification[0].resource_label == "app/test-alb/abc123/targetgroup/frontend-https/def456"
    error_message = "resource_label must be passed to the predefined metric"
  }
}

run "alb_request_count_target_tracking_requires_resource_label" {
  command = plan

  variables {
    metric_step_scaling = {}
    autoscaling_metrics = {
      requests = {
        metric_type  = "ALBRequestCountPerTarget"
        target_value = 1000
      }
    }
  }

  expect_failures = [var.autoscaling_metrics]
}

run "cpu_target_tracking_without_resource_label_is_unchanged" {
  command = plan

  variables {
    metric_step_scaling = {}
  }

  assert {
    condition     = aws_appautoscaling_policy.this["cpu"].target_tracking_scaling_policy_configuration[0].predefined_metric_specification[0].resource_label == null
    error_message = "CPU target tracking must not set a resource_label"
  }
}
