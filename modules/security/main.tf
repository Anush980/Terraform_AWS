# ==============================================================================
# 1. ACCESS TOKEN CONFIGURATION (Always Created)
# ==============================================================================
resource "random_id" "jwt_access_secret" {
  byte_length = 32 
}

resource "aws_ssm_parameter" "jwt_access_ssm" {
  name        = "/${var.project_name}/${var.environment}/jwt/access_secret"
  description = "Master Access Token signing key for ${var.project_name}"
  type        = "SecureString"
  value       = random_id.jwt_access_secret.hex
}

# ==============================================================================
# 2. REFRESH TOKEN CONFIGURATION (Conditionally Created)
# ==============================================================================
resource "random_id" "jwt_refresh_secret" {
  # If enable_dual_tokens is true -> count is 1. If false -> count is 0.
  count       = var.enable_dual_tokens ? 1 : 0
  byte_length = 32 
}

resource "aws_ssm_parameter" "jwt_refresh_ssm" {
  count       = var.enable_dual_tokens ? 1 : 0
  name        = "/${var.project_name}/${var.environment}/jwt/refresh_secret"
  description = "Long-lived Refresh Token signing key for ${var.project_name}"
  type        = "SecureString"
  value       = random_id.jwt_refresh_secret[0].hex # Must reference index [0] when using count!
}

# ==============================================================================
# 3. DATABASE PASSWORD GENERATION (Always Created)
# ==============================================================================
resource "random_password" "db_pass" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "db_password_ssm" {
  name        = "/${var.project_name}/${var.environment}/database/password"
  description = "Auto-generated master database password for ${var.project_name}"
  type        = "SecureString"
  value       = random_password.db_pass.result
}

resource "aws_ssm_parameter" "dynamic_secrets" {
  # Filter the map: ONLY run loops for keys where 'enabled == true'
  for_each = { for key, secret in var.third_party_secrets : key => secret if secret.enabled }

  # Automatically creates a clean, uniform URL directory structure!
  name        = "/${var.project_name}/${var.environment}/api/${each.key}"
  description = each.value.description
  type        = "SecureString"
  value       = each.value.value
}