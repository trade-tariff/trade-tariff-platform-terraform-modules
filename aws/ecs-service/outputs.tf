output "task_execution_role_arn" {
  description = "Task execution role ARN."
  value       = aws_iam_role.execution_role.arn
}

output "task_role_arn" {
  description = "Task role ARN."
  value       = aws_iam_role.task_role.arn
}
