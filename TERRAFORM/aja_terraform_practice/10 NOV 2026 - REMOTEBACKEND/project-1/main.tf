
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "prodserver" {
 
  ami           = "ami-0d97d7f07b25dd693"
  instance_type = "t2.micro"
  key_name      = "madhukey"

  tags = {
    Name = "Nitwin_Prod_server"
  }


}