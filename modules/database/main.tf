
# ── 1. CREATE THE ISOLATED DATABASE NETWORK FIREWALL ────────────────────────
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-${var.environment}-db-sg"
  description = "Strict inbound isolation vault for the ${var.project_name} database"
  vpc_id      = var.vpc_id

  # Inbound Rule: ONLY accept traffic on standard PostgreSQL port 5432 
  # coming directly from your ECS container security group!
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ecs_sg_id] # Chaining firewalls together
  }

  # Outbound Rule: Allow updates and internal syncs
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-db-sg"
  }
}

# ── 2. DB SUBNET POSITIONING GROUP ──────────────────────────────────────────
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

# ── 3. THE FREE-TIER ELIGIBLE RDS POSTGRESQL ENGINE ─────────────────────────
resource "aws_db_instance" "postgres" {
  identifier             = "${var.project_name}-${var.environment}-db"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = var.db_instance_class # AWS Free-Tier eligible burstable processor
  allocated_storage      = var.db_allocated_storage             # 20 GiB Free-Tier maximum base allocation
  storage_type      = "gp3"
  max_allocated_storage  = 100            # Automatically scales disk space up if storage hits capacity
  
  db_name                = "${var.project_name}_db"
  username               = "postgres"
  password               = var.db_password
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  
  skip_final_snapshot    = true  # Prevents deployment chains from freezing when tearing down environments
  publicly_accessible    = false # Hides the database entirely from the public internet scanner crawlers
  
  tags = {
    Name = "${var.project_name}-${var.environment}-database"
  }
}