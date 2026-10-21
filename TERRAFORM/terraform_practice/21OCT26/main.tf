


resource "aws_instance" "my_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  count         = var.instance_count

  tags = {
    Name = "MyInstance"
  }
}

