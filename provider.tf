# Create ENV VARs: [TF_BACKEND_BUCKET, TF_BACKEND_REGION, TF_BACKEND_KEY]

# Init Terraform: 
# terraform init \
# -backend-config="bucket=${TF_BACKEND_BUCKET}" \
# -backend-config="region=${TF_BACKEND_REGION}" \
# -backend-config="key=${TF_BACKEND_KEY}"

terraform {
  backend "s3" {
    use_lockfile = true
    encrypt      = true
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

