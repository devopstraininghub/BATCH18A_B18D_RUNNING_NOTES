

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "ingress_from_port" {
    description = "The starting port for ingress traffic"
    type        = number

}

variable "ingress_to_port" {
    description = "The ending port for ingress traffic"
    type        = number
}

variable "ingress_protocol" {
    description = "The protocol for ingress traffic (e.g., tcp, udp, icmp)"
    type        = string
}

variable "ingress_cidr_blocks" {
    description = "The CIDR blocks for ingress traffic"
    type        = list(string)
}

variable "egress_from_port" {
    description = "The starting port for egress traffic"
    type        = number
}

variable "egress_to_port" {
    description = "The ending port for egress traffic"
    type        = number
}

variable "egress_protocol" {
    description = "The protocol for egress traffic (e.g., tcp, udp, icmp)"
    type        = string
}

variable "egress_cidr_blocks" {
    description = "The CIDR blocks for egress traffic"
    type        = list(string)
}

variable "security_group_name" {
    description = "The name of the security group"
    type        = string
}