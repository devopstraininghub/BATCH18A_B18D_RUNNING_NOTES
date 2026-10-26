

variable "ami_id" {
  
  description = "Ami id for instance"

}

variable "instance_type" {
   description = "the instance family type "
   
}


variable "key_name" {
   description = "Key pair name to connect the instance"
}

variable "instance_count" {
  description = "No of instances"
}


variable "tag_server_name" {
  description = "Tag name of the ec2 instance"
}