provider "aws" {
  region  = "eu-west-2"
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