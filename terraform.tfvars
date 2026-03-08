aws_region  = "ap-south-1"
project     = "ibe"
environment = "demo"

# VPC
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

task_cpu      = 512   
task_memory   = 1024  
desired_count = 1

# Spring Boot
container_port    = 8080
health_check_path = "/actuator/health"

container_image = "public.ecr.aws/nginx/nginx:latest"
db_secret_arn = "arn:aws:secretsmanager:ap-south-1:743298171118:secret:ibe/demo/db-password-bsL1iM"
# App environment variables injected into container
app_environment_vars = [
  { name = "SPRING_PROFILES_ACTIVE", value = "demo" },
  { name = "SERVER_PORT",            value = "8080" },
  { name = "SPRING_DATASOURCE_URL",      value = "jdbc:postgresql://ibe-demo-rds.c76640a8iyue.ap-south-1.rds.amazonaws.com:5432/ibe" },
  { name = "SPRING_DATASOURCE_USERNAME", value = "ibeadmin" }
]
