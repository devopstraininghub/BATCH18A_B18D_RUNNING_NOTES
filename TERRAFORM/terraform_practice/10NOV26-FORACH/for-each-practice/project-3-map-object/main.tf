
provider "aws" {
  region = "us-east-1"
}


variable "ami_id" {
  description = "AMI value for ec2 instance"
  type = string
  default = "ami-0ed59cbb87dfa8dba"
}

variable "instances" {
    description = "Server configuration based on environments"
    type = map(object({
      instance_type = string
    }))
  
    default = {
      dev_server = { instance_type ="t3.micro"  }
      prod_server = { instance_type ="t3.small"  } 
      pre_prod_server = { instance_type ="t3.small"  }    
      
    }

}

#each.key each.value 

resource "aws_instance" "server" {
  for_each = var.instances
  ami = var.ami_id
  instance_type = each.value.instance_type

  tags = {
    Name = each.key
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