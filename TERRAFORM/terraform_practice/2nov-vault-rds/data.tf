
data "vault_kv_secret_v2" "rds_credentials" {
  mount = "secret"
  name  = "aws"
    }
