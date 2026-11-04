# Batch 18 — Terraform Running Notes: 4 November 2026

**Topic: The `load_balancers` Module — 3-Tier Project, Module 4 of 9**

Friends, this module builds **two** separate Application Load Balancers — one for the frontend (web) tier, one for the backend (app) tier — matching the "web subnet behind an ALB, app subnet behind its own ALB" split described in the capstone's architecture overview.

---

## 1. What this module builds

- **Two ALBs**: `frontend_alb` and `backend_alb`.
- **Two listeners** — one per ALB, both on port 80.
- **Two target groups** — one per ALB, where the actual EC2 instances (from the `asg` module) get registered.

---

## 2. `variables.tf`

```hcl
variable "frontend_alb_name" {
  type = string
}

variable "backend_alb_name" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "frontend_tg_name" {
  type = string
}

variable "backend_tg_name" {
  type = string
}

variable "vpc_id" {
  type = string
}
```
- `public_subnet_ids` — a `list(string)`, because an ALB needs **at least two subnets in two different AZs** to be valid at all; a single subnet ID wouldn't be enough.

---

## 3. `main.tf`

```hcl
resource "aws_lb" "frontend_alb" {
  name               = var.frontend_alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids
  tags = { Name = var.frontend_alb_name }
}

resource "aws_lb" "backend_alb" {
  name               = var.backend_alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids
  tags = { Name = var.backend_alb_name }
}

resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

resource "aws_lb_target_group" "frontend_tg" {
  name     = var.frontend_tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags = { Name = var.frontend_tg_name }
}

resource "aws_lb_target_group" "backend_tg" {
  name     = var.backend_tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags = { Name = var.backend_tg_name }
}
```
- `internal = false` on both ALBs — these are internet-facing, matching the architecture's picture of users reaching the frontend ALB directly, and the backend ALB routing internal frontend→backend traffic.
- Each ALB has **its own** listener and **its own** target group — frontend traffic never gets mixed into the backend's target group, or vice versa.
- Note: nothing's actually registered into these target groups **yet** — that's the `asg` module's job (`4November_Terraform_Module_ASG.md`), which is why this module's target group ARNs get passed forward as outputs.

---

## 4. `output.tf`

```hcl
output "frontend_alb_arn" {
  value = aws_lb.frontend_alb.arn
}

output "backend_alb_arn" {
  value = aws_lb.backend_alb.arn
}

output "frontend_tg_arn" {
  value = aws_lb_target_group.frontend_tg.arn
}

output "backend_tg_arn" {
  value = aws_lb_target_group.backend_tg.arn
}

output "alb_frontend_dns" {
  value = aws_lb.frontend_alb.dns_name
}

output "alb_backend_dns" {
  value = aws_lb.backend_alb.dns_name
}
```
- The two `*_tg_arn` outputs are what the `asg` module actually needs — an Auto Scaling Group attaches to a target group by its ARN.
- The two `*_dns` outputs are what the `route53` module needs — to create a CNAME record pointing a friendly domain name at each ALB's own AWS-generated DNS name (same idea as `28September_Route53.md`'s `myapp.com → ALB DNS name` pattern).

---

## 5. How the root project actually calls this module

```hcl
module "alb" {
  source            = "./modules/load_balancers"
  frontend_alb_name = "frontend-alb"
  backend_alb_name  = "backend-alb"
  security_group_id = module.security_group.security_group_id
  public_subnet_ids = [module.network.public_subnet_ids[1], module.network.public_subnet_ids[0]]
  frontend_tg_name  = "frontend-tg"
  backend_tg_name   = "backend-tg"
  vpc_id            = module.network.vpc_id
}
```
- Both ALBs share the **same two public subnets** from the `network` module — nothing stops two separate ALBs from living in the same subnets, since they're different resources entirely, just both reachable from the same public subnet range.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Two ALBs, one module | Same reusable resources, built twice with different names | `frontend_alb` and `backend_alb` |
| ALB needs 2+ subnets, 2+ AZs | Why `public_subnet_ids` is a list, not a single string | Matches the `network` module's 2 public subnets |
| Listener → forward → target group | How a request actually reaches a backend instance | Port 80, HTTP, forwarded to `frontend_tg`/`backend_tg` |
| `*_tg_arn` outputs | What the `asg` module needs to attach instances | Passed into `module.autoscaling` |
| `*_dns` outputs | What the `route53` module needs for CNAME records | Gives each ALB a friendly domain name |
