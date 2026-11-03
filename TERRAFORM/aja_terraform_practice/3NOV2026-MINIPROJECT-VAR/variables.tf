variable "vpc_cidr" {
  description = "CIDR block for the VPC"
 # default     = "10.81.0.0/16"
  type =   string
}


variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  # default     = "10.81.3.0/24"
  type =   string
}


variable "eni_private_ip" {
  description = "Private IP address for the ENI"
  # default     = ["10.81.3.33"]
  type =   list(string)
}


variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  # default     = "ami-0c230065b91270bc6" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  # default     = "t3.micro"
  type        = string
}

variable "key_name" {
  description = "Key pair name for the EC2 instance"
  # default     = "madhukey" # Replace with your key pair name
  type        = string
}


variable "tag_server_name" {
  description = "Name tag for the EC2 instance"
  # default     = "prod-server"
  type        = string
}
