
variable "domain_name" {
  description = "Primary domain name for the ACM certificate"
  type        = string
}

variable "san_names" {
  description = "List of Subject Alternative Names (SANs) for the certificate"
  type        = list(string)
  default     = []
}


output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.b17facebook_cert.arn
}

resource "aws_acm_certificate" "b17facebook_cert" {
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = var.san_names

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [domain_validation_options]
  }
}
