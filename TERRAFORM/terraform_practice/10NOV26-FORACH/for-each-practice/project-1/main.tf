

provider "aws" {
  region = "us-east-1"
}

# set(string)
# map(string)
# map(object)
variable "instance_type" {
  description = "type of instance"
  type = string
  default = "t3.micro"
}

variable "ami_id" {
  description = "AMI value for ec2 instance"
  type = string
  default = "ami-0ed59cbb87dfa8dba"
}

variable "environments" {

    description = "Environemnt names"
    type = set(string)
    default = [ "dev", "qa" , "prod" ]  
}

## each.key each.value 

resource "aws_instance" "server" {
  
  for_each = var.environments
  ami = var.ami_id
  instance_type =  var.instance_type
 # count = 3

  tags = {
    Name = each.value
  }

}


output "serverdetails" {
 value = {
  for env, instance in aws_instance.server : 

  env => {
   id = instance.id 
   ami = instance.ami 
   name = instance.tags["Name"]
   type = instance.instance_type

  }

 }
}