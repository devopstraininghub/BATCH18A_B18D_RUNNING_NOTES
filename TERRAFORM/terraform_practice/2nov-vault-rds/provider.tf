


provider "aws" {
  region = "us-east-1"
}


provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = var.vault_token
}
