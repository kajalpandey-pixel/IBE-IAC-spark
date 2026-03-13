resource "aws_ecr_repository" "ibe" {
  name                 = "${var.project}-${var.environment}"
  image_tag_mutability = "MUTABLE"  # allows overwriting :latest tag

  image_scanning_configuration {
    scan_on_push = true  # free vulnerability scan on every push
  }

  tags = { Name = "${var.project}-${var.environment}-ecr" }
}

# Keep only last 10 images — prevents storage costs from building up
resource "aws_ecr_lifecycle_policy" "ibe" {
  repository = aws_ecr_repository.ibe.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images — remove older ones"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = { type = "expire" }
      }
    ]
  })
}
