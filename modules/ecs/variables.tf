# ==============================================================================
# 1. METADATA
# ==============================================================================
variable "project_name" {
  type        = string
  description = "The prefix string for naming resources"
}

variable "environment" {
  type        = string
  description = "The target deployment stage (dev, hobby, prod)"
}

variable "aws_region" {
  type        = string
  description = "AWS region for CloudWatch log streams"
}

# ==============================================================================
# 2. NETWORKING
# ==============================================================================
variable "vpc_id" {
  type        = string
  description = "VPC ID where ECS security group is deployed"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnets for Fargate task placement"
}

variable "alb_sg_id" {
  type        = string
  description = "ALB security group ID — ECS only accepts inbound traffic from this SG"
}

variable "target_group_arn" {
  type        = string
  description = "ALB target group ARN to register ECS tasks into"
}

# ==============================================================================
# 3. COMPUTE & IMAGE
# ==============================================================================
variable "cpu_size" {
  type        = string
  description = "Fargate CPU units (e.g. 256, 512, 1024)"
}

variable "memory_size" {
  type        = string
  description = "Fargate memory in MB (e.g. 512, 1024, 2048)"
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR image URL for the Spring Boot container"
}

variable "health_check_url" {
  type        = string
  description = "Health check endpoint inside the container (e.g. http://localhost:8080/actuator/health)"
  default     = "http://localhost:8080/actuator/health"
}

variable "desired_count" {
  type        = number
  description = "Number of ECS tasks to run"
  default     = 1
}

# ==============================================================================
# 4. IAM
# ==============================================================================
variable "execution_role_arn" {
  type        = string
  description = "ECS task execution role ARN (pulls images, writes logs, reads SSM)"
}

variable "task_role_arn" {
  type        = string
  description = "ECS task role ARN (runtime AWS permissions for your application)"
}

# ==============================================================================
# 5. DATABASE & SECRETS
# ==============================================================================
variable "db_endpoint" {
  type        = string
  description = "RDS PostgreSQL host endpoint"
}

variable "db_password_param_arn" {
  type        = string
  description = "SSM parameter ARN for the database password"
}

variable "jwt_access_param_arn" {
  type        = string
  description = "SSM parameter ARN for the JWT access secret"
}

variable "jwt_refresh_param_arn" {
  type        = string
  description = "SSM parameter ARN for the JWT refresh secret (null if dual tokens disabled)"
  default     = null
}

# ==============================================================================
# 6. DYNAMIC CONFIGURATION
# ==============================================================================
variable "app_environment_variables" {
  type        = map(string)
  description = "Plain-text env vars injected into the Spring Boot container"
  default     = {}
}

variable "dynamic_secret_arns" {
  type        = map(string)
  description = "Map of SSM parameter ARNs for third-party secrets"
  default     = {}
}
