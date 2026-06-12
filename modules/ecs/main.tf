# ==============================================================================
# 1. ECS SECURITY GROUP — Only accepts traffic from the ALB
# ==============================================================================
resource "aws_security_group" "ecs_sg" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "Firewall for ${var.project_name} ECS tasks accepts traffic from ALB only"
  vpc_id      = var.vpc_id

  # Only ALB can talk to Spring Boot on 8080
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
    description     = "Allow inbound from ALB to Spring Boot"
  }

  # Full outbound — needed to reach RDS, SSM, ECR, CloudWatch
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-sg"
  }
}

# ==============================================================================
# 2. CLOUDWATCH LOG GROUP
# ==============================================================================
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 7
}

# ==============================================================================
# 3. ECS CLUSTER
# ==============================================================================
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  tags = {
    Name = "${var.project_name}-${var.environment}-cluster"
  }
}

# ==============================================================================
# 4. TASK DEFINITION — Single Spring Boot container, ALB handles routing
# ==============================================================================
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu_size
  memory                   = var.memory_size
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-${var.environment}-springboot"
      image     = var.ecr_repository_url
      essential = true

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f ${var.health_check_url} || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-${var.environment}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "springboot"
        }
      }

      environment = concat([
        {
          name  = "SPRING_PROFILES_ACTIVE"
          value = var.environment
        },
        {
          name  = "SPRING_DATASOURCE_URL"
          value = "jdbc:postgresql://${var.db_endpoint}/${var.project_name}_db"
        },
        {
          name  = "SPRING_DATASOURCE_USERNAME"
          value = "postgres"
        }
      ], [
        for key, value in var.app_environment_variables : {
          name  = key
          value = value
        }
      ])

      secrets = concat([
        {
          name      = "SPRING_DATASOURCE_PASSWORD"
          valueFrom = var.db_password_param_arn
        },
        {
          name      = "JWT_ACCESS_KEY"
          valueFrom = var.jwt_access_param_arn
        }
      ],
      var.jwt_refresh_param_arn != null ? [{ name = "JWT_REFRESH_KEY", valueFrom = var.jwt_refresh_param_arn }] : [],
      [for key, arn in var.dynamic_secret_arns : { name = upper(key), valueFrom = arn }]
      )
    }
  ])
}

# ==============================================================================
# 5. ECS SERVICE — Registers directly with the ALB target group
# ==============================================================================
resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.project_name}-${var.environment}-springboot"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [desired_count] # Allow auto-scaling to manage task count
  }
}
