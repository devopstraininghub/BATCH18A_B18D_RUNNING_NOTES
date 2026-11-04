# Batch 18 — Terraform Running Notes: 4 November 2026

**Topic: The `acm` Module — 3-Tier Project, Module 9 of 9**

Friends, this is the last module in the capstone — the smallest one, and the only one that puts its `variable`, `output`, and `resource` blocks all in a single `main.tf` *by design*, since there's genuinely little enough here to justify splitting it up.

---

## 1. What this module builds

- One public ACM certificate, matching the certificate concepts from `29September_ACM.md` — now requested through Terraform instead of the console.

---

## 2. The entire module — one file

```hcl
variable "domain_name" {
  description = "Primary domain name for the ACM certificate"
  type        = string
}

variable "san_names" {
  description = "List of Subject Alternative Names (SANs) for the certificate"
  type        = list(string)
  default     = []
}

output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.b17facebook_cert.arn
}

resource "aws_acm_certificate" "b17facebook_cert" {
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = var.san_names

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [domain_validation_options]
  }
}
```
- `validation_method = "DNS"` — same DNS validation approach as `29September_ACM.md` §10-11: ACM hands back a CNAME record, you add it to your DNS zone, ACM checks for it, certificate gets issued.
- `subject_alternative_names = var.san_names` — this is how a **multi-domain** certificate (`29September_ACM.md` §14) gets built through Terraform: a list of extra domain names, on top of the primary `domain_name`.

⚠️ **The genuinely new concept here: the `lifecycle` block.**
- **`create_before_destroy = true`** — normally, when Terraform needs to replace a resource, it destroys the old one *first*, then creates the new one. For a certificate, that order would mean a window where **no valid certificate exists at all** — potentially breaking HTTPS for real users. `create_before_destroy` flips the order: build the replacement certificate first, and only remove the old one once the new one exists.
- **`ignore_changes = [domain_validation_options]`** — tells Terraform to stop treating changes to that one specific attribute as something it needs to "fix" on the next `apply`. ACM's own validation details can shift slightly over time on AWS's side, without anything actually being wrong — without this line, Terraform might keep proposing a pointless "fix" every single `plan`.

---

## 3. How the root project actually calls this module

```hcl
module "acm" {
  source      = "./modules/acm"
  domain_name = "b17facebook.xyz"
  san_names   = ["*.b17facebook.xyz"]
}
```
- `domain_name = "b17facebook.xyz"` (the apex domain) **plus** `san_names = ["*.b17facebook.xyz"]` (a wildcard SAN) — exactly the "request both explicitly" pattern from `29September_ACM.md` §14's wildcard-certificate gotcha: a wildcard alone never covers the bare apex domain, so both have to be requested together if you need both covered.
- ⚠️ As already flagged in `4November_Terraform_Module_Route53.md` §5 — this module's domain (`b17facebook.xyz`) doesn't match the `route53` module's default public zone (`b15facebook.xyz`). In a real deployment, a certificate only secures the exact domain(s) it was issued for — a mismatch like this would mean the certificate genuinely wouldn't cover the domain Route 53 is actually routing traffic for.
- Unlike every other module in this project, `acm`'s **output isn't referenced anywhere else** in the root `main.tf` — the certificate ARN is available (`module.acm.acm_certificate_arn`), but nothing here actually attaches it to the ALBs' listeners yet. In a fully finished version of this project, that ARN would feed into the `load_balancers` module, turning the plain-HTTP listeners from `4November_Terraform_Module_LoadBalancers.md` into real HTTPS ones — exactly the ALB + ACM certificate pattern from `29September_ACM.md` §18.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `validation_method = "DNS"` | Same DNS validation from `29September_ACM.md` | ACM hands back a CNAME to add to your zone |
| `subject_alternative_names` | How a multi-domain cert is built in Terraform | A list of extra domains alongside the primary one |
| `create_before_destroy` | Build the replacement before removing the original | Avoids a window with no valid certificate at all |
| `ignore_changes` | Stops Terraform "fixing" a specific attribute's drift | Used here for ACM's own validation details |
| Wildcard + apex together | `*.domain` never covers the bare `domain` on its own | Both requested explicitly, matching `29September_ACM.md` §14 |
| Unused output | The cert ARN exists but isn't wired into the ALB yet | Would need to feed into `load_balancers` for real HTTPS |
