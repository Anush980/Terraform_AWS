variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "prod"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of AZs (minimum 2 for ALB)"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnet CIDR blocks"
}

variable "github_username" {
  type        = string
  description = "GitHub username or org"
}

variable "github_repo_name" {
  type        = string
  description = "GitHub repository name"
}

variable "cpu_size" {
  type        = string
  description = "Fargate CPU units"
  default     = "1024"
}

variable "memory_size" {
  type        = string
  description = "Fargate memory in MB"
  default     = "2048"
}

variable "desired_count" {
  type        = number
  description = "Number of ECS task replicas"
  default     = 2
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  type        = number
  description = "Initial RDS storage in GiB"
  default     = 50
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for HTTPS (strongly recommended for prod)"
  default     = ""
}

variable "health_check_path" {
  type        = string
  description = "ALB health check path"
  default     = "/actuator/health"
}

variable "health_check_url" {
  type        = string
  description = "Container-level health check URL"
  default     = "http://localhost:8080/actuator/health"
}

variable "access_logs_bucket" {
  type        = string
  description = "S3 bucket name for ALB access logs"
  default     = ""
}

variable "enable_dual_tokens" {
  type        = bool
  description = "Create JWT refresh token secret"
  default     = true
}

variable "third_party_secrets" {
  type = map(object({
    enabled     = bool
    value       = string
    description = string
  }))
  description = "External API secrets"
  default     = {}
}

variable "app_environment_variables" {
  type        = map(string)
  description = "Plain-text env vars for Spring Boot"
  default     = {}
}
