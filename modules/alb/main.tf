resource "aws_lb" "main" {
  name               = "${var.project}-${var.environment}-alb"
  internal           = false       # public-facing
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids  # ALB must be in public subnets

  # Access logs disabled for demo (saves S3 costs)
  enable_deletion_protection = false

  tags = { Name = "${var.project}-${var.environment}-alb" }
}

# ECS service registers its tasks into this target group
resource "aws_lb_target_group" "ecs" {
  name        = "${var.project}-${var.environment}-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"  # required for Fargate (tasks use ENI IPs, not instance IDs)

  health_check {
    enabled             = true
    path                = var.health_check_path  # /actuator/health
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  # Allow time for Spring Boot to start before health checks begin
  deregistration_delay = 30

  tags = { Name = "${var.project}-${var.environment}-tg" }
}

# HTTP:80 → forward to ECS target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}

resource "aws_cloudwatch_log_group" "alb" {
  name              = "/aws/alb/${var.project}-${var.environment}"
  retention_in_days = 7  # short retention for demo

  tags = { Name = "${var.project}-${var.environment}-alb-logs" }
}
