# Batch 18 — Terraform Running Notes: 26 October 2026

**Topic: Terraform Modules**

Friends, by now `main.tf` has grown a VPC, a subnet, a security group, an ENI, an EIP, an EC2 instance — and if tomorrow you needed a *second*, slightly different EC2 instance, you'd be tempted to just copy-paste the whole `resource "aws_instance"` block again. **Modules** are Terraform's answer to that temptation: write a piece of infrastructure **once**, then reuse it as many times as you need, with different inputs each time.

---

## 1. What is a module, in simple terms?

- A **module** is a **reusable block of Terraform code.**
- Instead of writing the same resource code again and again, you write it **once** and reuse it multiple times.
- This is the same **DRY** principle (**D**on't **R**epeat **Y**ourself) that applies in regular programming — just applied to infrastructure code.

---

## 2. The problem, without modules

Suppose you need:
- 3 EC2 instances.
- 5 EC2 instances.
- 10 EC2 instances.

**Without a module:** you write the same EC2 resource code multiple times. ❌

**Issues this causes:**
- Repeated code.
- Hard to update — change one thing, have to remember to change it everywhere.
- Error-prone — easy for the copies to quietly drift apart from each other.

---

## 3. The solution, with modules

- Create **ONE** EC2 module.
- Reuse it multiple times, with **different inputs** each time. ✅

---

## 4. Step 1 — create the module

**Folder structure:**
```
modules/
    ec2/
        main.tf
        variables.tf
```

**`modules/ec2/main.tf`:**
```hcl
resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type
}
```

**`modules/ec2/variables.tf`:**
```hcl
variable "ami" {}
variable "instance_type" {}
```
- The module itself is just a normal `.tf` file — the only thing that makes it a "module" is that something else (§5) refers to this folder as its `source`.

---

## 5. Step 2 — use the module, multiple times

**`main.tf` (the root module):**
```hcl
module "web_server" {
  source        = "./modules/ec2"
  ami           = "ami-123"
  instance_type = "t2.micro"
}

module "app_server" {
  source        = "./modules/ec2"
  ami           = "ami-456"
  instance_type = "t3.medium"
}

module "db_server" {
  source        = "./modules/ec2"
  ami           = "ami-789"
  instance_type = "t3.large"
}
```

**What's happening here:**
- The **same** EC2 code is reused **3 times**.
- Only the **inputs** changed: `web` → small instance, `app` → medium instance, `db` → large instance.
- **Easy memory trick:** a module call looks just like a `resource` block, but with `module` instead of `resource`, and a `source` telling Terraform *where* the reusable code actually lives.

---

## 6. Hands-on — today's actual practice code

**`ec2-module/main.tf` (the module):**
```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = var.tag_server_name
  }
}
```

**`ec2-module/variables.tf`:**
```hcl
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for the instance"
  type        = string
}

variable "tag_server_name" {
  description = "The name of the server to be tagged"
  type        = string
}
```

**`main.tf` (the root module, calling it):**
```hcl
provider "aws" {
  region = "us-east-1"
}

module "madhu-ec2creation" {
  source          = "./ec2-module"
  ami_id          = "ami-0d97d7f07b25dd693"
  key_name        = "mckey"
  instance_type   = "t2.micro"
  tag_server_name = "Madhu-server"
}
```
- Same shape as §4–§5's teaching example, just with four inputs instead of two (`ami_id`, `key_name`, `instance_type`, `tag_server_name`), matching the variables already built up across `21October_Terraform_Variables.md` and `22October_Terraform_MiniProject_Variables.md`.

⚠️ **One thing worth fixing, verified against HashiCorp's own current guidance:** today's `ec2-module/main.tf` also had its own `provider "aws" { region = "us-east-1" }` block inside the module. **Child modules shouldn't declare their own provider blocks** — a module is meant to inherit its provider configuration from whatever calls it (the root module, here). A provider has to stay available for the *entire* lifetime of the resources it manages, including when they're eventually destroyed — a provider block living inside the module itself can break that, and this exact pattern is called out by HashiCorp as discouraged/legacy. The provider block removed from the example above is intentional — only the **root** `main.tf` should configure the provider; the module just uses whatever provider the caller already set up.

---

## 7. A real example — a Security Group module

- One module defines: SSH access, HTTP access.
- Use that **same** module for: EC2, ALB, a Bastion host.
- Same code, reused everywhere it's needed — instead of writing near-identical Security Group rules three separate times.

---

## 8. Benefits of modules (reusability)

- Write once, use many times.
- Reduces code duplication.
- Easy to maintain.
- Easy to update — **change the module once, and it affects every place that uses it.**

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Module | A reusable block of Terraform code | `modules/ec2/` reused for web/app/db servers |
| DRY | Don't Repeat Yourself — write it once | Same principle as in regular programming |
| `source` | Tells a `module` block where the reusable code lives | `source = "./modules/ec2"` |
| Calling a module multiple times | Same code, different inputs each call | `web_server` (t2.micro) vs `db_server` (t3.large) |
| Module variables | The module's own "settings" it expects from the caller | `var.ami_id`, `var.instance_type`, etc. |
| Provider blocks and modules | Keep provider config in the root module only | A provider inside a child module is a discouraged legacy pattern |
| Updating a module | One change, applied everywhere it's used | Fix the SG module once → every EC2/ALB/Bastion using it updates |
