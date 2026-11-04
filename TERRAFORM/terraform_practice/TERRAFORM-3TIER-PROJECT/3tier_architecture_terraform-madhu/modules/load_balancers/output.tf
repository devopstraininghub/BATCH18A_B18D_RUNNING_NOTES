output "frontend_alb_arn" {
  description = "ARN of the frontend Application Load Balancer"
  value       = aws_lb.frontend_alb.arn
}

output "backend_alb_arn" {
  description = "ARN of the backend Application Load Balancer"
  value       = aws_lb.backend_alb.arn
}

output "frontend_tg_arn" {
  description = "ARN of the frontend target group"
  value       = aws_lb_target_group.frontend_tg.arn
}

output "backend_tg_arn" {
  description = "ARN of the backend target group"
  value       = aws_lb_target_group.backend_tg.arn
}
output "alb_frontend_dns" {
  description = "The DNS name of the frontend ALB"
  value       = aws_lb.frontend_alb.dns_name
}

output "alb_backend_dns" {
  description = "The DNS name of the backend ALB"
  value       = aws_lb.backend_alb.dns_name
}

