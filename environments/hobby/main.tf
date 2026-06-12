module "networking" {
  source             = "../../modules/networking"
  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
}

module "ecr" {
  source       = "../../modules/ecr"
  project_name = var.project_name
  environment  = var.environment
}

module "iam" {
  source           = "../../modules/iam"
  project_name     = var.project_name
  environment      = var.environment
  github_username  = var.github_username
  github_repo_name = var.github_repo_name
}

module "security" {
  source              = "../../modules/security"
  project_name        = var.project_name
  environment         = var.environment
  enable_dual_tokens  = false
  third_party_secrets = {}
}

module "database" {
  source       = "../../modules/database"
  project_name = var.project_name
  environment  = var.environment

  vpc_id               = module.networking.vpc_id
  subnet_ids           = module.networking.public_subnet_ids
  ecs_sg_id            = module.ecs.ecs_sg_id
  db_instance_class    = "db.t4g.micro"
  db_allocated_storage = 20
  db_password          = module.security.db_password_plain
}

module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  health_check_path = "/actuator/health"
  certificate_arn   = ""

  enable_deletion_protection = false
}

module "ecs" {
  source       = "../../modules/ecs"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids

  alb_sg_id        = module.alb.alb_sg_id
  target_group_arn = module.alb.target_group_arn

  cpu_size           = "256"
  memory_size        = "512"
  desired_count      = 1
  ecr_repository_url = module.ecr.repository_url

  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn

  db_endpoint           = module.database.db_endpoint
  db_password_param_arn = module.security.db_password_param_arn
  jwt_access_param_arn  = module.security.jwt_access_param_arn
  jwt_refresh_param_arn = module.security.jwt_refresh_param_arn
  dynamic_secret_arns   = module.security.dynamic_secret_arns
}
