resource "aws_autoscaling_group" "frontend_asg" {
  name                = var.frontend_asg_name
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = var.frontend_subnet_ids
  target_group_arns   = [var.frontend_tg_arn]

  launch_template {
    id      = var.frontend_lt_id
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "backend_asg" {
  name                = var.backend_asg_name
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = var.backend_subnet_ids
  target_group_arns   = [var.backend_tg_arn]

  launch_template {
    id      = var.backend_lt_id
    version = "$Latest"
  }
}

