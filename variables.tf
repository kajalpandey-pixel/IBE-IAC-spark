variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "IBE-spark"
  type        = string
  default     = "ibe"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "demo"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to use (2 required — one for ECS, both for RDS subnet group)"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ) — ALB lives here"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ) — ECS + RDS live here"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "container_port" {
  description = "Port the Spring Boot app listens on inside the container"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "Fargate task CPU units (256 = 0.25 vCPU)"
  type        = number
  default     = 512  
}

variable "task_memory" {
  description = "Fargate task memory in MB"
  type        = number
  default     = 1024  # 1 GB — suitable for demo
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "container_image" {
  description = "Initial container image (placeholder until first real deploy via CI/CD)"
  type        = string
  default     = "public.ecr.aws/nginx/nginx:latest"  # placeholder — replaced by CI/CD
}

variable "health_check_path" {
  description = "ALB health check path — Spring Boot Actuator endpoint"
  type        = string
  default     = "/actuator/health"
}

variable "app_environment_vars" {
  description = "Environment variables injected into the ECS task container"
  type = list(object({
    name  = string
    value = string
  }))
}

variable "rds_instance_class" {
  description = "RDS instance — db.t3.micro is free tier eligible"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Storage in GB — 20 GB is free tier max"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "ibe"
}

variable "db_username" {
  description = "Master DB username"
  type        = string
  default     = "ibeadmin"
}

variable "db_password" {
  description = "Master DB password — set via env var TF_VAR_db_password, never in tfvars"
  type        = string
  sensitive   = true
}

variable "db_secret_arn" {
  description = "Secret Manager ARN"
  type        = string
  sensitive   = true
}
