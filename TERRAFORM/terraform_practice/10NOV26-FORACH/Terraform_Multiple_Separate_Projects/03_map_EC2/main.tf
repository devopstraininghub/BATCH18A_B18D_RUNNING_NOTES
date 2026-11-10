terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "web" {
  for_each = var.instances

  ami                         = var.ami_id
  instance_type               = each.value
  associate_public_ip_address = true

  tags = {
    Name        = "mindcircuit-${each.key}"
    Environment = each.key
    ManagedBy   = "Terraform"
  }
}

output "ec2_details" {
  description = "EC2 instance details by map key"

  value = {
    for environment, instance in aws_instance.web : environment => {
      instance_id = instance.id
      instance_type = instance.instance_type
      public_ip   = instance.public_ip
    }
  }
}
