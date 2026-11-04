# Batch 18 — Terraform Running Notes: 4 November 2026

**Topic: The `security` Module — 3-Tier Project, Module 2 of 9**

Friends, this is the smallest module in the capstone (`4November_Terraform_3TierProject.md`) — but almost every other module (`bastion`, `load_balancers`, `launch_templates`, `rds`) needs its output before they can be created.

---

## 1. What this module builds

- **One** Security Group — fully parameterized, so the same module code could build a tight, specific Security Group just as easily as the wide-open one actually used here.

---

## 2. `variables.tf`

```hcl
variable "vpc_id" {
  type = string
}

variable "sg_name" {
  type = string
}

variable "ingress_from_port" {
  type = number
}

variable "ingress_to_port" {
  type = number
}

variable "ingress_protocol" {
  type = string
}

variable "ingress_cidr_blocks" {
  type = list(string)
}

variable "egress_from_port" {
  type = number
}

variable "egress_to_port" {
  type = number
}

variable "egress_protocol" {
  type = string
}

variable "egress_cidr_blocks" {
  type = list(string)
}
```
- Every single rule detail — ports, protocol, CIDR blocks — is a variable, for **both** ingress and egress. Nothing about the actual rule is hardcoded in `main.tf` at all.

---

## 3. `main.tf`

```hcl
resource "aws_security_group" "main_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.ingress_from_port
    to_port     = var.ingress_to_port
    protocol    = var.ingress_protocol
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    from_port   = var.egress_from_port
    to_port     = var.egress_to_port
    protocol    = var.egress_protocol
    cidr_blocks = var.egress_cidr_blocks
  }

  tags = { Name = var.sg_name }
}
```
- One `ingress` block, one `egress` block — both built entirely from `var.*` values.

---

## 4. `output.tf`

```hcl
output "security_group_id" {
  value = aws_security_group.main_sg.id
}
```
- One output — the SG's ID — which is exactly what every other module needs to attach itself to this same Security Group.

---

## 5. How the root project actually calls this module

```hcl
module "security_group" {
  source = "./modules/security"

  vpc_id              = module.network.vpc_id
  sg_name             = "MAIN-security-group"
  ingress_from_port   = 0
  ingress_to_port     = 0
  ingress_protocol    = "-1"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_from_port    = 0
  egress_to_port      = 0
  egress_protocol     = "-1"
  egress_cidr_blocks  = ["0.0.0.0/0"]
}
```
⚠️ **Worth being direct about this, not just reproducing it:** the actual values used here — `from_port`/`to_port` both `0`, `protocol = "-1"` — mean **allow all ports, all protocols, from/to anywhere.** This is the same single-wide-open-SG pattern already flagged once before in `17September_MiniProject.md` as something to call out, not quietly copy. The *module itself* is fine — it's fully parameterized, so a real project could just as easily call it with `ingress_from_port = 443`, a specific protocol, and a specific source SG instead. The values chosen for *this particular call* are the part that's a shortcut, not the module's design.

- Every module after this one receives `module.security_group.security_group_id` as an input — `bastion`, `load_balancers`, `launch_templates`, and `rds` (as `db_security_group_id`) all attach to this exact same Security Group.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Fully parameterized SG module | No rule detail hardcoded — all via variables | Same module could build a tight SG or a wide-open one |
| `protocol = "-1"` | "All protocols" | Same meaning as in `16October_Terraform_MiniProject.md`'s egress rule |
| This module's one output | `security_group_id`, reused everywhere | Passed into bastion, ALB, launch templates, and RDS |
| The actual call made here | Allow-all in both directions | A deliberate shortcut for this project, not a best practice to copy |
