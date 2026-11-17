resource "aws_launch_template" "frontend_lt" {
  name          = var.frontend_lt_name
  key_name      = var.key_name
  image_id      = var.ami_id_frontend
  instance_type = var.instance_type
  user_data     = base64encode(file("${path.module}/${var.frontend_user_data}"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [var.security_group_id]
  }
}

resource "aws_launch_template" "backend_lt" {
  name          = var.backend_lt_name
  key_name      = var.key_name
  image_id      = var.ami_id_backend
  instance_type = var.instance_type
  user_data     = base64encode(file("${path.module}/${var.backend_user_data}"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [var.security_group_id]
  }
}