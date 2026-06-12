output "app_url" {
  value       = "https://${module.alb.alb_dns_name}"
  description = "Public URL for the production environment"
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "ALB DNS name — set your domain CNAME to this"
}

output "alb_zone_id" {
  value       = module.alb.alb_zone_id
  description = "ALB hosted zone ID — needed for Route 53 alias records"
}

output "vpc_id" {
  value       = module.networking.vpc_id
}

output "ecs_cluster_name" {
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  value       = module.ecs.service_name
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "Push Docker images here"
}

output "database_endpoint" {
  value       = module.database.db_endpoint
  description = "PostgreSQL host (internal)"
}

output "github_deploy_role_arn" {
  value       = module.iam.github_deploy_role_arn
  description = "Role ARN for GitHub Actions"
}

output "provisioned_dynamic_secrets_matrix" {
  value       = module.security.dynamic_secret_arns
}
