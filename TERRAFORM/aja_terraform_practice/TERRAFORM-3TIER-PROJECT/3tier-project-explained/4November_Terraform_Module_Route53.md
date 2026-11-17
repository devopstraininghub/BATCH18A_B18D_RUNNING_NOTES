# Batch 18 — Terraform Running Notes: 4 November 2026

**Topic: The `route53` Module — 3-Tier Project, Module 8 of 9**

Friends, this module does **two different DNS jobs at once** — giving the RDS database a friendly internal name, and giving the public ALBs friendly public domain names — using a kind of hosted zone we haven't built before: a **private** one.

---

## 1. What this module builds

- One **private** hosted zone, scoped to this VPC only — for the RDS endpoint.
- One **public** hosted zone — for the frontend and backend ALBs.
- Three CNAME records in total: one in the private zone (RDS), two in the public zone (frontend ALB, backend ALB).

---

## 2. `variables.tf`

```hcl
variable "vpc_id" {
  type = string
}

variable "rds_private_zone_name" {
  type    = string
  default = "rds.com"
}

variable "rds_record_name" {
  type    = string
  default = "book.rds.com"
}

variable "rds_endpoint" {
  type = string
}

variable "public_zone_name" {
  type    = string
  default = "b15facebook.xyz"
}

variable "alb_record_name" {
  type    = string
  default = "api.b15facebook.xyz"
}

variable "alb_dns_name" {
  type = string
}

variable "alb_dns_frontend_record" {
  type    = string
  default = "login.b15facebook.xyz"
}

variable "alb_front_dns_name" {
  type = string
}
```

---

## 3. `main.tf`

```hcl
# Private Hosted Zone for RDS
resource "aws_route53_zone" "rds_private" {
  name = var.rds_private_zone_name
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "rds_endpoint" {
  zone_id = aws_route53_zone.rds_private.zone_id
  name    = var.rds_record_name
  type    = "CNAME"
  ttl     = 100
  records = [var.rds_endpoint]
}

# Public Hosted Zone for the app's domain
resource "aws_route53_zone" "public_zone" {
  name = var.public_zone_name
}

resource "aws_route53_record" "alb_backend" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = var.alb_record_name
  type    = "CNAME"
  ttl     = 300
  records = [var.alb_dns_name]
}

resource "aws_route53_record" "alb_frontend" {
  zone_id = aws_route53_zone.public_zone.zone_id
  name    = var.alb_dns_frontend_record
  type    = "CNAME"
  ttl     = 300
  records = [var.alb_front_dns_name]
}
```

⚠️ **The genuinely new concept here: Route 53 Private Hosted Zones.** Every hosted zone built in `28September_Route53.md` was **public** — resolvable by anyone, anywhere. Adding a `vpc { vpc_id = ... }` block to `aws_route53_zone` makes it **private** instead: it only resolves for things *inside that specific VPC*. That's exactly why it's used for the RDS endpoint here — `app-db.xxxxx.us-east-1.rds.amazonaws.com` is long and AWS-generated; `book.rds.com` is short and memorable, but there's no reason (and real risk) in making a database's address resolvable from the public internet. A private zone gives the app servers inside the VPC the convenience, without giving the whole internet the information.
- The **public** zone, by contrast, is exactly the kind already covered in `28September_Route53.md` — used here for the two things that genuinely do need to be internet-resolvable: the frontend and backend ALBs.
- All three records are **CNAME**, not **A** records — each points at another DNS name (an ALB's DNS name, or the raw RDS endpoint), not directly at an IP address — consistent with `28September_Route53.md` §4's CNAME definition.

---

## 4. `output.tf`

```hcl
output "rds_private_zone_id" {
  value = aws_route53_zone.rds_private.zone_id
}

output "rds_record_fqdn" {
  value = aws_route53_record.rds_endpoint.fqdn
}

output "public_zone_id" {
  value = aws_route53_zone.public_zone.zone_id
}

output "alb_record_fqdn" {
  value = aws_route53_record.alb_backend.fqdn
}
```
- `.fqdn` — the record's **Fully Qualified Domain Name**, i.e. the complete, final domain name (`book.rds.com`, not just the "book" part) — useful to have as an output if some other part of the project needed to reference the exact full name.

---

## 5. How the root project actually calls this module

```hcl
module "route53" {
  source             = "./modules/route53"
  vpc_id             = module.network.vpc_id
  rds_endpoint       = module.rds.rds_endpoint
  alb_dns_name       = module.alb.alb_backend_dns
  alb_front_dns_name = module.alb.alb_frontend_dns
}
```
- This module is the **last** one that depends on almost everything else — it needs the VPC (from `network`), the real RDS endpoint (from `rds`), and both ALBs' DNS names (from `alb`) before it can create a single record.
- ⚠️ **Worth noting plainly, not glossing over:** this module's own `variables.tf` defaults to `public_zone_name = "b15facebook.xyz"`, while the separate `acm` module (`4November_Terraform_Module_ACM.md`) uses `"b17facebook.xyz"` for its certificate's domain. Two different placeholder domains, used in two different modules of the same project — a small inconsistency worth being aware of if asked, not something that breaks anything on its own, but exactly the kind of mismatch that would actually matter in a real deployment (a certificate for one domain doesn't secure a different domain).

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Private hosted zone | A hosted zone that only resolves inside one VPC | `vpc { vpc_id = ... }` added to `aws_route53_zone` |
| Why it's used for RDS | Gives a long AWS endpoint a short internal name | `book.rds.com` instead of the raw `*.rds.amazonaws.com` |
| Public hosted zone | Same kind already covered in `28September_Route53.md` | Used for the internet-facing frontend/backend ALBs |
| All records are CNAME | Point at another name, not an IP | Matches the A-record vs CNAME distinction from earlier |
| `.fqdn` output | The complete final domain name | `aws_route53_record.rds_endpoint.fqdn` |
| Domain mismatch across modules | `route53` defaults to `b15facebook.xyz`, `acm` to `b17facebook.xyz` | Worth knowing about, not urgent to fix |
