


provider "aws" {
  region = "us-east-1"

}


resource "aws_instance" "prod" {
  # (resource arguments)

  ami = "ami-073f45061d35c86f0"
 # instance_type = "t3.micro"

  tags = {
    Name = "Prodcution-Server"
  }

}



resource "aws_s3_bucket" "prodbucket" {

    bucket = "prod-mc-b18-1243"

    tags = {
      Name = "MC-bucket"
    }
  
}