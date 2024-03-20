output "user_pool_arn" {
  value = aws_cognito_user_pool.this.arn
}

output "user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "client_id" {
  value = aws_cognito_user_pool_client.this[0].id
}

output "domain" {
  value = var.domain_certificate_arn != null ? var.domain : "${aws_cognito_user_pool.this.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
}

output "cloudfront_distribution_arn" {
  value = aws_cognito_user_pool_domain.this[0].cloudfront_distribution_arn
}

output "cloudfront_distribution_zone_id" {
  value = aws_cognito_user_pool_domain.this[0].cloudfront_distribution_zone_id
}
