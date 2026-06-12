output "alb_arn" {
  value       = aws_lb.main.arn
  description = "The ARN of the Application Load Balancer"
}

output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The public DNS name of the ALB — use this to access your app or set a CNAME"
}

output "alb_zone_id" {
  value       = aws_lb.main.zone_id
  description = "The Route 53 hosted zone ID for the ALB — needed for alias DNS records"
}

output "target_group_arn" {
  value       = aws_lb_target_group.app.arn
  description = "The ARN of the target group — passed to ECS service for registration"
}

output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "The security group ID of the ALB — ECS SG should allow inbound from this"
}

output "http_listener_arn" {
  value       = aws_lb_listener.http.arn
  description = "ARN of the HTTP listener (port 80)"
}

output "https_listener_arn" {
  value       = length(aws_lb_listener.https) > 0 ? aws_lb_listener.https[0].arn : null
  description = "ARN of the HTTPS listener (port 443) — null if no certificate provided"
}
