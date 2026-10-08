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

  cpu_step_scaling = {
    threshold          = 80
    scaling_adjustment = 3
  }
}

run "cpu_step_scaling_alarm_reacts_after_one_minute" {
  command = plan

  assert {
    condition     = aws_cloudwatch_metric_alarm.cpu_step_scale_out[0].threshold == 80
    error_message = "alarm threshold did not match cpu_step_scaling.threshold"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.cpu_step_scale_out[0].period == 60 && aws_cloudwatch_metric_alarm.cpu_step_scale_out[0].evaluation_periods == 1
    error_message = "alarm must use one 60 second period, so that scale-out starts within about 2 minutes"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.cpu_step_scale_out[0].namespace == "AWS/ECS" && aws_cloudwatch_metric_alarm.cpu_step_scale_out[0].metric_name == "CPUUtilization"
    error_message = "alarm must watch the ECS service CPUUtilization metric"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.cpu_step_scale_out[0].comparison_operator == "GreaterThanOrEqualToThreshold"
    error_message = "alarm must fire when CPU is at or above the threshold"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.cpu_step_scale_out[0].dimensions["ServiceName"] == "frontend" && aws_cloudwatch_metric_alarm.cpu_step_scale_out[0].dimensions["ClusterName"] == "trade-tariff-cluster-test"
    error_message = "alarm dimensions must name the service and cluster"
  }
}

run "cpu_step_scaling_policy_adds_tasks" {
  command = plan

  assert {
    condition     = aws_appautoscaling_policy.cpu_step_scale_out[0].policy_type == "StepScaling"
    error_message = "policy must use step scaling"
  }

  assert {
    condition     = aws_appautoscaling_policy.cpu_step_scale_out[0].step_scaling_policy_configuration[0].adjustment_type == "ChangeInCapacity"
    error_message = "policy must add a fixed number of tasks"
  }

  assert {
    condition     = one(aws_appautoscaling_policy.cpu_step_scale_out[0].step_scaling_policy_configuration[0].step_adjustment).scaling_adjustment == 3
    error_message = "step adjustment did not match cpu_step_scaling.scaling_adjustment"
  }

  assert {
    condition     = one(aws_appautoscaling_policy.cpu_step_scale_out[0].step_scaling_policy_configuration[0].step_adjustment).metric_interval_lower_bound == "0"
    error_message = "step adjustment must apply from the alarm threshold upwards"
  }

  assert {
    condition     = aws_appautoscaling_policy.cpu_step_scale_out[0].step_scaling_policy_configuration[0].cooldown == 60
    error_message = "cooldown must default to 60 seconds"
  }
}

run "cpu_step_scaling_keeps_target_tracking" {
  command = plan

  assert {
    condition     = aws_appautoscaling_policy.this["cpu"].policy_type == "TargetTrackingScaling"
    error_message = "target tracking policy must stay, so that it still handles scale-in"
  }
}

run "cpu_step_scaling_null_creates_nothing" {
  command = plan

  variables {
    cpu_step_scaling = null
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.cpu_step_scale_out) == 0 && length(aws_appautoscaling_policy.cpu_step_scale_out) == 0
    error_message = "expected no step scaling resources when cpu_step_scaling is null"
  }
}

run "cpu_step_scaling_needs_autoscaler" {
  command = plan

  variables {
    has_autoscaler = false
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.cpu_step_scale_out) == 0 && length(aws_appautoscaling_policy.cpu_step_scale_out) == 0
    error_message = "expected no step scaling resources when has_autoscaler is false"
  }
}

run "cpu_step_scaling_rejects_non_positive_adjustment" {
  command = plan

  variables {
    cpu_step_scaling = {
      threshold          = 80
      scaling_adjustment = 0
    }
  }

  expect_failures = [var.cpu_step_scaling]
}
