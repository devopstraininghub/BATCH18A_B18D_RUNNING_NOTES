

provider "aws" {
  region = "us-east-1"
}



resource "aws_instance" "server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = var.tag_server
  }
}
