

provider "aws" {
  region = "us-east-1"
}

variable "ami_id" {
  description = "AMI value for ec2 instance"
  type = string
  default = "ami-0ed59cbb87dfa8dba"
}


variable "instances" {
    description = "env instance type  for servers "
    type = map(string)
    default = {
      dev = "t3.small"
      prod = "t3.micro"
      qa  = "t3.small"
    }
}

# each.key & each.value 
resource "aws_instance" "server" {

  for_each = var.instances  
  ami = var.ami_id
  instance_type = each.value

  tags = {
    Name = each.key
    Managed_by = "terraform"
  }
}

output "server_details" {
  
  value = {

    for env, instance in aws_instance.server : 
    env => {
      id = instance.id 
      ami = instance.ami
      type = instance.instance_type 
      name = instance.tags["Name"]
      pub_ip = instance.public_ip

    }
  }

}