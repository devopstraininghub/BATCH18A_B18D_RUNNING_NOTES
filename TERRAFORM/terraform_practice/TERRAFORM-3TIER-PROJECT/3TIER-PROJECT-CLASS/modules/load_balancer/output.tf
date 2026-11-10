

output "frontend_tg_arn" {

value = aws_lb_target_group.frontend_tg.arn

}



output "backend_tg_arn" {
  value = aws_lb_target_group.backend_tg.arn
}

output "alb_frontend_dnsname" {
  value = aws_lb.frontend_lb.arn
}

output "alb_backend_dnsname" {
  value = aws_lb.backend_lb.arn
}