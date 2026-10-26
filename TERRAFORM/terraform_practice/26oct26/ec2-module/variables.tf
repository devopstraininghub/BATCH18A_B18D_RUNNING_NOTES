
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string

}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string

}

variable "key_name" {
  description = "The name of the key pair to use for the instance"
  type        = string

}

variable "tag_server_name" {
 # description = "The ID of the subnet to launch the instance in"
  description = "The name of the server to be tagged"
  type        = string
}