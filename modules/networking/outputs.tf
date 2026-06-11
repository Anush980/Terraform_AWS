output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the main VPC container"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "The list of IDs belonging to the public subnets"
}