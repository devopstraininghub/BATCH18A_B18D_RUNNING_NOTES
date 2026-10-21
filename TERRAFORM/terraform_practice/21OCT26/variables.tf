variable "ami_id" {
    description = "The AMI ID to use for the EC2 instance"
    type        = string
    default     = "ami-0c55b159cbfafe1f0" # Example AMI ID for Amazon Linux 2
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}
  
variable "key_name" {

    description = "The name of the key pair to use for the EC2 instance"
    type        = string
    default     = "my-key-pair" # Replace with your actual key pair name
  
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

