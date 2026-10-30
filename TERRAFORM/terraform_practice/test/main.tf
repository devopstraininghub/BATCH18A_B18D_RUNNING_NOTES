

resource "aws_instance" "test" {

   ami = "ami-073f45061d35c86f0"
   instance_type = "t3.micro"
  
   tags = {
    Name = "Madhuserver"
}

#terraform import aws_instance.test i-0d2d91e7c9ece42f


resource "aws_s3_bucket" "testbukcet" {
  # (resource arguments)
  bucket =  "madhhutest-b18-12354"
}


# terraform import aws_s3bucket.testbukcet madhhutest-b18-12354
