provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket = "kens-terraform"
    key    = "path/to/my/key"
    region = "eu-west-2"
  }
}

resource "aws_s3_bucket" "docker_bucket" {
  bucket = "kendockerapp"
  acl    = "private"
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

resource "aws_iam_instance_profile" "ken_app_ec2_instance_profile" {
  name = "ken-task-listing-app-ec2-instance-profile"
  role = aws_iam_role.ken_app_ec2_role.name
}

resource "aws_iam_policy_attachment" "ken_app_ec2_worker_policy" {
  name       = "ken-elastic-beanstalk-ec2-worker-policy"
  roles      = ["${aws_iam_role.ken_app_ec2_role.id}"]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_policy_attachment" "ken_app_ec2_web_policy" {
  name       = "ken-elastic-beanstalk-ec2-web-policy"
  roles      = ["${aws_iam_role.ken_app_ec2_role.id}"]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_policy_attachment" "ken_app_ec2_container_policy" {
  name       = "ken-elastic-beanstalk-ec2-container-policy"
  roles      = ["${aws_iam_role.ken_app_ec2_role.id}"]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "ken_app_role_policy_attachment" {
  role       = aws_iam_role.ken_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role" "ken_app_ec2_role" {
  name = "ken-task-listing-app-ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })

}

resource "aws_elastic_beanstalk_environment" "ken_app_environment" {
  name                = "ken-task-listing-app-environment"
  application         = aws_elastic_beanstalk_application.ken_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.4.16 running Docker"

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

resource "aws_db_instance" "ken_rds_app" {
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "13.3"
  instance_class       = "db.m6g.large"
  identifier           = "ken-app-prod"
  name                 = "ken-app-database-name"
  username             = "root"
  password             = "password"
  skip_final_snapshot  = true
  publicly_accessible = true
}