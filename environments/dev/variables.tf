# ==============================================================================
# 1. BASE METADATA
# ==============================================================================
variable "project_name" {
  type        = string
  description = "The prefix name used for identifying all application assets"
}

variable "environment" {
  type        = string
  description = "The targeted runtime stage (dev, hobby, prod)"
}

variable "aws_region" {
  type        = string
  description = "Target AWS region code"
}

# ==============================================================================
# 2. NETWORKING
# ==============================================================================
variable "vpc_cidr" {
  type        = string
  description = "Master private network CIDR block for the VPC"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of AZs for subnet distribution (minimum 2 required for ALB)"
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDR blocks for public subnets (one per AZ)"
}

# ==============================================================================
# 3. CI/CD — GITHUB OIDC
# ==============================================================================
variable "github_username" {
  type        = string
  description = "GitHub organisation or user handle hosting the source repo"
}

variable "github_repo_name" {
  type        = string
  description = "Repository name for OIDC trust policy scoping"
}

# ==============================================================================
# 4. COMPUTE
# ==============================================================================
variable "cpu_size" {
  type        = string
  description = "Fargate CPU units (256 | 512 | 1024 | 2048 | 4096)"
}

variable "memory_size" {
  type        = string
  description = "Fargate memory in MB (must be valid for the chosen CPU)"
}

variable "desired_count" {
  type        = number
  description = "Number of ECS task replicas to run"
  default     = 1
}

# ==============================================================================
# 5. ALB
# ==============================================================================
variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for HTTPS. Leave empty string for HTTP-only."
  default     = ""
}

variable "health_check_path" {
  type        = string
  description = "Path the ALB uses to health-check Spring Boot (e.g. /actuator/health)"
  default     = "/actuator/health"
}

# ==============================================================================
# 6. APPLICATION
# ==============================================================================
variable "health_check_url" {
  type        = string
  description = "Full URL for container-level health check (used by ECS)"
  default     = "http://localhost:8080/actuator/health"
}

variable "app_environment_variables" {
  type        = map(string)
  description = "Plain-text env vars injected into the Spring Boot container"
  default     = {}
}

variable "third_party_secrets" {
  type = map(object({
    enabled     = bool
    value       = string
    description = string
  }))
  description = "External API secrets stored in SSM (e.g. Stripe, SendGrid keys)"
  default     = {}
}

# ==============================================================================
# 7. SECURITY FEATURES
# ==============================================================================
variable "enable_dual_tokens" {
  type        = bool
  description = "Create a JWT refresh token SSM secret in addition to the access token"
  default     = false
}

# ==============================================================================
# 8. DATABASE
# ==============================================================================
variable "db_instance_class" {
  type        = string
  description = "RDS instance class (e.g. db.t4g.micro)"
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  type        = number
  description = "Initial RDS storage in GiB"
  default     = 20
}
