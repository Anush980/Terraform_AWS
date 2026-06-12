# ==============================================================================
# 1. BASE SYSTEM GLOBAL METADATA
# ==============================================================================
variable "project_name" {
  type        = string
  description = "The prefix name used for identifying application assets (e.g., vyaparflow)"
}

variable "environment" {
  type        = string
  description = "The targeted runtime stage profile (e.g., dev, test, prod)"
}

variable "aws_region" {
  type        = string
  description = "The target AWS geographical hosting region region code"
}

variable "health_check_url" {
  type        = string
  description = "The actuator check target endpoint used to evaluate Spring Boot container health"
  default     = "http://localhost:8080/actuator/health"
}

# ==============================================================================
# 2. NETWORKING TOPOLOGY INPUTS
# ==============================================================================
variable "vpc_cidr" {
  type        = string
  description = "The master private network IP layout block segment for the custom VPC allocation"
}

variable "availability_zones" {
  type        = list(string)
  description = "The explicit data centers used to handle multi-zone routing layouts"
}

variable "public_subnets" {
  type        = list(string)
  description = "The sub-allocation IP blocks tracking public interface subnet zones"
}

# ==============================================================================
# 3. IDENTITY ACCESS & CI/CD PIPELINE CONFIGURATIONS
# ==============================================================================
variable "github_username" {
  type        = string
  description = "The official GitHub organisation handle or user profile hosting the source repo"
}

variable "github_repo_name" {
  type        = string
  description = "The precise targeted repository identifier target for configuring trust paths"
}

# ==============================================================================
# 4. COMPUTE DIMENSIONAL PROFILES
# ==============================================================================
variable "cpu_size" {
  type        = string
  description = "The Fargate engine resource processing core metric layout value"
}

variable "memory_size" {
  type        = string
  description = "The Fargate engine runtime memory partition size tracking limits"
}

variable "nginx_image_url" {
  type        = string
  description = "The docker target lookup URL matching your frontend routing container proxy"
  default     = "nginx:alpine"
}


# ==============================================================================
# 5. DYNAMIC MAPS & INTEGRATION ARCHITECTURE CONTROLS
# ==============================================================================
variable "enable_dual_tokens" {
  type        = bool
  description = "A configuration switch flag to dictate if secondary refresh tokens are provisioned"
  default     = false
}

variable "app_environment_variables" {
  type        = map(string)
  description = "A plain text mapping structure for plain text environmental setups in Spring Boot"
  default     = {}
}

variable "third_party_secrets" {
  type = map(object({
    enabled     = bool
    value       = string
    description = string
  }))
  description = "The central configuration map tracker handling customized external integrations"
  default     = {}
}

##database
variable "db_instance_class" {
     type =string
     description = "database intance class tier"
     default= "db.t4g.micro"
     }

variable "db_allocated_storage"{
     type=number
     description = "total storage"
     default= 20
}