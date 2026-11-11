

variable "security_groups" {
  type = map(string)
  default = {
    web = "Web server security group"
    app = "Application security group"
    db  = "Database security group"
  }
}
## 
resource "aws_security_group" "sg" {
  for_each    = var.security_groups
  name        = "${each.key}-sg"
  description = each.value
  vpc_id      = "vpc-066e6bd0d51c6b811"

  tags = {
    Name = "${each.key}-sg"
  }
}

variable "iam_users" {
  type    = set(string)
  default = ["developer", "tester", "admin"]
}

resource "aws_iam_user" "users" {
  for_each = var.iam_users
  name     = each.value
}