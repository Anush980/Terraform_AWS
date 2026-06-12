# ==============================================================================
# 1. NETWORKING EXPORTS
# ==============================================================================
output "vpc_id" {
  value       = module.networking.vpc_id
  description = "The unique tracking ID assigned to your custom VPC network infrastructure"
}

# ==============================================================================
# 2. COMPUTATION SERVICE EXPORTS
# ==============================================================================
output "ecs_cluster_name" {
  value       = module.ecs.cluster_name
  description = "The tracking name assigned to your logical ECS Fargate coordination cluster"
}

output "ecs_service_name" {
  value       = module.ecs.service_name
  description = "The management identifier tracking the active long-running app process daemon"
}

# ==============================================================================
# 3. COMPONENT DATA REPOSITORIES (ECR & RDS)
# ==============================================================================
output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "The endpoint registry path targeting your spring boot build image dropzone"
}

output "database_connection_endpoint" {
  value       = module.database.db_endpoint
  description = "The raw connection string endpoint targeting your locked down PostgreSQL cluster host"
}

# ==============================================================================
# 4. ACTIVE VAULT PARAMETER MAP LOOKUPS
# ==============================================================================
output "provisioned_dynamic_secrets_matrix" {
  value       = module.security.dynamic_secret_arns
  description = "The active map layout collecting all provisioned third party SSM location keys"
}