# ==============================================================================
# 1. METADATA & ENVIRONMENT INFO
# ==============================================================================
variable "project_name" {
  type        = string
  description = "The prefix string for naming resources (e.g., vyaparflow)"
}

variable "environment" {
  type        = string
  description = "The target deployment stage (e.g., dev, test, prod)"
}

variable "aws_region" {
  type        = string
  description = "The AWS region where CloudWatch logging streams deploy"
}

# ==============================================================================
# 2. NETWORKING PIPELINES
# ==============================================================================
variable "vpc_id" {
  type        = string
  description = "The ID of the custom VPC network hosting the security groups"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The public subnets assigned to the Fargate execution network profile"
}

# ==============================================================================
# 3. COMPUTATION SPECS & CONTAINER IMAGES
# ==============================================================================
variable "cpu_size" {
  type        = string
  description = "Fargate hardware engine processing unit allocation (e.g., 256, 512, 1024)"
}

variable "memory_size" {
  type        = string
  description = "Fargate hardware engine memory matrix block allocation (e.g., 512, 1024, 2048)"
}

variable "nginx_image_url" {
  type        = string
  description = "The image URL for your edge reverse proxy routing layer container"
}

variable "ecr_repository_url" {
  type        = string
  description = "The ECR registry path tracking your custom Spring Boot Java build image"
}

variable "health_check_url" {
  type        = string
  description = "The targeted context path URL for actuator heartbeat monitoring checks"
}

# ==============================================================================
# 4. IAM EXECUTION IDENTITY ACCESS
# ==============================================================================
variable "execution_role_arn" {
  type        = string
  description = "The system role allowing the infrastructure engine to tap log groups and pull images"
}

variable "task_role_arn" {
  type        = string
  description = "The operational role giving runtime AWS resource permissions directly to your Java code"
}

# ==============================================================================
# 5. CROSS-MODULE REFERENCE COORDINATES (Database & Security Hooks)
# ==============================================================================
variable "db_endpoint" {
  type        = string
  description = "The host address endpoint connecting back to your database layer instance"
}

variable "db_password_param_arn" {
  type        = string
  description = "The SSM location parameter path string for the encrypted master DB password"
}

variable "jwt_access_param_arn" {
  type        = string
  description = "The SSM location parameter path string for your secure login token signer key"
}

variable "jwt_refresh_param_arn" {
  type        = string
  description = "The SSM location parameter path string for your long-term login session token key"
  default     = null
}

# ==============================================================================
# 6. DYNAMIC BULK MATRIX STORAGE CONTAINERS
# ==============================================================================
variable "app_environment_variables" {
  type        = map(string)
  description = "The plain text environment map for non-sensitive configurations inside Spring Boot"
  default     = {}
}

variable "dynamic_secret_arns" {
  type        = map(string)
  description = "The parameter path string collection tracking custom third-party secrets integrations"
  default     = {}
}