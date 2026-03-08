variable "project"             { type = string }
variable "environment"         { type = string }
variable "db_subnet_group_name"{ type = string }
variable "rds_sg_id"           { type = string }

variable "rds_instance_class" {
  description = "RDS instance type — db.t3.micro is free tier eligible"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage in GB — 20 GB is free tier max"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the initial database"
  type        = string
  default     = "IBE_DB"
}

variable "db_username" {
  description = "Master DB username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Master DB password — provide via tfvars or env var, never hardcode"
  type        = string
  sensitive   = true  # masked in plan/apply output
}