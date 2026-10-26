# AWS Provider Configuration
provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "prod_instance" {

     ami           = "ami-004d1eaf8eaa0107d"
     instance_type = "t3.micro"
     key_name      = "mckey"
     count         = 1

     tags = {
        Name = "test-Instance"
  }

  }