output "kms_key_id" {
  description = "KMS key ID, if `var.create_kms_key` is `true`."
  value       = try(aws_kms_key.this[0].key_id, null)
}
