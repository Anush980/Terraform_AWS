output "execution_role_arn" {
  value       = aws_iam_role.ecs_task_execution_role.arn
  description = "The ARN for the ECS engine deployment agent"
}

output "task_role_arn" {
  value       = aws_iam_role.ecs_task_role.arn
  description = "The ARN for active container runtime application tasks"
}

output "github_deploy_role_arn" {
  value       = aws_iam_role.github_ci_deploy.arn
  description = "The OIDC ARN used inside GitHub Actions YAML deployment workflows"
}