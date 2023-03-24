locals {
  environment = "development"
}

resource "random_string" "variable" {
  length  = 16
  special = true
}

resource "random_id" "large_variable" {
  byte_length = 8192
}

module "parameters" {
  source = "../"

  create_kms_key = true
  parameters = [
    {
      name  = "/${local.environment}/frontend/FRONTEND_VAR"
      value = random_string.variable.result
    },
    {
      name  = "/${local.environment}/BIG_KEY"
      value = random_id.large_variable.dec
      tier  = "Advanced"
    }
  ]
}
