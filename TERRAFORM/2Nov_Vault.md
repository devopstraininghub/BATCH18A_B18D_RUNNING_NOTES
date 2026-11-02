
#  What is Vault + Terraform?

* **Terraform** → Infrastructure as Code (create AWS, EC2, RDS, etc.)
* **Vault** → Secret Manager (stores passwords, API keys, DB creds securely)

 Problem:
You don’t want to hardcode secrets like:

```hcl
password = "mypassword123"
```

 Solution:
Use **Vault to dynamically fetch secrets in Terraform**

---

#  Real-Time Use Case

You are deploying:

* EC2 instance
* RDS database

Instead of storing DB password in code:
 Store in Vault → Fetch via Terraform → Use securely
 
---

##  Prerequisites

* Terraform installed
* Vault installed
* AWS CLI configured (if using AWS resources)
* Git Bash / Terminal
---

# Install Vault on Windows 

##  Step 1: Download Vault

Go to:
 [https://developer.hashicorp.com/vault/downloads](https://developer.hashicorp.com/vault/downloads)

* Select:

  * OS: **Windows**
  * Architecture: **amd64**

Download ZIP file

---

## 📂 Step 2: Extract

* Extract ZIP → you’ll get:

```bash
vault.exe
```

Move it to a folder like:

```bash
C:\vault\
```

---

##  Step 3: Add to PATH

### Steps:

1. Go to **Environment Variables**
2. Under **System Variables → Path → Edit**
4. Add:

```bash
C:\vault\
```

Click OK 

---

##  Step 4: Restart Terminal

Close Git Bash and open again

---

##  Step 5: Verify

```bash
vault --version
```

 Output should be like:

```bash
Vault v1.x.x
```

---


##  Architecture

```
Terraform → Vault → AWS
             ↓
         Secrets (DB credentials)
```

---

##  Step 1: Start Vault Server (Dev Mode)

```bash
vault.exe server -dev
```

### Output:

```
Root Token: hvs.xxxxxx
Vault Addr: http://127.0.0.1:8200
```

 Keep this terminal running.

---

##  Step 2: Set Environment Variables

Open a **new terminal**:

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='hvs.xxxxxx'
```

Verify:

```bash
vault status
```

Expected:

```
Sealed: false
```

---

##  Step 3: Store Secrets in Vault

```bash
vault kv put secret/aws db_username=admin db_password=MyPass123
```

Verify:

```bash
vault kv get secret/aws
```

---

##  Project Structure

```
terraform-vault/
│
├── provider.tf
├── variables.tf
├── data.tf
├── main.tf
└── terraform.tfvars (optional)
```

---

##  Step 4: Terraform Configuration

### provider.tf

```hcl
provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = var.vault_token
}

provider "aws" {
  region = "us-east-1"
}
```

---

### variables.tf

```hcl
variable "vault_token" {
  description = "Vault Root Token"
  type        = string
}
```

---

### data.tf

```hcl
data "vault_kv_secret_v2" "aws_secret" {
  mount = "secret"
  name  = "aws"
}
```

---

### main.tf (Example: RDS)

```hcl
resource "aws_db_instance" "example" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = data.vault_kv_secret_v2.aws_secret.data["db_username"]
  password             = data.vault_kv_secret_v2.aws_secret.data["db_password"]
  skip_final_snapshot  = true
}
```

---

##  Step 5: Provide Vault Token to Terraform

###  terraform.tfvars

```hcl
vault_token = "hvs.xxxxxx"
```

---

##  Step 6: Run Terraform

```bash
terraform init
terraform plan
terraform apply
```

---

##  Common Issues & Fixes

###  Error: connection refused

✔ Vault server not running → start again

---

###  Error: invalid token / permission denied

✔ Vault restarted → new token required
✔ Re-export VAULT_TOKEN

---

###  Secrets not found

✔ Re-run:

```bash
vault kv put secret/aws db_username=admin db_password=MyPass123
```

---

##  Important Notes

* Dev mode Vault:

  * Data is temporary 
  * Token changes on restart 

* Production Vault:

  * Persistent storage 
  * IAM / AppRole authentication 

---

##  Best Practices

*  Never hardcode secrets in Terraform files
*  Don’t commit `.tfvars` to GitHub
*  Use Vault for secrets management
*  Use environment variables for tokens


 If interviewer asks:

**“How do you integrate Terraform with Vault?”**

Answer:

> “We use Vault provider in Terraform to securely fetch secrets at runtime using data blocks. Instead of hardcoding credentials, Terraform dynamically retrieves secrets like DB passwords from Vault. In advanced setups, we use Vault dynamic secrets and authentication methods like AppRole or IAM to enhance security.”


