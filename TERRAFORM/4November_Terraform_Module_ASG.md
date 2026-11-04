# Batch 18 — Terraform Running Notes: 4 November 2026

**Topic: The `asg` Module — 3-Tier Project, Module 6 of 9**

Friends, this is where the frontend and backend tiers actually get their running instances — this module takes the Launch Templates from `4November_Terraform_Module_LaunchTemplates.md` and the target groups from `4November_Terraform_Module_LoadBalancers.md`, and connects them into two real, scaling Auto Scaling Groups.

---

## 1. What this module builds

- **Two Auto Scaling Groups**: `frontend_asg` and `backend_asg`.

---

## 2. `variables.tf`

```hcl
variable "frontend_asg_name" {
  type = string
}

variable "backend_asg_name" {
  type = string
}

variable "asg_min_size" {
  type = number
}

variable "asg_max_size" {
  type = number
}

variable "asg_desired_capacity" {
  type = number
}

variable "frontend_subnet_ids" {
  type = list(string)
}

variable "backend_subnet_ids" {
  type = list(string)
}

variable "frontend_tg_arn" {
  type = string
}

variable "backend_tg_arn" {
  type = string
}

variable "frontend_lt_id" {
  type = string
}

variable "backend_lt_id" {
  type = string
}
```
- `asg_min_size`/`asg_max_size`/`asg_desired_capacity` — the exact same three-number pattern from `8September_SNS_ASG.md`'s ASG coverage, just now driven by variables instead of typed directly into the console.

---

## 3. `main.tf`

```hcl
resource "aws_autoscaling_group" "frontend_asg" {
  name                = var.frontend_asg_name
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = var.frontend_subnet_ids
  target_group_arns   = [var.frontend_tg_arn]

  launch_template {
    id      = var.frontend_lt_id
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "backend_asg" {
  name                = var.backend_asg_name
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = var.backend_subnet_ids
  target_group_arns   = [var.backend_tg_arn]

  launch_template {
    id      = var.backend_lt_id
    version = "$Latest"
  }
}
```
- `vpc_zone_identifier` — the (slightly unusually-named) argument that actually takes the **subnet IDs** the ASG is allowed to launch instances into.
- `target_group_arns = [var.frontend_tg_arn]` — **this is the line that actually registers new instances into the ALB's target group**, automatically, every time the ASG launches one. Nobody has to manually attach an instance to a target group.
- `launch_template { id = ..., version = "$Latest" }` — `"$Latest"` means: if the Launch Template is ever updated later, **new** instances the ASG launches will pick up the new version automatically — existing running instances aren't touched until they're replaced.

---

## 4. `output.tf`

```hcl
output "frontend_asg_id" {
  value = aws_autoscaling_group.frontend_asg.id
}

output "backend_asg_id" {
  value = aws_autoscaling_group.backend_asg.id
}
```

---

## 5. How the root project actually calls this module

```hcl
module "autoscaling" {
  source               = "./modules/asg"
  frontend_asg_name    = "frontend-asg"
  backend_asg_name     = "backend-asg"
  asg_min_size         = 1
  asg_max_size         = 1
  asg_desired_capacity = 1
  frontend_subnet_ids  = [module.network.private_subnet_ids[0], module.network.private_subnet_ids[1]]
  backend_subnet_ids   = [module.network.private_subnet_ids[2], module.network.private_subnet_ids[3]]
  frontend_tg_arn      = module.alb.frontend_tg_arn
  backend_tg_arn       = module.alb.backend_tg_arn
  frontend_lt_id       = module.launch_templates.frontend_lt_id
  backend_lt_id        = module.launch_templates.backend_lt_id
}
```
- This is **the module with the most inputs coming from other modules** in the whole project — it needs subnets from `network`, a target group ARN from `alb`, and a launch template ID from `launch_templates`, all at once. It's the clearest single example of module composition (`4November_Terraform_3TierProject.md` §2) anywhere in this project.
- `frontend_subnet_ids`/`backend_subnet_ids` use private subnets **0-1** and **2-3** — leaving private subnets **4-5** free, which is exactly what the `rds` module (`4November_Terraform_Module_RDS.md`) uses next.
- `asg_min_size = asg_max_size = asg_desired_capacity = 1` — fixed at exactly one instance each here, for a learning build; in a real production setup these three would typically differ, to actually let the ASG scale.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `vpc_zone_identifier` | The subnets an ASG is allowed to launch into | Private subnets, 2 per tier |
| `target_group_arns` | Auto-registers new instances into the ALB's target group | No manual target-group attachment needed |
| `launch_template { version = "$Latest" }` | New instances always use the newest template version | Existing instances untouched until replaced |
| Most composed module in the project | Needs inputs from 3 other modules at once | `network` + `alb` + `launch_templates` all feed into this one |
| Private subnets 0-3 used here | Leaves subnets 4-5 free for RDS | Deliberate tier-by-tier subnet allocation |
