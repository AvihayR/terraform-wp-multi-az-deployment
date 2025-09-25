terraform {
    backend "s3" {
    bucket         = "arize-tf-state-management"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    use_lockfile   = true
    encrypt        = true
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
  }
}


provider "aws" {
  region = var.region
}

