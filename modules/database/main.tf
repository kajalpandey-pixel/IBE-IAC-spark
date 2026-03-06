data "aws_secretsmanager_secret" "db_secret" {
  name = "booking-db-credentials-spark"
}

data "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_secret_version.secret_string)
}   

resource "aws_db_instance" "booking_db" {
  allocated_storage   = 20
  db_name             = "bookingdbspark"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"

  username = local.db_credentials.username
  password = local.db_credentials.password

  skip_final_snapshot = true
}