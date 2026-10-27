


provider "aws" {
  region = "us-east-1"
  alias  = "nv"
}

provider "aws" {
  region = "ap-south-1"
  alias  = "mum"
}

resource "aws_instance" "prodserver" {
 
  ami           = "ami-0d97d7f07b25dd693"
  instance_type = "t2.micro"
  key_name      = "mckey"
  provider      = aws.nv

  tags = {
    Name = "Aja_testserver-NorthVirginia"
  }


}

resource "aws_instance" "testserver" {
 
  ami           = "ami-022374b883d9d7931"
  instance_type = "t2.micro"
  key_name      = "ajamumbai"
  provider      = aws.mum

  tags = {
    Name = "MUM-Aja_testserver"
  }


}