/* 
 *  IAM role for fargate instances to use when they are launched
 */

data "aws_iam_policy_document" "ecs_tasks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = var.task_name
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


/* 
 *  Container instance Iam role
 */
resource "aws_iam_role_policy" "container_instances_policy" {
  name   = var.container_instance_policy
  role   = aws_iam_role.container_instances.id
  policy = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_role" "container_instances" {
  name               = var.service_role_name
  assume_role_policy = file("${path.module}/files/ecs-assume-policy.json")
}

