# ==============================================================================
# 1. ALB SECURITY GROUP — Controls who can talk to the load balancer
# ==============================================================================
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Internet-facing firewall for the ${var.project_name} Application Load Balancer"
  vpc_id      = var.vpc_id

  # Allow inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Public HTTP access"
  }

  # Allow inbound HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Public HTTPS access"
  }

  # Allow all outbound (to reach ECS containers)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Unrestricted outbound to reach ECS targets"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  }
}

# ==============================================================================
# 2. THE APPLICATION LOAD BALANCER
# ==============================================================================
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false          # Internet-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  # Protects against accidental deletion in production
  enable_deletion_protection = var.enable_deletion_protection

  # Access logs (optional — enable by passing a valid S3 bucket name)
  dynamic "access_logs" {
    for_each = var.access_logs_bucket != "" ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = "${var.project_name}-${var.environment}"
      enabled = true
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}

# ==============================================================================
# 3. TARGET GROUP — Points at Spring Boot containers on port 8080
# ==============================================================================
resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"  # Required for ECS Fargate (awsvpc network mode)

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }

  # Allow connections to drain before deregistering (graceful deploys)
  deregistration_delay = 30

  tags = {
    Name = "${var.project_name}-${var.environment}-tg"
  }
}

# ==============================================================================
# 4. HTTP LISTENER — Port 80 → Redirect to HTTPS (if cert provided) or forward
# ==============================================================================
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    # If an ACM cert ARN is provided, redirect HTTP → HTTPS
    # Otherwise, forward directly to the target group
    type = var.certificate_arn != "" ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.certificate_arn != "" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.certificate_arn == "" ? [1] : []
      content {
        target_group {
          arn = aws_lb_target_group.app.arn
        }
      }
    }
  }
}

# ==============================================================================
# 5. HTTPS LISTENER — Port 443 → Forward to target group (only if cert provided)
# ==============================================================================
resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"  # Modern TLS policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
