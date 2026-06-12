# ==============================================================================
# 1. CORE IDENTITY
# ==============================================================================
variable "project_name" {
  type        = string
  description = "The prefix name used for all ALB resource identifiers"
}

variable "environment" {
  type        = string
  description = "The deployment stage (dev, hobby, prod)"
}

# ==============================================================================
# 2. NETWORKING
# ==============================================================================
variable "vpc_id" {
  type        = string
  description = "The VPC ID where the ALB and its security group are deployed"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "At least two public subnet IDs across different AZs for ALB deployment"
}

# ==============================================================================
# 3. HEALTH CHECK
# ==============================================================================
variable "health_check_path" {
  type        = string
  description = "The HTTP path the ALB uses to check container health"
  default     = "/actuator/health"
}

# ==============================================================================
# 4. HTTPS / TLS (Optional)
# ==============================================================================
variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN to enable HTTPS. Leave empty string to run HTTP-only."
  default     = ""
}

# ==============================================================================
# 5. OPTIONAL FEATURES
# ==============================================================================
variable "enable_deletion_protection" {
  type        = bool
  description = "Prevents accidental ALB deletion. Recommended true for production."
  default     = false
}

variable "access_logs_bucket" {
  type        = string
  description = "S3 bucket name for ALB access logs. Leave empty to disable."
  default     = ""
}
