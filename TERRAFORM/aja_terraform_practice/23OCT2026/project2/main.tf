
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "prodserver" {
 
  ami           = "ami-0d97d7f07b25dd693"
  instance_type = "t2.micro"
  key_name      = "mckey"

  tags = {
    Name = "Nitwin_Prod_server"
  }


}


resource "aws_s3_bucket" "prod_bucket" {
    bucket = "deepak-prod-bucket-2026"

    tags = {
        Name = "Deepak_Prod_bucket"
  }
  
}