terraform {
  backend "s3" {
    bucket  = "cr-prodxcloud-store" 
    region  = "us-east-2"
    key     = "state/terraform.tfstate"
    encrypt = true
  }
}