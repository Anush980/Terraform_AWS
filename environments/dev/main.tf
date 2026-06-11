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