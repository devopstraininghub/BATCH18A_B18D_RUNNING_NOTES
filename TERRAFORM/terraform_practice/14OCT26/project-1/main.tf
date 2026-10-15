

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.68.0"
    }
  }
}



# AWS Provider Configuration
provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "prod_instance" {

     ami           = "ami-004d1eaf8eaa0107d"
     instance_type = "t3.micro"
     key_name      = "mckey"
     count         = 2

     tags = {
        Name = "Prod-Instance"
  }

  }


resource "aws_s3_bucket" "prod_bucket" {

    bucket = "madhu-prod-bucket-terraform-2026"

    tags = {
    Name        = "Madhu-prod-bucket-terraform-2026"
  }

}




