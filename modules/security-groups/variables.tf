variable "project"     { type = string }
variable "environment" { type = string }
variable "vpc_id"      { type = string }
variable "vpc_cidr"    { type = string }
variable "bastion_sg_id" {
  type        = string
  description = "Security group ID of the manually created bastion host"
}