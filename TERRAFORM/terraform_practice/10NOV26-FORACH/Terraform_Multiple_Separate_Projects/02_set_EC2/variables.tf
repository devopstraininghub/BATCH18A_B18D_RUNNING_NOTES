variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "Your custom AMI ID in the selected region"
  type        = string
}

variable "instance_type" {
  description = "Instance type used for each environment"
  type        = string
  default     = "t3.micro"
}

variable "environments" {
  description = "Unique environment names"
  type        = set(string)
  default     = ["dev", "qa", "prod"]
}
