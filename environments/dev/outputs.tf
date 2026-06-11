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