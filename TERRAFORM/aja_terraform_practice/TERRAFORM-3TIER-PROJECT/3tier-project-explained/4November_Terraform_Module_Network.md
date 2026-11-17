# Batch 18 — Terraform Running Notes: 4 November 2026

**Topic: The `network` Module — 3-Tier Project, Module 1 of 9**

Friends, this is the first and most foundational module of the capstone (`4November_Terraform_3TierProject.md`) — everything else (security groups, bastion, load balancers, ASGs, RDS) gets built **inside** the VPC this module creates. Nothing else can exist without this module running first.

---

## 1. What this module builds

- One **VPC**.
- A configurable number of **public subnets** and **private subnets**, each in a specific Availability Zone.
- One **Internet Gateway** (for the public subnets).
- One **NAT Gateway** + its **Elastic IP** (so private subnets can still reach the internet outbound).
- Separate **public and private route tables**, each correctly associated with their matching subnets.

---

## 2. `variables.tf` — what this module needs from whoever calls it

```hcl
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  description = "List of public subnets with CIDR and Availability Zone"
  type = list(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "List of private subnets with CIDR and Availability Zone"
  type = list(object({
    cidr = string
    az   = string
  }))
}
```
- `public_subnets`/`private_subnets` both use **`list(object({...}))`** — exactly the type from `3November_Terraform_VariableTypes.md` §8, the one called out there as the most-used type in real projects. This module is the proof: without it, you'd need a separate `public_subnet_cidrs` list *and* a separate `availability_zones` list, and keep them lined up by position — error-prone, and exactly the commented-out approach you can still see left in the file as a "don't do it this way" reminder.
- `region` has a `default` — optional. The three others don't — **required**, per `21October_Terraform_Variables.md` §4's "no default = required" rule.

---

## 3. `main.tf` — the actual resources

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "MAIN-3-TIER-VPC" }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index].cidr
  availability_zone       = var.public_subnets[count.index].az
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet-${count.index + 1}" }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index].cidr
  availability_zone = var.private_subnets[count.index].az
  tags = { Name = "private-subnet-${count.index + 3}" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = { Name = "nat-gateway" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-route-table" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "private-route-table" }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
```

**Reading it top to bottom:**
- `enable_dns_support`/`enable_dns_hostnames = true` on the VPC — needed for anything that depends on DNS working correctly *inside* the VPC (this matters later for the `route53` module's private hosted zone).
- `count = length(var.public_subnets)` — one subnet created **per entry** in the list, however many that turns out to be. Same `count` + `length()` pattern taught in `3November_Terraform_VariableTypes.md` §5/§8.
- `var.public_subnets[count.index].cidr` / `.az` — for subnet number `count.index`, pull out *that* entry's `cidr` and `az` fields. This is list-indexing (`[count.index]`) combined with object field access (`.cidr`), the exact combo covered in `3November_Terraform_VariableTypes.md` §8.
- `map_public_ip_on_launch = true` on public subnets only — this is what actually makes a subnet "public" in the practical sense: any instance launched into it gets a public IP automatically.
- The **public route table** sends `0.0.0.0/0` traffic to the **Internet Gateway**. The **private route table** sends the same `0.0.0.0/0` traffic to the **NAT Gateway** instead — same destination, completely different path, which is the entire difference between a public and private subnet in AWS.
- `aws_nat_gateway` must sit in a **public** subnet (`aws_subnet.public[0].id`) even though it exists to serve **private** subnets — a detail that trips people up the first time they build this by hand too.

---

## 4. `output.tf` — handing values to the other 8 modules

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}
```
- `[for s in aws_subnet.public : s.id]` — a **`for` expression**: "for every subnet this module created, give me back just its `.id`, as a plain list." This is how a module with a variable number of subnets (driven by `count`) can still hand back one clean, predictable list of IDs to whoever calls it.
- This module's file also shows the shorthand version of the same idea — `aws_subnet.public[*].id`, the **splat expression** — kept as an alternate output (`public_subnets`) right alongside the `for`-expression version, so both forms are visible side by side.

---

## 5. How the root project actually calls this module

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
```
- **6 private subnets, in pairs across 2 AZs** — this is deliberate: 2 for the frontend tier, 2 for the backend tier, 2 for the database tier (see `4November_Terraform_Module_ASG.md`/`4November_Terraform_Module_RDS.md` for exactly which pair each tier actually uses).
- Every other module in this project reaches into this one's outputs — e.g. `module.network.vpc_id`, `module.network.private_subnet_ids[4]` — this module has to exist and finish first, which Terraform figures out automatically from those references (`16October_Terraform_MiniProject.md` §2's implicit dependency graph, now operating across modules instead of just resources).

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `list(object({cidr, az}))` | One variable, many subnets, each with its own CIDR + AZ | Avoids keeping two separate lists in sync by position |
| `count = length(var.x)` | Create exactly as many resources as there are list entries | 2 public subnets, 6 private subnets |
| `var.x[count.index].field` | Combine list indexing with object field access | Each subnet gets its own correct `cidr` and `az` |
| Public vs private route table | Same `0.0.0.0/0` destination, different gateway | IGW for public, NAT Gateway for private |
| NAT Gateway placement | Must live in a public subnet, even though it serves private ones | A common first-time mistake when building this by hand |
| `[for s in x : s.id]` | Turn a `count`-based resource into one clean list of IDs | Lets every other module just ask for `network.public_subnet_ids` |
| This module's outputs | What every other module in the project depends on | `vpc_id`, `public_subnet_ids`, `private_subnet_ids` |
