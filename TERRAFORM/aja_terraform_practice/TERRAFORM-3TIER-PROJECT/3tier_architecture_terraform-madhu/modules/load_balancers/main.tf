resource "aws_lb" "frontend_alb" {
  name               = var.frontend_alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids
  tags               = { Name = var.frontend_alb_name }
}

resource "aws_lb" "backend_alb" {
  name               = var.backend_alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids
  tags               = { Name = var.backend_alb_name }
}

# Load Balancer Listeners
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

# Target Groups
resource "aws_lb_target_group" "frontend_tg" {
  name     = var.frontend_tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags     = { Name = var.frontend_tg_name }
}

resource "aws_lb_target_group" "backend_tg" {
  name     = var.backend_tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags     = { Name = var.backend_tg_name }
}