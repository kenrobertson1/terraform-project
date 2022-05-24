provider "aws" {
  region     = "eu-west-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

terraform {
  backend "s3" {
    bucket = "terraform-ken"
    key    = "path/to/my/key"
    region = "eu-west-2"
  }
}

resource "aws_ecr_repository" "foo" {
  name                 = "bar"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}