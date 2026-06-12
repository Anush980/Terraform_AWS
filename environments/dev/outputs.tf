output "vpc_id" {
  # Change from aws_vpc.main.id to module.networking.vpc_id
  value       = module.networking.vpc_id
  description = "The ID of the main VPC"
}

output "public_subnet_ids" {
  # Change from aws_subnet.public[*].id to module.networking.public_subnet_ids
  value       = module.networking.public_subnet_ids
  description = "The list of IDs belonging to the public subnets"
}

output "repository_url"{
    value = module.ecr.repository_url
    description= "ecr repository url"
}

output "github_deploy_role_arn" {
  value       = module.iam.github_deploy_role_arn
  description = "OIDC Role ARN for GitHub Actions workflows"
}

output "dev_ecs_cluster_name" {
  value       = module.ecs.cluster_name
  description = "Active Dev Compute Cluster Name"
}

output "dev_ecs_service_name" {
  value       = module.ecs.service_name
  description = "Active Dev ECS Service Name"
}

# This lets you quickly double check which firewall is protecting your app
output "dev_ecs_security_group_id" {
  value       = module.ecs.security_group_id
  description = "Dedicated Application Security Group ID"
}