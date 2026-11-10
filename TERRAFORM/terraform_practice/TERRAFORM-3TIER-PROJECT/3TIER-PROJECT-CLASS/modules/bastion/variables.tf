
output "jump_server" {
  value = aws_instance.bastion.public_ip
}

variable "ami_id" {
  description = "The AMI ID for the Bastion Host"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the Bastion Host"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "public_subnet_id" {
  description = "The public subnet ID where the Bastion host will be deployed"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the Bastion Host"
  type        = string
}

variable "bastion_name" {
  description = "Tag name for the Bastion Host"
  type        = string
  #default     = "bastion-host"
}
output "bastion_instance_id" {
  description = "The ID of the Bastion host instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "The public IP of the Bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "The private IP of the Bastion host"
  value       = aws_instance.bastion.private_ip
}