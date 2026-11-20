variable "frontend_lt_name" {
  description = "Name of the frontend launch template"
  type        = string
}

variable "backend_lt_name" {
  description = "Name of the backend launch template"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "ami_id_frontend" {
  description = "AMI ID for the frontend instance"
  type        = string
}

variable "ami_id_backend" {
  description = "AMI ID for the backend instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
}

variable "frontend_user_data" {
  description = "User data script for frontend instance"
  type        = string
}

variable "backend_user_data" {
  description = "User data script for backend instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for instances"
  type        = string
}