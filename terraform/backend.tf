terraform {
  backend "s3" {
    bucket = "terraform-docker-state-bucket" 
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}