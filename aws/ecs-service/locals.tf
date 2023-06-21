locals {
  account_id     = data.aws_caller_identity.current.account_id
  container_port = 80
  cluster_arn    = data.aws_ecs_cluster.this.arn

  default_environment_config = [
    {
      name  = "PORT"
      value = tostring(local.container_port)
    }
  ]

  default_secrets_config = [{}]

  merged_secrets     = distinct(concat(var.service_secrets_config, local.default_secrets_config))
  merged_environment = distinct(concat(var.service_environment_config, local.default_environment_config, ))

  tags = merge(
    {
      Terraform   = "true"
      Environment = title(var.environment)
    },
    var.tags,
  )

}

data "aws_caller_identity" "current" {}

data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}
