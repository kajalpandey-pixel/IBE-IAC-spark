resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"  # enables CloudWatch Container Insights
  }

  tags = { Name = "${var.project}-${var.environment}-cluster" }
}

# Capacity provider — Fargate + Fargate Spot (demo uses standard)
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project}-${var.environment}"
  retention_in_days = 7  # short retention

  tags = { Name = "${var.project}-${var.environment}-ecs-logs" }
}

# Defines the container spec: image, CPU, memory, ports, env vars, logging
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"  # required for Fargate
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  task_role_arn            = var.task_role_arn        # your app's runtime permissions
  execution_role_arn       = var.execution_role_arn   # ECS agent permissions (ECR pull, logs)

  container_definitions = jsonencode([
    {
      name      = "${var.project}-${var.environment}-container"
      image     = var.container_image  # placeholder — CI/CD updates this
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      # Environment variables passed into Spring Boot
      environment = var.app_environment_vars
      secrets = [
        {
          name      = "SPRING_DATASOURCE_PASSWORD"
          valueFrom = var.db_secret_arn        # ← full ARN passed in as variable
        }
      ]

      # CloudWatch logging — streams directly, no log download needed
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      # Health check inside container (separate from ALB health check)
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/actuator/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60  # give Spring Boot 60s to start before health checks begin
      }
    }
  ])

  tags = { Name = "${var.project}-${var.environment}-task-definition" }
}

# Maintains desired_count tasks and registers them with ALB target group
resource "aws_ecs_service" "app" {
  name            = "${var.project}-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  # Rolling deployment — replace tasks one at a time (zero downtime)
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  # Allow ECS to manage task definition updates independently from Terraform
  # CI/CD will update the task definition — Terraform manages everything else
  lifecycle {
    ignore_changes = [ desired_count, task_definition]
  }

  network_configuration {
    subnets          = var.private_subnet_ids   # tasks run in private subnets
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false                    # no public IP — NAT handles outbound
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.project}-${var.environment}-container"
    container_port   = var.container_port
  }

  # Ensure ALB target group exists before service starts
  depends_on = [var.target_group_arn]

  tags = { Name = "${var.project}-${var.environment}-service" }
}
