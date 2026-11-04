# Batch 18 — Terraform Running Notes: 4 November 2026

**Topic: The Capstone — A Full 3-Tier Architecture, Built With Terraform Modules**

Friends, today's practice brings together everything since `13October_Terraform.md`: file segregation, variables, modules, multi-region providers, and the VPC/ALB/ASG/RDS/Route53/ACM concepts from `AWS-CLOUD/`. We built it in two passes — a smaller **in-class** version to introduce the `network` module on its own, then the **complete** project with every tier wired together.

---

## 1. The architecture, in plain terms

Straight from the project's own `README.md`:

- **User Access Layer** — users reach the app through the internet; **Route 53** handles DNS.
- **Networking Layer** — one VPC, spanning **two Availability Zones** for high availability, split into:
  - **Public subnets** — NAT Gateway + a **Bastion Host** for SSH access.
  - **Web (frontend) subnets** — web servers in an Auto Scaling Group, behind a Load Balancer.
  - **App (backend) subnets** — application-layer servers, also in an Auto Scaling Group.
  - **Database subnets** — private, hosting **RDS**, in a DB Subnet Group for redundancy.
- **Load Balancing & Auto Scaling** — ALBs distribute traffic across AZs; ASGs scale instance count with demand.
- **Security** — only the Bastion is SSH-reachable from outside; private subnets reach the internet only via NAT; RDS has no direct internet access; everything spans multiple AZs for fault tolerance.

**Request flow:** `User → Route 53 → ALB → Web server (frontend) → App server (backend) → RDS → back up the same path.`

---

## 2. The project as eight modules

Following `26October_Terraform_Modules.md`'s pattern, every piece of this architecture is its own module, called once from the root `main.tf`:

| Module | What it builds |
|---|---|
| `network` | VPC, public + private subnets, Internet Gateway, NAT Gateway, route tables |
| `security` | A Security Group (ingress/egress rules, parameterized) |
| `bastion` | The jump-host EC2 instance in a public subnet |
| `load_balancers` | Two ALBs (frontend + backend), their listeners, and target groups |
| `launch_templates` | Launch Templates for frontend/backend instances, with their own user-data scripts |
| `asg` | Two Auto Scaling Groups (frontend + backend), using the launch templates above |
| `rds` | The RDS MySQL instance + its DB Subnet Group |
| `route53` | DNS records — both a private hosted zone (for RDS) and a public one (for the ALBs) |
| `acm` | The TLS certificate for the public domain |

**Root `main.tf` — how the modules connect to each other:**
```hcl
module "network" {
  source = "./modules/network"
  vpc_cidr = "170.20.0.0/16"

  public_subnets = [
    { cidr = "170.20.1.0/24", az = "us-east-1a" },
    { cidr = "170.20.2.0/24", az = "us-east-1b" }
  ]
  private_subnets = [
    { cidr = "170.20.3.0/24", az = "us-east-1a" },
    { cidr = "170.20.4.0/24", az = "us-east-1b" },
    { cidr = "170.20.5.0/24", az = "us-east-1a" },
    { cidr = "170.20.6.0/24", az = "us-east-1b" },
    { cidr = "170.20.7.0/24", az = "us-east-1a" },
    { cidr = "170.20.8.0/24", az = "us-east-1b" }
  ]
}

module "security_group" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
  # ...
}

module "rds" {
  source                = "./modules/rds"
  db_security_group_id  = module.security_group.security_group_id
  db_subnet_ids         = [module.network.private_subnet_ids[4], module.network.private_subnet_ids[5]]
}

module "alb" {
  source            = "./modules/load_balancers"
  security_group_id = module.security_group.security_group_id
  public_subnet_ids = [module.network.public_subnet_ids[1], module.network.public_subnet_ids[0]]
  vpc_id            = module.network.vpc_id
}

module "launch_templates" {
  source             = "./modules/launch_templates"
  security_group_id  = module.security_group.security_group_id
  frontend_user_data = "frontend.sh"
  backend_user_data  = "backend.sh"
}

module "autoscaling" {
  source            = "./modules/asg"
  frontend_subnet_ids = [module.network.private_subnet_ids[0], module.network.private_subnet_ids[1]]
  backend_subnet_ids  = [module.network.private_subnet_ids[2], module.network.private_subnet_ids[3]]
  frontend_tg_arn   = module.alb.frontend_tg_arn
  backend_tg_arn    = module.alb.backend_tg_arn
  frontend_lt_id    = module.launch_templates.frontend_lt_id
  backend_lt_id     = module.launch_templates.backend_lt_id
}

module "bastion" {
  source           = "./modules/bastion"
  public_subnet_id = module.network.public_subnet_ids[0]
  security_group_id = module.security_group.security_group_id
}

module "route53" {
  source       = "./modules/route53"
  vpc_id       = module.network.vpc_id
  rds_endpoint = module.rds.rds_endpoint
  alb_dns_name = module.alb.alb_backend_dns
}

module "acm" {
  source      = "./modules/acm"
  domain_name = "b17facebook.xyz"
}
```
- **This is module composition** — nothing here is one giant `main.tf`. Every `module.<name>.<output>` reference is one module handing a value to another, exactly the same `module` block mechanics as `26October_Terraform_Modules.md`, just now with **nine modules depending on each other** instead of one module called twice.
- The order modules are *written* in doesn't matter — just like plain resources (`16October_Terraform_MiniProject.md` §2), Terraform builds its dependency graph from these `module.x.y` references and figures out the real build order itself.

---

## 3. Genuinely new Terraform syntax, seen for the first time

### Splat expressions and `for` expressions — getting a list of IDs out of a list of resources
```hcl
# network/main.tf creates 2 public subnets via count:
resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  # ...
}

# network/output.tf needs to hand back a plain list of their IDs:
output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}
```
- `aws_subnet.public[*].id` — the **splat expression** (`[*]`). Reads: "for every instance of this resource created by `count`, grab its `.id`." Produces a plain list of IDs.
- `[for s in aws_subnet.public : s.id]` — a **`for` expression**, the more general, more flexible version of the same idea. Both lines above actually produce the same result here — the splat is the shorthand, the `for` expression is what you reach for when you need something more than just "grab one attribute from each" (e.g. filtering, or combining multiple attributes).

### `base64encode(file(...))` — launch templates need encoded user data
```hcl
resource "aws_launch_template" "frontend_lt" {
  user_data = base64encode(file("${path.module}/${var.frontend_user_data}"))
}
```
- ⚠️ **This is different from every `aws_instance.user_data` we've written before** (`16October_Terraform_MiniProject.md` onward used `user_data = file("facebook.sh")` directly, no encoding). An `aws_launch_template`'s `user_data` argument specifically requires **base64-encoded** text — `aws_instance.user_data` doesn't. Forgetting `base64encode(...)` here is a genuinely common real-world mistake.
- `path.module` is a Terraform built-in reference to **the directory the current module's own files live in** — needed here because `launch_templates` is a module, and `frontend.sh`/`backend.sh` live *inside that module's own folder*, not wherever the root project happens to be.

### The `lifecycle` block — controlling how Terraform replaces a resource
```hcl
resource "aws_acm_certificate" "b17facebook_cert" {
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [domain_validation_options]
  }
}
```
- `create_before_destroy = true` — when this certificate needs to be replaced, Terraform creates the **new** one first, and only destroys the old one after — instead of the normal destroy-then-create order. Useful for anything where even a brief gap (no valid certificate at all) would actually break something.
- `ignore_changes = [domain_validation_options]` — tells Terraform to stop treating changes to that specific attribute as something it needs to "fix" on the next `apply` — some ACM validation details change on their own over time and shouldn't trigger an unwanted update.

### Route 53 Private Hosted Zones — DNS that only works inside your VPC
```hcl
resource "aws_route53_zone" "rds_private" {
  name = var.rds_private_zone_name   # e.g. "rds.com"
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "rds_endpoint" {
  zone_id = aws_route53_zone.rds_private.zone_id
  name    = var.rds_record_name      # e.g. "book.rds.com"
  type    = "CNAME"
  records = [var.rds_endpoint]
}
```
- Every Route 53 zone we've built before (`28September_Route53.md`) was a **public** hosted zone, resolvable by anyone on the internet.
- Adding a `vpc { vpc_id = ... }` block makes it a **private hosted zone** instead — it only resolves for things *inside* that VPC. This project uses one specifically to give the real RDS endpoint (a long `*.rds.amazonaws.com` name) a short, friendly internal name (`book.rds.com`) that only the app servers inside the VPC can actually resolve — exactly the kind of internal-only DNS a public zone was never meant for.

---

## 4. Two real things worth learning from, not just copying

**1. A real, reused hardcoded RDS password.** The root `main.tf`'s `rds` module call, and the `backend.sh` user-data script, both contain the literal same password string for the RDS master user — with the module's own code comment already saying *"Consider using AWS Secrets Manager or Vault"* right next to it. This is exactly the mistake `2Nov_Vault.md` exists to solve — a real project is the moment that lesson actually matters, not just a one-off demo. **The fix isn't "use a stronger password" — it's "don't put the password in version-controlled code at all,"** which is the whole point of `2Nov_Vault.md`'s approach.

**2. Inconsistent file segregation across modules.** Most modules (`network`, `security`, `rds`, `load_balancers`, `asg`) correctly split their code into `main.tf`/`variables.tf`/`output.tf`, exactly as `21October_Terraform_Variables.md` taught. The `bastion` module, though, has its `variable` and `output` blocks written directly inside `main.tf`, leaving its own `variables.tf`/`output.tf` empty. **It still works** — Terraform doesn't actually care which file a block lives in within the same module, it reads every `.tf` file in the folder — but it's worth noticing as the kind of inconsistency that makes a real project harder to navigate later, even when nothing is technically broken.

---

## 5. Two passes at the same project

- **`3TIER-PROJECT-CLASS/`** — the in-class, build-along version: just the `network` module on its own, with the exact same VPC/subnet layout as the full project. This is where the `network` module itself (splat/`for` expressions and all) was actually worked through live.
- **`3tier_architecture_terraform-madhu/`** — the complete take-home version, with every module from §2 wired together, plus its own `README.md` and architecture diagram.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Module composition | Multiple modules, each feeding outputs into another's inputs | `module.network.vpc_id` passed into `module.security_group` |
| Splat expression `[*]` | Grab one attribute from every instance of a `count`-based resource | `aws_subnet.public[*].id` |
| `for` expression | The general-purpose version of the same idea | `[for s in aws_subnet.public : s.id]` |
| `base64encode(file(...))` | Required for `aws_launch_template.user_data`, unlike `aws_instance.user_data` | Forgetting this is a common real mistake |
| `path.module` | The current module's own directory | Needed so a module can find its own shell scripts |
| `lifecycle { create_before_destroy }` | Build the replacement before destroying the original | Used here for the ACM certificate |
| `lifecycle { ignore_changes }` | Stop Terraform from "fixing" a specific attribute's drift | ACM's `domain_validation_options` |
| Route 53 private hosted zone | A zone that only resolves inside a specific VPC | Giving the real RDS endpoint a short internal name |
| Hardcoded RDS password | The exact problem `2Nov_Vault.md` exists to solve | Found in both `main.tf` and `backend.sh` here |
| Inconsistent file segregation | Still works, but harder to navigate | `bastion` module's variables/outputs living in `main.tf` |
