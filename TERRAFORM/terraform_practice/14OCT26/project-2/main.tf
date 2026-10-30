
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "prod-fb-srv" {
  ami           = "ami-0ed59cbb87dfa8dba" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  key_name      = "madhukey"  
  count         = 1

   tags = {
    Name = "testserver" 
   }
}