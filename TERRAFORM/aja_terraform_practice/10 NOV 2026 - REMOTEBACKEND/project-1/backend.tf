
terraform {
  backend "s3" {
    bucket       = "aja-state-bucket-2026-unique"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    # dynamodb_table = "terraform-state-lock"   ← old approach, left commented out
    use_lockfile = true
  }
}