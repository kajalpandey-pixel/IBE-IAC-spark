resource "aws_db_instance" "main" {
  identifier = "${var.project}-${var.environment}-rds"

  engine         = "postgres"
  engine_version = "17.6"
  instance_class = var.rds_instance_class  # db.t3.micro for free tier

  allocated_storage     = var.allocated_storage  
  max_allocated_storage = 0                       # disable autoscaling (free tier)
  storage_type          = "gp2"
  storage_encrypted     = false                   # encryption not available on free tier

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password  # passed in via tfvars — never hardcode

  db_subnet_group_name   = var.db_subnet_group_name  # from VPC module output
  vpc_security_group_ids = [var.rds_sg_id]           # from security-groups module output
  publicly_accessible    = false                      # private subnet only
  multi_az               = false                      # single-AZ — free tier

  backup_retention_period = 1        
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"
  skip_final_snapshot     = true     

  monitoring_interval = 0            # disable enhanced monitoring 

  deletion_protection       = false  # allow destroy for demo
  auto_minor_version_upgrade = true

  tags = { Name = "${var.project}-${var.environment}-rds" }
}