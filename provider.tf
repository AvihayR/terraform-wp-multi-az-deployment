terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
  }
}


provider "aws" {
  region = "eu-central-1"
  # region = lookup(var.region, terraform.workspace) 
}

