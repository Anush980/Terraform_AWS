output "app_url" {
  value       = "http://${module.alb.alb_dns_name}"
  description = "Public URL for the hobby environment"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "Push Docker images here"
}

output "github_deploy_role_arn" {
  value       = module.iam.github_deploy_role_arn
  description = "Role ARN for GitHub Actions"
}
