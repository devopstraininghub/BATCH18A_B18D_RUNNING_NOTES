variable "ami_id" {
  description = "The AMI ID to use for the instance"
  type        = string
 # default     = "ami-0d97d7f07b25dd693"
}

variable "instance_type" {
  description = "The type of instance to create"
  type        = string
  #default     = "t3.micro"
}

variable "key_name" {
  description = "The name of the key pair to use for the instance"
  type        = string
  #default     = "madhukey"
}

variable "tag_server" {
  description = "tag of the server"
  type = string
}