terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket         = "booking-engine-terraform-state-spark"
    key            = "internet-booking-engine/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table-spark"
    encrypt        = true
    use_lockfile   = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "IBE-Spark"
      Environment = var.environment
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  project          = var.project
  environment      = var.environment
  vpc_cidr         = var.vpc_cidr
  azs              = var.availability_zones
  public_subnets   = var.public_subnet_cidrs
  private_subnets  = var.private_subnet_cidrs
}

module "security_groups" {
  source = "./modules/security-groups"

  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr
  bastion_sg_id = "sg-0e175fff63c799716" //passing the bastion host SG created on the console
}

module "iam" {
  source = "./modules/iam"

  project     = var.project
  environment = var.environment
  aws_region  = var.aws_region
  account_id  = data.aws_caller_identity.current.account_id
}

module "ecr" {
  source = "./modules/ecr"

  project     = var.project
  environment = var.environment
}

module "alb" {
  source = "./modules/alb"

  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  alb_sg_id          = module.security_groups.alb_sg_id
  health_check_path  = var.health_check_path
}

module "ecs" {
  source = "./modules/ecs"

  project               = var.project
  environment           = var.environment
  aws_region            = var.aws_region
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_sg_id             = module.security_groups.ecs_sg_id
  ecr_repository_url    = module.ecr.repository_url
  task_role_arn         = module.iam.ecs_task_role_arn
  execution_role_arn    = module.iam.ecs_execution_role_arn
  target_group_arn      = module.alb.target_group_arn
  container_port        = var.container_port
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  desired_count         = var.desired_count
  container_image       = var.container_image
  app_environment_vars  = var.app_environment_vars
  db_secret_arn         = var.db_secret_arn
}

module "s3" {
  source = "./modules/s3"

  project     = var.project
  environment = var.environment
}

module "rds" {
  source = "./modules/rds"

  project              = var.project
  environment          = var.environment
  db_subnet_group_name = module.vpc.rds_subnet_group_name
  rds_sg_id            = module.security_groups.rds_sg_id
  rds_instance_class   = var.rds_instance_class
  allocated_storage    = var.rds_allocated_storage
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
}

module "apigw" {
  source       = "./modules/apigw"
  project      = var.project
  environment  = var.environment
  alb_dns_name = module.alb.alb_dns_name
}

output "apigw_endpoint" {
  value = module.apigw.api_endpoint
}

data "aws_caller_identity" "current" {}
