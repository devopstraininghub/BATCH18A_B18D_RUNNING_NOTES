variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "sg_name" {
  description = "Name tag for the security group"
  type        = string
  # default     = "main-security-group"
}

variable "ingress_from_port" {
  description = "Ingress rule starting port"
  type        = number
  # default     = 0
}

variable "ingress_to_port" {
  description = "Ingress rule ending port"
  type        = number
  # default     = 0
}

variable "ingress_protocol" {
  description = "Protocol for ingress rules"
  type        = string
  # default     = "-1"
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks for ingress rules"
  type        = list(string)
  # default     = ["0.0.0.0/0"]
}

variable "egress_from_port" {
  description = "Egress rule starting port"
  type        = number
  # default     = 0
}

variable "egress_to_port" {
  description = "Egress rule ending port"
  type        = number
  # default     = 0
}

variable "egress_protocol" {
  description = "Protocol for egress rules"
  type        = string
  # default     = "-1"
}

variable "egress_cidr_blocks" {
  description = "CIDR blocks for egress rules"
  type        = list(string)
  # default     = ["0.0.0.0/0"]
}