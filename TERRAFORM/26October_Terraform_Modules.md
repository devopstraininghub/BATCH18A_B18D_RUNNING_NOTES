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
resource "aws_instance" "server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  count         = var.instance_count

  tags = {
    Name = var.tag_server_name
  }
}
```
- Notice `count = var.instance_count` **inside the module itself** — the module doesn't just create one instance per call, it can create however many the caller asks for.

**`ec2-module/variables.tf`:**
```hcl
variable "ami_id" {
  description = "Ami id for instance"
}

variable "instance_type" {
  description = "the instance family type"
}

variable "key_name" {
  description = "Key pair name to connect the instance"
}

variable "instance_count" {
  description = "No of instances"
}

variable "tag_server_name" {
  description = "Tag name of the ec2 instance"
}
```
- None of these variables declare a `type` this time — that's allowed. **A variable with no `type` defaults to `any`**, meaning Terraform won't check what kind of value gets passed in. It works, but it's looser than `21October_Terraform_Variables.md`'s style, which always pinned down `type = string`/`number`/etc. — being explicit about `type` catches mistakes earlier (passing a number where a string was expected, for instance), so it's worth doing even though Terraform doesn't force it.

**`main.tf` (the root module, calling it twice with genuinely different inputs):**
```hcl
provider "aws" {
  region = "us-east-1"
}

module "dev_webserver" {
  source          = "./ec2-module"
  ami_id          = "ami-04b938437b69a2c9c"
  instance_count  = 1
  instance_type   = "t2.micro"
  tag_server_name = "DevServer"
  key_name        = "mckey"
}

module "prod-server" {
  source          = "./ec2-module"
  ami_id          = "ami-0d97d7f07b25dd693"
  instance_count  = 2
  instance_type   = "t3.micro"
  key_name        = "ramanikey"
  tag_server_name = "Prod servers"
}
```
- **This is a cleaner demonstration of the whole point of modules than a single call would be:** `dev_webserver` creates **1** `t2.micro`, `prod-server` creates **2** `t3.micro` instances — same module, same code, two calls, genuinely different outcomes each time, purely from different inputs.

⚠️ **Still worth fixing, verified against HashiCorp's own current guidance:** `ec2-module/main.tf` still has its own `provider "aws" { region = "us-east-1" }` block inside the module (same issue as the first pass at this exercise). **Child modules shouldn't declare their own provider blocks** — a module is meant to inherit its provider configuration from whatever calls it (the root module, here). A provider has to stay available for the *entire* lifetime of the resources it manages, including when they're eventually destroyed — a provider block living inside the module itself can break that, and this exact pattern is called out by HashiCorp as discouraged/legacy. The provider block is left out of the example above intentionally — only the **root** `main.tf` should configure the provider; the module just uses whatever provider the caller already set up.

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
| Calling a module multiple times | Same code, different inputs each call | `dev_webserver` (1× t2.micro) vs `prod-server` (2× t3.micro) |
| `count` inside a module | A module's own resource can still use `count` | `count = var.instance_count`, set per module call |
| Module variables | The module's own "settings" it expects from the caller | `var.ami_id`, `var.instance_type`, etc. |
| Variable with no `type` | Defaults to `any` — allowed, but looser than pinning a type | Worth adding `type = string` anyway, to catch mistakes early |
| Provider blocks and modules | Keep provider config in the root module only | A provider inside a child module is a discouraged legacy pattern |
| Updating a module | One change, applied everywhere it's used | Fix the SG module once → every EC2/ALB/Bastion using it updates |
