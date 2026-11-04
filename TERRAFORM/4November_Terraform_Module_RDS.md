# Batch 18 — Terraform Running Notes: 4 November 2026

**Topic: The `rds` Module — 3-Tier Project, Module 7 of 9**

Friends, this module builds the database tier — the one piece of this whole architecture that absolutely must never be reachable from outside the VPC, matching every RDS principle already covered in `25September_RDS.md`.

---

## 1. What this module builds

- One **DB Subnet Group**.
- One **RDS MySQL instance**, placed into that subnet group.

---

## 2. `variables.tf`

```hcl
variable "db_identifier" {
  type = string
}

variable "db_engine" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_allocated_storage" {
  type = number
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_security_group_id" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}
```

⚠️ **`sensitive = true` on `db_password` — a genuinely new Terraform concept, and a good one.** Marking a variable `sensitive` tells Terraform to **hide its value** from `plan`/`apply` console output and logs — instead of printing the real password, Terraform shows `(sensitive value)`. This is a real, worthwhile protection — but it's worth being precise about what it does and doesn't do: **it does not encrypt the value, and it does not stop the real password from still being written into the Terraform state file, or from being hardcoded in a calling `main.tf`.** `sensitive = true` only hides it from terminal output — it's a genuinely useful habit, but it's not a substitute for actually keeping the real value out of your code in the first place (which is `2Nov_Vault.md`'s job).

---

## 3. `main.tf`

```hcl
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags       = { Name = "rds-subnet-group" }
}

resource "aws_db_instance" "db" {
  identifier              = var.db_identifier
  engine                  = var.db_engine
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  publicly_accessible     = false
  skip_final_snapshot     = true
  vpc_security_group_ids  = [var.db_security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  tags = { Name = var.db_identifier }
}
```
- `publicly_accessible = false` — hardcoded, not even a variable. This isn't something the module lets the caller get wrong — the database is private, full stop.
- `db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name` — the subnet group gets created **first**, by this same module, then the DB instance references it — all inside one module, no need to pass a subnet group in from outside.

---

## 4. `output.tf`

```hcl
output "rds_instance_id" {
  value = aws_db_instance.db.id
}

output "rds_endpoint" {
  value = aws_db_instance.db.endpoint
}

output "rds_subnet_group" {
  value = aws_db_subnet_group.rds_subnet_group.name
}
```
- `rds_endpoint` is the one output that matters most outside this module — it's exactly what feeds into the `route53` module next, to give the raw AWS endpoint a friendlier internal DNS name.

---

## 5. How the root project actually calls this module

```hcl
module "rds" {
  source                = "./modules/rds"
  db_identifier         = "app-db"
  db_engine             = "mysql"
  db_instance_class     = "db.t3.micro"
  db_allocated_storage  = 25
  db_name               = "test"
  db_username           = "admin"
  db_password           = "password123"  # Consider using AWS Secrets Manager or Vault
  db_security_group_id  = module.security_group.security_group_id
  db_subnet_ids         = [module.network.private_subnet_ids[4], module.network.private_subnet_ids[5]]
}

output "rds_name" {
  value = module.rds.rds_endpoint
}
```
⚠️ **This is the exact spot flagged in `4November_Terraform_3TierProject.md` §4.** The module itself does the right thing — `sensitive = true`, no public access, private subnets only. But the **call site** hardcodes a real, working password directly into version-controlled `main.tf`, with the module's own comment immediately next to it admitting that's not the right approach. The module's design and the module's actual usage here are two different things — a well-built module can still be called badly, and this is exactly what that looks like.
- `private_subnet_ids[4]` and `[5]` — the **last** pair of the `network` module's 6 private subnets, left unused by the `asg` module (`4November_Terraform_Module_ASG.md`), which only took subnets `0-3`. This is the database tier getting its own dedicated pair, same AZ-spanning pattern as the other two tiers.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `sensitive = true` | Hides a variable's value from console/log output | Does NOT encrypt it or keep it out of state/code |
| `publicly_accessible = false` | Hardcoded in the module, not a variable | The database can never be made public by mistake here |
| DB Subnet Group built inside the module | No need to pass a pre-made subnet group in | Created from `db_subnet_ids`, used immediately |
| `rds_endpoint` output | Feeds directly into the `route53` module | Gets wrapped in a friendly private DNS name next |
| Hardcoded password at the call site | The module did its job; the caller didn't | Exactly what `2Nov_Vault.md` exists to fix |
| Subnets 4-5 used here | The last pair, left over after the ASG took 0-3 | Each tier gets its own dedicated subnet pair |
