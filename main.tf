provider "aws" {
  region = "eu-west-2"
  profile = "kens-aws"
}

terraform {
  backend "s3" {
    bucket = "ken-terraform"
    key    = "path/to/my/key"
    region = "eu-west-2"
  }
}

resource "aws_ecr_repository" "kens-repo" {
  name                 = "bar"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}