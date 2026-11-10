

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "frontend_tg_name" {
  description = "Name of frontend target group"
    type        = string
}



variable "backend_tg_name" {
  description = "Name of backend target group"
  type        = string
}



variable "frontend_lb_name" {
  description = "Name of frontend load balancer"
  type        = string
}

variable "backend_lb_name" {
  description = "Name of backend load balancer"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the load balancer"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the load balancer"
  type        = list(string)
}

