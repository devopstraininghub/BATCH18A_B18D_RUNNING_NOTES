variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  # default     = "170.20.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnets with CIDR and Availability Zone"
  type = list(object({
    cidr = string
    az   = string
  }))

  # default = [
  #   { cidr = "170.20.1.0/24", az = "us-east-1a" },
  #   { cidr = "170.20.2.0/24", az = "us-east-1b" }
  # ]
}

variable "private_subnets" {
  description = "List of private subnets with CIDR and Availability Zone"
  type = list(object({
    cidr = string
    az   = string
  }))
  # default = [
  #   { cidr = "170.20.3.0/24", az = "us-east-1a" },
  #   { cidr = "170.20.4.0/24", az = "us-east-1b" },
  #   { cidr = "170.20.5.0/24", az = "us-east-1a" },
  #   { cidr = "170.20.6.0/24", az = "us-east-1b" },
  #   { cidr = "170.20.7.0/24", az = "us-east-1a" },
  #   { cidr = "170.20.8.0/24", az = "us-east-1b" }
  # ]
}
# variable "private_subnet_cidrs" {
#   description = "List of private subnet CIDR blocks"
#   type        = list(string)
# }


# variable "availability_zones" {
#   description = "List of availability zones for private subnets"
#   type        = list(string)
# }