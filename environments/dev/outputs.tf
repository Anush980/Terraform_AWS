# ==============================================================================
# 1. APPLICATION ENTRY POINT
# ==============================================================================
output "app_url" {
  value       = "http://${module.alb.alb_dns_name}"
  description = "Public URL to reach your application via the ALB"
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "Raw ALB DNS name — use as a CNAME target for your custom domain"
}

# ==============================================================================
# 2. NETWORKING
# ==============================================================================
output "vpc_id" {
  value       = module.networking.vpc_id
  description = "ID of the VPC"
}

# ==============================================================================
# 3. ECS
# ==============================================================================
output "ecs_cluster_name" {
  value       = module.ecs.cluster_name
  description = "ECS cluster name"
}

output "ecs_service_name" {
  value       = module.ecs.service_name
  description = "ECS service name"
}

# ==============================================================================
# 4. ECR
# ==============================================================================
output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "Push your Docker images here for deployment"
}

# ==============================================================================
# 5. DATABASE
# ==============================================================================
output "database_endpoint" {
  value       = module.database.db_endpoint
  description = "PostgreSQL host endpoint (internal — not publicly accessible)"
}

# ==============================================================================
# 6. CI/CD
# ==============================================================================
output "github_deploy_role_arn" {
  value       = module.iam.github_deploy_role_arn
  description = "Paste this ARN into your GitHub Actions workflow as the role to assume"
}

# ==============================================================================
# 7. SECRETS REGISTRY
# ==============================================================================
output "provisioned_dynamic_secrets_matrix" {
  value       = module.security.dynamic_secret_arns
  description = "Map of all provisioned third-party SSM secret ARNs"
}
