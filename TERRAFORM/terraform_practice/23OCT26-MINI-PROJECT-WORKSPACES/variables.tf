

variable "vpc_cidr" {
 # default = "10.81.0.0/16"
  description = "CIDR block for the VPC"
  type = string
}

variable "subnet_cidr" {
  #default = "10.81.3.0/24"
  description = "CIDR block for the subnet"
  type = string
}


variable "eni_pvt_ip" {
  # default = ["10.81.3.33"]
  description = "Private IP for the network interface"
  type = list(string)
}


variable "instance_type" {
  #default = "t2.micro"
  description = "EC2 instance type"
  type = string
}

variable "ami_id" {
#  default = "ami-0ed59cbb87dfa8dba" # Replace with a valid AMI ID for your region
  description = "AMI ID for the EC2 instance"
  type = string
}

variable "key_name" {
 ## default = "mckey" # Replace with your key pair name
  description = "Key pair name for the EC2 instance"
    type = string

}

variable "instance_count" {
  # default = 1
  description = "Number of EC2 instances to deploy"
  type = number
}

variable "tag_server_name" {
  
 # default = "prod-facebook-srv"
  description = "Tag name for the EC2 instance"
  type = string
}