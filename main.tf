
//terraform config
terraform {
  backend "s3" {
    bucket = "edrandall-dev"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.63.0"
    }
  }
}

//Use local "edr-neo4j" profile
provider "aws" {
  region  = var.region
  profile = "ed-neo4j"
}
