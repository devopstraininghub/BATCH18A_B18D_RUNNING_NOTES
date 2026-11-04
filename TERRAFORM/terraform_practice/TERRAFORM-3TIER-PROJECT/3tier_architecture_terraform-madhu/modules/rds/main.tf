# DB Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags       = { Name = "rds-subnet-group" }
}

# RDS Database
resource "aws_db_instance" "db" {
  identifier             = var.db_identifier
  engine                = var.db_engine
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  db_name               = var.db_name
  username              = var.db_username
  password              = var.db_password
  publicly_accessible   = false
  skip_final_snapshot   = true
  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  tags = { Name = var.db_identifier }
}