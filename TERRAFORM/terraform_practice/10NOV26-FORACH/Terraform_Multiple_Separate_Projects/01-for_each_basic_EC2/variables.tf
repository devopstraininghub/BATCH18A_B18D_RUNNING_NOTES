variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "Your custom AMI ID in the selected region"
  type        = string
}

variable "instances" {
  description = "EC2 instance configuration by environment"
  type = map(object({
    instance_type = string
  }))
}
