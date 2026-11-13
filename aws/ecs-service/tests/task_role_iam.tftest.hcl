# Assertions here can only check resources by address. They cannot detect an
# extra attachment to the task role, for example a restored AmazonECS_FullAccess
# attachment. check_task_role_attachments.sh checks all planned attachments in
# the plan JSON of these runs. At least one run must set task_role_policy_arns.

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

run "trust_policy_allows_only_ecs_tasks" {
  command = plan

  assert {
    condition     = length(data.aws_iam_policy_document.ecs_tasks_assume_role_policy.statement) == 1
    error_message = "trust policy must have exactly one statement"
  }

  assert {
    condition = alltrue([
      for p in data.aws_iam_policy_document.ecs_tasks_assume_role_policy.statement[0].principals :
      p.type == "Service" && toset(p.identifiers) == toset(["ecs-tasks.amazonaws.com"])
    ])
    error_message = "trust policy must trust only ecs-tasks.amazonaws.com"
  }

  assert {
    condition     = length(data.aws_iam_policy_document.ecs_tasks_assume_role_policy.statement[0].principals) == 1
    error_message = "trust policy must have exactly one principal block"
  }
}

run "task_role_has_no_managed_policies_by_default" {
  command = plan

  assert {
    condition     = length(aws_iam_role_policy_attachment.task_role_additional_policies) == 0
    error_message = "task role must have no policy attachments when task_role_policy_arns is empty"
  }
}

run "task_role_attaches_only_given_policies" {
  command = plan

  variables {
    task_role_policy_arns = ["arn:aws:iam::123456789012:policy/frontend-task-role-policy"]
  }

  assert {
    condition     = aws_iam_role_policy_attachment.task_role_additional_policies[*].policy_arn == ["arn:aws:iam::123456789012:policy/frontend-task-role-policy"]
    error_message = "task role must attach only the policies in task_role_policy_arns"
  }
}

run "execution_role_keeps_task_execution_policy" {
  command = plan

  assert {
    condition     = aws_iam_role_policy_attachment.execution_role_policy.policy_arn == "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    error_message = "execution role must keep AmazonECSTaskExecutionRolePolicy"
  }
}
