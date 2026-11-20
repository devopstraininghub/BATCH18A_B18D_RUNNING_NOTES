variable "frontend_asg_name" {
  description = "Name of the frontend Auto Scaling Group"
  type        = string
}

variable "backend_asg_name" {
  description = "Name of the backend Auto Scaling Group"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
}

variable "frontend_subnet_ids" {
  description = "List of subnet IDs for the frontend ASG"
  type        = list(string)
}

variable "backend_subnet_ids" {
  description = "List of subnet IDs for the backend ASG"
  type        = list(string)
}

variable "frontend_tg_arn" {
  description = "ARN of the frontend target group"
  type        = string
}

variable "backend_tg_arn" {
  description = "ARN of the backend target group"
  type        = string
}

variable "frontend_lt_id" {
  description = "Launch template ID for frontend ASG"
  type        = string
}

variable "backend_lt_id" {
  description = "Launch template ID for backend ASG"
  type        = string
}