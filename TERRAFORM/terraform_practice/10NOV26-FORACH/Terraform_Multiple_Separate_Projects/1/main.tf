
provider "aws" {
  region = "us-east-1"
}

variable "environmetns" {
    description = "Environment names"
    type = set(string)
    default = [ "dev", "qa", "prod" ]
  
}

variable "instance_tyepe" {
  description = "Type of instance"
  default = "t3.micro"
}


variable "ami_id" {
    default = "ami-0ed59cbb87dfa8dba"
  
}


resource "aws_instance" "server" {
    for_each = var.environmetns
    ami = var.ami_id
    instance_type =  var.instance_tyepe

   tags = {
     "Name" = each.value
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


