output "db_password_plain" {
  value     = random_password.db_pass.result
  sensitive = true
}

output "db_password_param_arn" {
  value     = aws_ssm_parameter.db_password_ssm.arn
}

output "jwt_access_param_arn" {
  value     = aws_ssm_parameter.jwt_access_ssm.arn
}

# Passes the string ARN if enabled, otherwise gracefully outputs null
output "jwt_refresh_param_arn" {
  value       = one(aws_ssm_parameter.jwt_refresh_ssm[*].arn)
  description = "The ARN for the refresh token parameter, or null if disabled"
}

output "dynamic_secret_arns" {
  value = { for key, param in aws_ssm_parameter.dynamic_secrets : key => param.arn }
  description = "A map of all active third-party token paths"
}