//terraform config
terraform {
  backend "s3" {
    bucket  = "edrandall-dev"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    profile = "product-na"

  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.63.0"
    }
  }
}

//Use neo4j-product-na aws profile
provider "aws" {
  region  = var.region
  profile = "product-na"
}
