output "rds_private_zone_id" {
  description = "The ID of the private hosted zone for RDS"
  value       = aws_route53_zone.rds_private.zone_id
}

output "rds_record_fqdn" {
  description = "The fully qualified domain name (FQDN) for the RDS record"
  value       = aws_route53_record.rds_endpoint.fqdn
}

output "public_zone_id" {
  description = "The ID of the public hosted zone"
  value       = aws_route53_zone.public_zone.zone_id
}

output "alb_record_fqdn" {
  description = "The fully qualified domain name (FQDN) for the ALB backend record"
  value       = aws_route53_record.alb_backend.fqdn
}