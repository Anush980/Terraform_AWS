variable "project_name" {
  description = "Project name goes here "
  type        = string
}

variable "environment" {
  description = "Which enviroment like dev , test or prod"
  type        = string
}

variable "github_username" {
    description= "Github org or username"
    type=string
}

variable "github_repo_name" {
    description= "Github repo name"
    type=string
}