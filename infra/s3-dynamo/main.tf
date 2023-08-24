terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.5"
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "laravel_terraform_state_bucket" {
  bucket = "laravel-tfstate"

  tags = {
    Name = "Laravel terraform State Bucket"
  }
}

resource "aws_s3_bucket_acl" "laravel_bucket_acl" {
  bucket = aws_s3_bucket.laravel_terraform_state_bucket.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.laravel_s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "laravel_s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.laravel_terraform_state_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_dynamodb_table" "laravel_terraform_lock_table" {
  name         = "laravel-terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
