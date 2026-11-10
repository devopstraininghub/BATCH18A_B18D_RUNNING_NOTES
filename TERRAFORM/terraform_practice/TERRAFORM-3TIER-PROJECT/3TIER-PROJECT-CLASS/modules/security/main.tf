

resource "aws_security_group" "main_sg" {
  name        = "main_sg"
  description = "Main security group of this project"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.ingress_from_port
    to_port     = var.ingress_to_port
    protocol    = var.ingress_protocol
    cidr_blocks = var.ingress_cidr_blocks
  }

    egress {
        from_port   = var.egress_from_port
        to_port     = var.egress_to_port
        protocol    = var.egress_protocol
        cidr_blocks = var.egress_cidr_blocks
    }

    tags = {
        Name = var.security_group_name
    }
}


output "security_group_id" {
  value = aws_security_group.main_sg.id
}