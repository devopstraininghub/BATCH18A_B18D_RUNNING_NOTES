

provider "aws" {
  region = "us-east-1"
}


variable "instances" {
  description = "Map of environment names to instances"
  type = map(string)

  default = {
    dev = "t3.micro"
    prod = "t3.small"
  }
  
}


variable "ami_id" {
    default = "ami-0ed59cbb87dfa8dba"
  
}


resource "aws_instance" "server" {

  for_each = var.instances
  ami = var.ami_id

  instance_type = each.value

  tags = {
    Name = each.key
  }
  
}


output "ec2details" {
 value = {

 for env, instance in aws_instance.server :
   env => {
      id   = instance.id
      ami  = instance.ami
      type = instance.instance_type
      name = instance.tags["Name"]
      pubip = instance.public_ip


   }


 }

}