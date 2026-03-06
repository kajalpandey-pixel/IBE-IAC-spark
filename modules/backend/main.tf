data "aws_elastic_beanstalk_solution_stack" "java_stack" {
  most_recent = true
  name_regex  = ".*Corretto 17.*"
}

resource "aws_elastic_beanstalk_application" "backend_app" {
  name        = "booking-engine-backend-spark"
  description = "Spring Boot backend"
}

resource "aws_elastic_beanstalk_environment" "backend_env" {

  name        = "booking-engine-env-spark"
  application = aws_elastic_beanstalk_application.backend_app.name

  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.java_stack.name
  tier                = "WebServer"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.public_subnets)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", var.public_subnets)
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "aws-elasticbeanstalk-service-role"
  }

}