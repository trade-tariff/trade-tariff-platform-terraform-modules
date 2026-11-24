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
}

run "defaults_to_x86_64" {
  command = plan

  assert {
    condition     = one(aws_ecs_task_definition.this.runtime_platform).cpu_architecture == "X86_64"
    error_message = "task definition must stay on X86_64 when cpu_architecture is not set"
  }
}

run "uses_arm64_when_set" {
  command = plan

  variables {
    cpu_architecture = "ARM64"
  }

  assert {
    condition     = one(aws_ecs_task_definition.this.runtime_platform).cpu_architecture == "ARM64"
    error_message = "task definition must use ARM64 when cpu_architecture is ARM64"
  }
}

run "rejects_unknown_architecture" {
  command = plan

  variables {
    cpu_architecture = "arm64"
  }

  expect_failures = [var.cpu_architecture]
}
