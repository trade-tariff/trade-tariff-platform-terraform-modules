locals {
  tags = merge(
    {
      Terraform = true
    },
    var.tags
  )
}

resource "aws_kms_key" "this" {
  count                    = var.create_kms_key == true ? 1 : 0
  description              = "SSM parameters key."
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  tags                     = local.tags
}

resource "aws_ssm_parameter" "this" {
  for_each = {
    for index, parameter in var.parameters :
    parameter.name => parameter
  }

  data_type = "text"
  name      = each.value.name
  value     = each.value.value
  tier      = try(each.value.tier, "Standard")
  type      = "SecureString"
  key_id    = try(var.kms_key_id, aws_kms_key.this[0].key_id)
  tags      = local.tags
}
