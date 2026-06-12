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

module "ecs" {
  source             = "../../modules/ecs"
  project_name       = var.project_name
  aws_region = var.aws_region
  environment        = var.environment
  vpc_id             = module.networking.vpc_id 
  public_subnet_ids  = module.networking.public_subnet_ids
 # ecr_repository_url = module.ecr.repository_url
  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn
  cpu_size = var.cpu_size
  memory_size = var.memory_size
}