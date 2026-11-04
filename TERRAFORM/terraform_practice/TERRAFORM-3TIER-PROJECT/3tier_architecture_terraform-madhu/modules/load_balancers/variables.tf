variable "frontend_alb_name" {
  description = "Name of the frontend Application Load Balancer"
  type        = string
}

variable "backend_alb_name" {
  description = "Name of the backend Application Load Balancer"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where the ALB will be deployed"
  type        = list(string)
}

variable "frontend_tg_name" {
  description = "Name of the frontend target group"
  type        = string
}

variable "backend_tg_name" {
  description = "Name of the backend target group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB will be deployed"
  type        = string
}