#base varibles
variable "project_name" {
  description = "Project name goes here "
  type        = string
}

variable "aws_region" {
  description = "Aws region about just here"
  type        = string
}
variable "environment" {
  description = "Which environment like dev , test or prod"
  type        = string
}

#networking variables
variable "vpc_cidr" {
  description = "Vpc Cidr like 10.0.0.0/16 for many ips and 24 for 256 ips ig"
  type        = string
}
variable "availability_zones" {
  description = "Availability zones "
  type        = list(string)
}
variable "public_subnets" {
  description = "list of cidr blocks"
  type        = list(string)
}
