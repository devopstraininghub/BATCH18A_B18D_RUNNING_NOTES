

terraform {
  backend "s3" {
    bucket         = "mc-b18-state-bucket-2026-unique"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
   # dynamodb_table = "terraform-state-lock"
   use_lockfile   = true 
  }
}