output "frontend_lt_id" {
  description = "ID of the frontend launch template"
  value       = aws_launch_template.frontend_lt.id
}

output "backend_lt_id" {
  description = "ID of the backend launch template"
  value       = aws_launch_template.backend_lt.id
}