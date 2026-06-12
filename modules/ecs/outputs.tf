output "cluster_name" {
  value       = aws_ecs_cluster.main.name
  description = "The name of the active ECS compute cluster"
}

output "service_name" {
  value       = aws_ecs_service.main.name
  description = "The name of the long-running ECS manager service"
}
output "ecs_sg_id" {
  value       = aws_security_group.ecs_sg.id
  description = "The ID of the custom container firewall passed to the database layout"
}