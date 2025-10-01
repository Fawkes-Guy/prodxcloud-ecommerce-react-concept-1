provider "aws" {
  region = "us-east-2" 
  # profile = "CRomero"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" 
    }
  }
}