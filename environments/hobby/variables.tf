variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "hobby"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
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
