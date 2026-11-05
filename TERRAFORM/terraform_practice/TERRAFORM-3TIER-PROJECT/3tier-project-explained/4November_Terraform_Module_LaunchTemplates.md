# Batch 18 — Terraform Running Notes: 4 November 2026

**Topic: The `launch_templates` Module — 3-Tier Project, Module 5 of 9**

Friends, this module defines **what** a frontend or backend EC2 instance actually looks like — its AMI, size, key pair, and startup script — without creating any instances itself. The `asg` module (`4November_Terraform_Module_ASG.md`) is what actually launches instances, using the templates built here as the blueprint.

---

## 1. What this module builds

- **Two Launch Templates**: `frontend_lt` and `backend_lt` — one blueprint per tier.

---

## 2. `variables.tf`

```hcl
variable "frontend_lt_name" {
  type = string
}

variable "backend_lt_name" {
  type = string
}

variable "key_name" {
  type = string
}

variable "ami_id_frontend" {
  type = string
}

variable "ami_id_backend" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "frontend_user_data" {
  type = string
}

variable "backend_user_data" {
  type = string
}

variable "security_group_id" {
  type = string
}
```
- Separate `ami_id_frontend`/`ami_id_backend` — frontend and backend run **different** AMIs (the frontend one ends up running Apache, the backend one runs a Node.js API via `pm2` — see `backend.sh` below).

---

## 3. `main.tf`

```hcl
resource "aws_launch_template" "frontend_lt" {
  name          = var.frontend_lt_name
  key_name      = var.key_name
  image_id      = var.ami_id_frontend
  instance_type = var.instance_type
  user_data     = base64encode(file("${path.module}/${var.frontend_user_data}"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [var.security_group_id]
  }
}

resource "aws_launch_template" "backend_lt" {
  name          = var.backend_lt_name
  key_name      = var.key_name
  image_id      = var.ami_id_backend
  instance_type = var.instance_type
  user_data     = base64encode(file("${path.module}/${var.backend_user_data}"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [var.security_group_id]
  }
}
```

⚠️ **The two details that are genuinely new here, worth sitting with:**
- **`base64encode(file(...))`** — every `user_data` we've written before this (`16October_Terraform_MiniProject.md` onward) used plain `user_data = file("facebook.sh")`, no encoding. `aws_launch_template.user_data` specifically **requires base64-encoded text** — `aws_instance.user_data` doesn't. Forgetting the `base64encode(...)` wrapper here is a very easy, very real mistake to make.
- **`${path.module}`** — a Terraform built-in that always points at **the folder this module's own files live in**, regardless of where the root project is. It's needed here specifically because this module is called from the root (`./modules/launch_templates`), but `frontend.sh`/`backend.sh` sit *inside that module's own folder* — without `path.module`, Terraform would look for those scripts relative to the root project instead, and fail to find them.

---

## 4. The two startup scripts

**`frontend.sh`:**
```bash
#!/bin/bash
sudo apt update -y
sleep 90
sudo systemctl start apache2.service
```

**`backend.sh`:**
```bash
#!/bin/bash
sudo apt update -y
sudo pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
sudo systemctl start pm2-root
sudo systemctl enable pm2-root
sudo pm2 start aws_three_tier_code/backend/index.js --name "backendApi"
sudo apt install mysql-server -y
mysql -h book.rds.com -u admin -ppassword123 test < aws_three_tier_code/backend/test.sql
```
- `frontend.sh` is a simple Apache startup — the same idea as `facebook.sh` from `16October_Terraform_MiniProject.md`, just for Ubuntu (`apt`, `apache2.service`) instead of Amazon Linux (`yum`, `httpd`).
- `backend.sh` starts a **Node.js API** under `pm2` (a process manager that keeps a Node app running and restarts it if it crashes), then loads a `test.sql` file into MySQL — note it connects using `book.rds.com`, the **private hosted zone name** the `route53` module (`4November_Terraform_Module_Route53.md`) gives the RDS endpoint, not the raw AWS-generated endpoint.
- ⚠️ **The same hardcoded password already flagged in `4November_Terraform_3TierProject.md` §4 shows up again here**, in plain text in a shell script — `-ppassword123`. This is exactly why that section calls it a reused mistake, not a one-off: the same secret ends up duplicated in more than one file, which is precisely the situation `2Nov_Vault.md`'s approach (fetch the credential at runtime, store it nowhere in code) is meant to prevent.

---

## 5. `output.tf`

```hcl
output "frontend_lt_id" {
  value = aws_launch_template.frontend_lt.id
}

output "backend_lt_id" {
  value = aws_launch_template.backend_lt.id
}
```
- Both IDs feed directly into the `asg` module — an Auto Scaling Group references a Launch Template by its ID.

---

## 6. How the root project actually calls this module

```hcl
module "launch_templates" {
  source             = "./modules/launch_templates"
  frontend_lt_name   = "frontend-lt"
  backend_lt_name    = "backend-lt"
  key_name           = "madhu"
  ami_id_frontend    = "ami-026ff2aed0f235b98"
  ami_id_backend     = "ami-0cf6e84dc7d56f9d1"
  instance_type      = "t3.micro"
  frontend_user_data = "frontend.sh"
  backend_user_data  = "backend.sh"
  security_group_id  = module.security_group.security_group_id
}
```
- Notice `frontend_user_data`/`backend_user_data` are passed in as just `"frontend.sh"`/`"backend.sh"` — plain filenames, no path. That's only possible *because* the module's own `main.tf` prepends `${path.module}/` to them internally — the root project never needs to know or care where inside the module folder those scripts actually live.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Launch Template | The blueprint for an instance — AMI, size, key, startup script | Used by an ASG to actually launch instances |
| `base64encode(file(...))` | Required for `aws_launch_template.user_data` | Different from plain `aws_instance.user_data` |
| `path.module` | The current module's own folder, regardless of caller | Lets `frontend.sh`/`backend.sh` be found correctly |
| Two AMIs, two scripts | Frontend runs Apache, backend runs a Node.js API under `pm2` | Matches the web-tier/app-tier split in the architecture |
| Repeated hardcoded password | Same real mistake, now in a second file | Reinforces why `2Nov_Vault.md`'s approach matters |
