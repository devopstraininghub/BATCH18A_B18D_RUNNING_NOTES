
variable "ami_id" {
  
  description = "AMI of the instance "
  # default = "ami-0d97d7f07b25dd693"
  type = string

}

variable "instance_type" {

    description = "Type of the aws instance"
    # default = "t2.micro"
    type = string
}

variable "key_name" {
    description = "key name to connect to the  instance"
    default = "mckey"
    type = string
}

variable "instance_count" {
  description = "No of instances"
  # default = 1
  type = number
}

variable "tag_server_env" {
  description = "Name tag of the instance"
  # default = "AjaServer-test"
  type = string
}
