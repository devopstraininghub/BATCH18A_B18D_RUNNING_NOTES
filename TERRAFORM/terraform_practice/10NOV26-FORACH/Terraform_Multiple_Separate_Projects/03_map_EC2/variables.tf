variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Your custom AMI ID in the selected region"
  type        = string
}

variable "instances" {
  description = "Map of environment names to EC2 instance types"
  type        = map(string)
  default = {
    dev  = "t3.micro"
    qa   = "t3.micro"
    prod = "t3.small"
  }
}
