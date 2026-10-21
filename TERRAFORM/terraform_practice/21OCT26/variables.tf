variable "ami_id" {
  description = "AWS AMI ID"
  type        = string
 # default     = "ami-0567589d25e06853e"
}

variable "instance_type" {
  description = "Type of AWS instance"
  type        = string
 # default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
#  default     = "mckey"
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  #default     = 2
}

variable "instance_env" {
  
  description = "Environment for the instance"
  type        = string
  #default     = "Lab-Instance"
}
