
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "test" {
  ami           = "ami-0cede6fe40e6ac719"
  instance_type = "t2.micro"
  key_name      = "mc-mumbaikey"

  tags = {
    Name = "TestInstance"
  }
}

