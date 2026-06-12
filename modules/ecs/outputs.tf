output "cluster_name" {
  value       = aws_ecs_cluster.main.name
  description = "Name of the ECS cluster"
}

output "service_name" {
  value       = aws_ecs_service.main.name
  description = "Name of the ECS service"
}

output "ecs_sg_id" {
  value       = aws_security_group.ecs_sg.id
  description = "ECS security group ID — passed to database module to allow DB access from containers"
}
