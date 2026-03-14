output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (ALB)"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs (ECS + RDS)"
  value       = module.vpc.private_subnet_ids
}

output "alb_dns_name" {
  description = "ALB DNS name — use this to access the GraphQL endpoint during demo"
  value       = module.alb.alb_dns_name
}

output "graphql_endpoint" {
  description = "GraphQL endpoint URL"
  value       = "http://${module.alb.alb_dns_name}/graphql"
}

output "ecr_repository_url" {
  description = "ECR URL — use this in CI/CD to push Docker images"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = module.ecs.service_name
}

output "s3_frontend_bucket" {
  description = "S3 bucket name for frontend deployment"
  value       = module.s3.bucket_name
}

output "s3_frontend_website_url" {
  description = "S3 static website endpoint"
  value       = module.s3.website_url
}

output "rds_subnet_group_name" {
  description = "RDS DB subnet group name — use when manually creating RDS free tier"
  value       = module.vpc.rds_subnet_group_name
}

output "rds_security_group_id" {
  description = "Security group ID to attach to RDS — allows inbound from ECS only"
  value       = module.security_groups.rds_sg_id
}

output "ecs_task_role_arn" {
  description = "ECS Task Role ARN"
  value       = module.iam.ecs_task_role_arn
}

output "ecs_execution_role_arn" {
  description = "ECS Execution Role ARN"
  value       = module.iam.ecs_execution_role_arn
}

output "rds_endpoint" {
  description = "Full RDS endpoint for JDBC connection string"
  value       = module.rds.db_endpoint
}

output "rds_host" {
  description = "RDS hostname — set as SPRING_DATASOURCE_URL in ECS task env vars"
  value       = module.rds.db_host
}

output "jdbc_url" {
  description = "Ready-made Spring Boot JDBC URL"
  value       = "jdbc:postgresql://${module.rds.db_host}:${module.rds.db_port}/${module.rds.db_name}"
}


# outputs.tf (ROOT)

output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}

output "cognito_client_id" {
  # Change this from user_pool_client_id to match the module output name
  value = module.cognito.client_id
}

output "cognito_identity_pool_id" {
  value = module.cognito.identity_pool_id
}