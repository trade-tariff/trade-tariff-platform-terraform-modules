locals {
  account_id  = data.aws_caller_identity.current.account_id
  cluster_arn = data.aws_ecs_cluster.this.arn

  # TODO:
  # pre-populate these with things that are common between ALL applications
  default_environment_config = [{}]
  default_secrets_config     = [{}]

  merged_secrets = distinct(
    concat(
      var.service_secrets_config,
      local.default_secrets_config
    )
  )
  merged_environment = distinct(
    concat(
      var.service_environment_config,
      local.default_environment_config
    )
  )

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
