
variable "db_subnet_ids" {
  description = "The subnet IDs for the RDS instance"
  type        = list(string)
}

variable "db_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
}

variable "db_engine" {
  description = "The database engine for the RDS instance"
  type        = string
}

variable "db_instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage for the RDS instance"
  type        = number
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  #default     = "test"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}
variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "db_security_group_id" {
  description = "The security group ID for the RDS instance"
  type        = string
}