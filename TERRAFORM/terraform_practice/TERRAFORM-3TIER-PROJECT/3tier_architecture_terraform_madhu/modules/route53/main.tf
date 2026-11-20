# Private Hosted Zone for RDS
resource "aws_route53_zone" "rds_private" {
  name = var.rds_private_zone_name
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "rds_endpoint" {
  zone_id = aws_route53_zone.rds_private.zone_id
  name    = var.rds_record_name
  type    = "CNAME"
  ttl     = 100
  records = [var.rds_endpoint]
}

# Public Hosted Zone for b15facebook.xyz
resource "aws_route53_zone" "public_zone" {
  name = var.public_zone_name
}

resource "aws_route53_record" "alb_backend" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = var.alb_record_name
  type    = "CNAME"
  ttl     = 300
  records = [var.alb_dns_name]
}



resource "aws_route53_record" "alb_frontend" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = var.alb_dns_frontend_record
  type    = "CNAME"
  ttl     = 300
  records = [var.alb_front_dns_name]
}