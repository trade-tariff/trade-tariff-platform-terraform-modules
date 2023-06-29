/* 
 *  IAM role for fargate instances to use when they are launched
 */


data "aws_iam_policy_document" "ecs_tasks_execution_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "TradeTariff-${var.environment}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role_policy.json
}


resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = aws_iam_role.ecs_tasks_execution_role.arn
}


/* 
 *  Container instance Iam role
 */
resource "aws_iam_role_policy" "container_instances_policy" {
  name   = var.container_instance_policy
  role   = aws_iam_role.container_instances.id
  policy = file("${path.module}/files/container-instance-assume-policy.json")
}

resource "aws_iam_role" "container_instances" {
  name               = "TradeTariff-${var.environment}-container-instances-role"
  assume_role_policy = aws_iam_role_policy.container_instances_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = aws_iam_role_policy.container_instances_policy.arn
}
