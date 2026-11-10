resource "aws_instance" "bastion" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = var.public_subnet_id
  security_groups = [var.security_group_id]

  tags = {
    Name = var.bastion_name
  }

# lifecycle {
#     prevent_destroy = true
#     ignore_changes = [ami, instance_type, key_name]
#   }

}
