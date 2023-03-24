locals {
  tags = merge(
    {
      Terraform = true
    },
    var.tags
  )
}

resource "aws_kms_key" "this" {
  count               = var.create_kms_key == true ? 1 : 0
  key_usage           = "ENCRYPT_DECRYPT"
  enable_key_rotation = true
  tags                = local.tags
}

resource "aws_ssm_parameter" "this" {
  for_each  = var.parameters
  data_type = "text"
  name      = each.value.name
  value     = each.value.value
  tier      = try(each.value.tier, "Standard")
  type      = "SecureString"
  key_id    = var.create_kms_key == true ? aws_kms_key.this.key_id : null
  tags      = local.tags
}
