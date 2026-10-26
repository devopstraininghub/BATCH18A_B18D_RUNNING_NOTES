provider "aws" {
  region = "us-east-1"
}

# create ec2 instance



resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = var.tag_server_name
  }
}