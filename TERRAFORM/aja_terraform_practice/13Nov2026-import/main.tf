
provider "aws" {
  region = "us-east-1"
}

variable "ami" {
  description = "AMI id of the instance "
  type = "string"
  default = "ami-096ef200a877f36af"
}

variable "instance_type" {
  description = "Type of instance"
  type = string
  default = "t3.micro"
}

variable "instance_count" {
    description = "No of instances"
    type = number
    default = 1
  
}

variable "tagss" {
  description = "all tags of instnaces"
  type = map(string)

  default = {
    Name = "Madhu"
    Env  = "prod"
    owner = "Madhukiran"
  }
}


resource "aws_instance" "server" {
  
  ami = var.ami
  instance_type = "t2.micro"
  count = var.instance_count 
  tags = var.tagss

}



resource "aws_s3_bucket" "aja-bucket" {
     
    bucket = "aja-prod-unique"

    tags = {
      Name = "testbucket"
    }
  
}