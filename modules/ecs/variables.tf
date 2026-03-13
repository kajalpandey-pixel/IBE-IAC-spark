variable "project"              { type = string }
variable "environment"          { type = string }
variable "aws_region"           { type = string }
variable "vpc_id"               { type = string }
variable "private_subnet_ids"   { type = list(string) }
variable "ecs_sg_id"            { type = string }
variable "ecr_repository_url"   { type = string }
variable "task_role_arn"        { type = string }
variable "execution_role_arn"   { type = string }
variable "target_group_arn"     { type = string }
variable "container_port"       { type = number }
variable "task_cpu"             { type = number }
variable "task_memory"          { type = number }
variable "desired_count"        { type = number }
variable "container_image"      { type = string }
variable "app_environment_vars" {
  type = list(object({ name = string, value = string }))
}
variable "db_secret_arn" {
  description = "arn:aws:secretsmanager:ap-south-1:743298171118:secret:ibe/demo/db-password-bsL1iM"
  type        = string
}
