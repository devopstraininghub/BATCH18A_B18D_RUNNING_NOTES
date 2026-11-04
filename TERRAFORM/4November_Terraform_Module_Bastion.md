# Batch 18 — Terraform Running Notes: 4 November 2026

**Topic: The `bastion` Module — 3-Tier Project, Module 3 of 9**

Friends, this module builds the **one** EC2 instance in the whole project that's actually meant to be reachable from the outside for SSH — matching the jump-server pattern from `17September_Bastion.md`, now written as a reusable module.

---

## 1. What this module builds

- One EC2 instance, in a **public** subnet, acting as the jump host for the entire private network.

---

## 2. The code — all in one file, unusually

Unlike every other module in this project, `bastion`'s `variables.tf` and `output.tf` are both **empty** — everything lives inside `main.tf` instead:

```hcl
resource "aws_instance" "bastion" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = var.public_subnet_id
  security_groups = [var.security_group_id]

  tags = {
    Name = var.bastion_name
  }
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "bastion_name" {
  type    = string
  default = "bastion-host"
}

output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}
```
- ⚠️ **This still works perfectly** — Terraform reads every `.tf` file in a module's folder as one combined whole, regardless of which specific file a `variable`/`output`/`resource` block sits in. But it's worth noticing as the one inconsistency in this project: every other module (`network`, `security`, `rds`, `load_balancers`, `asg`) splits `main.tf`/`variables.tf`/`output.tf` cleanly, the way `21October_Terraform_Variables.md` taught. This module doesn't, and it's a little harder to scan at a glance because of it — a real, harmless example of "technically fine, practically worth tidying up."
- `bastion_name` is the **only** variable in this entire module with a `default` — every other variable here is required.

---

## 3. How the root project actually calls this module

```hcl
module "bastion" {
  source            = "./modules/bastion"
  ami_id            = "ami-0c3389a4fa5bddaad"
  instance_type     = "t3.micro"
  key_name          = "madhu"
  public_subnet_id  = module.network.public_subnet_ids[0]
  security_group_id = module.security_group.security_group_id
}

output "jump_server" {
  value = module.bastion.bastion_public_ip
}
```
- `public_subnet_id = module.network.public_subnet_ids[0]` — the bastion lands in the **first** public subnet the `network` module created.
- The root's own `jump_server` output surfaces the bastion's public IP straight to the terminal after `apply` — exactly the same "print the useful value, don't make someone go dig for it" pattern as the `output "instance_public_ip"` block in `16October_Terraform_MiniProject.md` §10.

---

## 4. Why a bastion, specifically, in this architecture

- Every other EC2 instance in this project (frontend/backend ASGs, RDS) lives in a **private** subnet, with no direct path in from the internet.
- The bastion is the **one deliberate exception** — a single, small, closely watched instance in a public subnet, whose entire job is being the one door an engineer can SSH through to then reach anything private.
- Same reasoning as `17September_Bastion.md`'s original jump-server lesson — just now codified as a reusable module instead of a one-off console build.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Bastion's role | The one SSH-reachable instance in an otherwise private network | Jump host for reaching the frontend/backend/RDS tiers |
| Blocks in the "wrong" file | Still works — Terraform merges every `.tf` file in a module | A real, harmless file-segregation inconsistency to notice |
| `public_subnet_id = module.network.public_subnet_ids[0]` | Bastion placed in the network module's first public subnet | Module composition in action again |
| `jump_server` root output | Surfaces the bastion's IP straight to the terminal | Same pattern as the mini project's `instance_public_ip` output |
