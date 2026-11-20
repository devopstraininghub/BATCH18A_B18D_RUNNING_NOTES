output "frontend_asg_id" {
  description = "Frontend Auto Scaling Group ID"
  value       = aws_autoscaling_group.frontend_asg.id
}

output "backend_asg_id" {
  description = "Backend Auto Scaling Group ID"
  value       = aws_autoscaling_group.backend_asg.id
}