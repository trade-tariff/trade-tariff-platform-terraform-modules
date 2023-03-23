output "kms_key_id" {
  description = "KMS Key ID, if `var.create_kms_key` is `true`."
  value       = aws_kms_key.this.key_id
}
