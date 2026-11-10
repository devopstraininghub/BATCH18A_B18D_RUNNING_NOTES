aws_region = "us-east-1"
ami_id     = "ami-0ed59cbb87dfa8dba"

instances = {
  dev  = { instance_type = "t3.micro" }
  qa   = { instance_type = "t3.micro" }
  prod = { instance_type = "t3.small" }
}
