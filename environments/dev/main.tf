module "networking" {
  source             = "../../modules/networking"
  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
 availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
}

module "ecr"{
    source = "../../modules/ecr"
    project_name= var.project_name
    environment= var.environment
}

module "iam" {
    source = "../../modules/iam"
    project_name=var.project_name
    environment=var.environment
    github_username = var.github_username
    github_repo_name=var.github_repo_name

}

module "security" {
  source             = "../../modules/security"
  project_name       = var.project_name
  environment        = var.environment
  enable_dual_tokens = var.enable_dual_tokens # ◄ Maps down from root variables
}

module "database" {
  source       = "../../modules/database"
  project_name = var.project_name
  environment  = var.environment
  
  # ── FIX: Fetching values directly from module outputs, NOT root variables! ──
  vpc_id       = module.networking.vpc_id
  subnet_ids   = module.networking.public_subnet_ids # ◄ Using public subnets since private ones don't exist!
  ecs_sg_id    = module.ecs.ecs_sg_id
  
  db_instance_class = var.db_instance_class
  db_allocated_storage =var.db_allocated_storage
  db_password  = module.security.db_password_plain 
}

module "ecs" {
  source       = "../../modules/ecs"
  project_name = var.project_name
  environment  = var.environment
  
  # Fetches VPC ID directly from the networking module outputs
  vpc_id       = module.networking.vpc_id

  app_environment_variables = var.app_environment_variables
  
  # ── THE SECURE LOCATION CREDENTIAL PIPELINE ──
  db_endpoint           = module.database.db_endpoint
  db_password_param_arn = module.security.db_password_param_arn
  
  # ── FIX: Map these to match your new ecs variables template ──
  jwt_access_param_arn  = module.security.jwt_access_param_arn
  jwt_refresh_param_arn = module.security.jwt_refresh_param_arn
  dynamic_secret_arns   = module.security.dynamic_secret_arns

  # Network topology mapping
  public_subnet_ids  = module.networking.public_subnet_ids
  
  # Identity execution roles
  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn
  
  # Deployment image targets and sizing profiles
  ecr_repository_url = module.ecr.repository_url
  nginx_image_url    = var.nginx_image_url
  health_check_url   = var.health_check_url
  aws_region         = var.aws_region
  cpu_size           = var.cpu_size
  memory_size        = var.memory_size
}