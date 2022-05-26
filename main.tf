provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket = "ken-terraform"
    key    = "path/to/my/key"
    region = "eu-west-2"
  }
}

resource "aws_ecr_repository" "ken-repo" {
  name                 = "ken-terraform-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_elastic_beanstalk_application" "ken_app" {
  name        = "ken-task-listing-app"
  description = "Task listing app"
}

resource "aws_elastic_beanstalk_environment" "ken_app_environment" {
  name                = "ken-task-listing-app-environment"
  application         = aws_elastic_beanstalk_application.ken_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.4.5 running Docker"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ken_app_ec2_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "kenkeypair"
  }
}