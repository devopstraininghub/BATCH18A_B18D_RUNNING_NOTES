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
  for_each = var.environments

  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true

  tags = {
    Name        = "mindcircuit-${each.value}"
    Environment = each.value
    ManagedBy   = "Terraform"
  }
}

output "instance_ids" {
  description = "EC2 instance IDs by environment"
  value = {
    for environment, instance in aws_instance.web :
    environment => instance.id
  }
}
