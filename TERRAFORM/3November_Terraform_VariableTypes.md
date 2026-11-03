# Batch 18 — Terraform Running Notes: 3 November 2026

**Topic: Terraform Variable Data Type Constraints**

Friends, every variable we've written since `21October_Terraform_Variables.md` has used `type = string` or `type = number` without really dwelling on *why* that line matters. Today we slow down on exactly that — the full set of data types Terraform variables can be constrained to, from the simplest (`string`) to the one real projects reach for constantly (`list(object)`).

---

## 1. What are data type constraints?

- A **data type constraint** defines what *kind* of value a variable is allowed to accept.

| Type | Holds |
|---|---|
| `string` | Text only |
| `number` | Numbers only |
| `bool` | `true`/`false` only |
| `list` | Multiple values, in order |
| `map` | Key-value pairs |
| `object` | Structured data — several named fields together |

**Why they matter:**
- Avoid mistakes — catch the wrong *kind* of value before it ever reaches AWS.
- Make code predictable — anyone reading the variable knows exactly what shape of value to supply.
- Improve readability.

---

## 2. `string` — text

**In `variables.tf`** — declare the variable and its type:
```hcl
variable "key_name" {
  type = string
}
```

**In `main.tf`** — use it with `var.<name>`:
```hcl
resource "aws_instance" "web" {
  key_name = var.key_name
}
```

**In `terraform.tfvars`** — supply the actual value:
```hcl
key_name = "mckey"
```
- `variables.tf` only defines the **shape** (a string) — it never contains a real value.
- `main.tf` never hardcodes the value either — it just asks for `var.key_name`, whatever that turns out to be.
- `terraform.tfvars` is the **only** place the real value `"mckey"` actually lives — change it there, and every place `var.key_name` is used picks up the new value automatically.

**Real-time use:** AWS region, resource names, environment name (`dev`/`prod`), EC2 key pair names.

---

## 3. `number`

**In `variables.tf`:**
```hcl
variable "instance_count" {
  type = number
}
```

**In `main.tf`:**
```hcl
resource "aws_instance" "web" {
  count = var.instance_count
}
```

**In `terraform.tfvars`:**
```hcl
instance_count = 6
```
- Six instances get created — change the `6` in `terraform.tfvars` to `2`, and the **same** `main.tf` creates two instead, with no code edit at all.
- If someone typed `instance_count = "six"` in `terraform.tfvars` instead, Terraform rejects it immediately — `"six"` is a string, not a `number`, and the type constraint catches that before anything is ever sent to AWS.

**Real-time use:** number of servers, disk size (GB), Auto Scaling limits.

---

## 4. `bool` — true/false

**In `variables.tf`:**
```hcl
variable "enable_public_ip" {
  type = bool
}
```

**In `main.tf`:**
```hcl
resource "aws_instance" "web" {
  associate_public_ip_address = var.enable_public_ip
}
```

**In `terraform.tfvars`:**
```hcl
enable_public_ip = true
```
- Flip this single `true`/`false` in `terraform.tfvars`, and every instance built from this `main.tf` gets (or stops getting) a public IP — no digging through the resource block itself to change behavior.

**Real-time use:** turning a feature on or off, enabling/disabling a public IP, enabling/disabling S3 versioning (`21September_S3.md`).

---

## 5. `list` — ordered values

**In `variables.tf`:**
```hcl
variable "subnet_cidrs" {
  type = list(string)
}
```

**In `main.tf`:**
```hcl
resource "aws_subnet" "public" {
  count      = length(var.subnet_cidrs)
  cidr_block = var.subnet_cidrs[count.index]
}
```

**In `terraform.tfvars`:**
```hcl
subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]
```
- `length(var.subnet_cidrs)` reads how many CIDRs were supplied (2 here) — `count` then creates one subnet per entry.
- `var.subnet_cidrs[count.index]` picks out the CIDR for *that specific* subnet — index `0` gets `"10.0.1.0/24"`, index `1` gets `"10.0.2.0/24"`.
- Add a third CIDR to the list in `terraform.tfvars`, and `main.tf` automatically creates a third subnet too — nothing in `main.tf` itself needs to change.

**Real-time use:** subnets, Availability Zones, Security Group IDs — anything where you need several values of the *same* type, in a specific order.

---

## 6. `map` — key-value pairs

**In `variables.tf`:**
```hcl
variable "tags" {
  type = map(string)
}
```

**In `main.tf`:**
```hcl
resource "aws_instance" "web" {
  tags = var.tags
}
```

**In `terraform.tfvars`:**
```hcl
tags = {
  Name  = "web-server"
  Env   = "dev"
  owner = "madhu"
}
```
- `main.tf` just points `tags` at `var.tags` — it has no idea, and doesn't need to know, how many key-value pairs are actually inside it.
- Add a fourth tag (say, `CostCenter = "ops"`) in `terraform.tfvars`, and it shows up on the instance with no `main.tf` change at all.

**Real-time use:** AWS resource tagging — this is exactly the shape every `tags = { Name = ... }` block we've written since `16October_Terraform_MiniProject.md` has actually been, just not formally typed as a variable until now.

---

## 7. `object` — structured data

**In `variables.tf`:**
```hcl
variable "server_config" {
  type = object({
    name  = string
    size  = string
    count = number
  })
}
```

**In `main.tf`:**
```hcl
resource "aws_instance" "web" {
  instance_type = var.server_config.size
  count         = var.server_config.count

  tags = {
    Name = var.server_config.name
  }
}
```

**In `terraform.tfvars`:**
```hcl
server_config = {
  name  = "web"
  size  = "t2.micro"
  count = 2
}
```
- Unlike a `map`, every field in an `object` can have its **own type** — `name` and `size` are strings, `count` is a number, all inside one variable.
- Note the `.` syntax in `main.tf`: `var.server_config.size`, `var.server_config.count` — you reach into one named field at a time, instead of passing the whole object around as one blob.

**Real-time use:** a single server's configuration, database settings, an application's config — anywhere several *related but differently-typed* values travel together.

---

## 8. `list(object(...))` — the one that matters most in real projects

**In `variables.tf`:**
```hcl
variable "public_subnets" {
  description = "List of public subnets with CIDR and Availability Zone"
  type = list(object({
    cidr = string
    az   = string
  }))
}
```

**In `main.tf`:**
```hcl
resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  cidr_block        = var.public_subnets[count.index].cidr
  availability_zone = var.public_subnets[count.index].az
}
```

**In `terraform.tfvars`:**
```hcl
public_subnets = [
  { cidr = "10.0.1.0/24", az = "us-east-1a" },
  { cidr = "10.0.2.0/24", az = "us-east-1b" }
]
```
- A **list of objects** — each entry in the list is itself a small structured object with its own `cidr` and `az`.
- `var.public_subnets[count.index]` picks out **one object** from the list (e.g. `{ cidr = "10.0.1.0/24", az = "us-east-1a" }`), and `.cidr`/`.az` then reach into that one object's fields — combining list-indexing (§5) with object field access (§7) in a single line.
- Add a third `{ cidr = ..., az = ... }` entry in `terraform.tfvars`, and a third subnet gets created with its own CIDR *and* its own AZ — `main.tf` doesn't change at all.

**Real-time use:** multiple subnets across multiple Availability Zones, multiple servers each with their own settings, multiple environments — **this is called out as the most-used type in real projects**, because almost everything in AWS that comes in sets (subnets, instances, listener rules) needs exactly this "list of small structured things" shape.

---

## 8a. Usage inside a module

Typed variables don't stop working once a **module** (`26October_Terraform_Modules.md`) is involved — a module has its **own** `variables.tf`, and the root project passes values into it exactly the same way `terraform.tfvars` feeds the root's own variables.

**The module itself — `ec2-module/variables.tf`:**
```hcl
variable "instance_type" {
  type = string
}

variable "instance_count" {
  type = number
}
```

**The module itself — `ec2-module/main.tf`:**
```hcl
resource "aws_instance" "server" {
  instance_type = var.instance_type
  count         = var.instance_count
}
```
- Exactly the same pattern as every section above — the module's own `main.tf` reads `var.instance_type`/`var.instance_count`, and has no idea where those values ultimately came from.

**The root project — `main.tf`, calling the module:**
```hcl
module "dev_webserver" {
  source         = "./ec2-module"
  instance_type  = var.dev_instance_type
  instance_count = var.dev_instance_count
}
```

**The root project — `variables.tf`:**
```hcl
variable "dev_instance_type" {
  type = string
}

variable "dev_instance_count" {
  type = number
}
```

**The root project — `terraform.tfvars`:**
```hcl
dev_instance_type  = "t2.micro"
dev_instance_count = 1
```

**How the value actually travels, end to end:**
```
terraform.tfvars (root)
  dev_instance_type = "t2.micro"
        │
        ▼
root variables.tf declares var.dev_instance_type (type = string)
        │
        ▼
root main.tf's module "dev_webserver" block passes it in as instance_type = var.dev_instance_type
        │
        ▼
ec2-module/variables.tf declares its OWN var.instance_type (type = string)
        │
        ▼
ec2-module/main.tf uses var.instance_type to actually build the instance
```
- Notice the **root's** variable (`dev_instance_type`) and the **module's** variable (`instance_type`) don't have to share a name — the `module` block's `instance_type = var.dev_instance_type` line is what connects them. The type (`string`) has to match on both sides, but the variable *name* is local to whichever `variables.tf` it's declared in.
- This is exactly how `26October_Terraform_Modules.md`'s `dev_webserver`/`prod-server` module calls actually received their different `instance_type`/`ami_id`/`tag_server_name` values — each one could just as easily have come from a typed root variable instead of a literal string, using this same pattern.

---

## 9. Why type constraints are actually important

**1. Prevent errors:**
```hcl
instance_count = "three"   # ❌ wrong type — number expected, got a string
```

**2. Validate structure:**
```hcl
public_subnets = "10.0.1.0/24"   # ❌ wrong shape — a list was expected, not a single string
```

**3. Improve readability.**

**4. Help teamwork** — a teammate can look at a variable's declared type and immediately know the exact input format expected, without having to go read how it's used everywhere downstream.

---

## 10. Simple analogy

| Terraform type | Real-life example |
|---|---|
| `string` | A name |
| `number` | An age |
| `bool` | Yes or no |
| `list` | A shopping list |
| `map` | A dictionary (word → meaning) |
| `object` | A form with fields |
| `list(object)` | Multiple filled-out forms |

---

## 11. Final summary

- Terraform variables need the **correct data type** to behave predictably.
- Types ensure the input format is actually correct, not just "whatever happened to be typed in."
- Common types: `string`, `number`, `bool`, `list`, `map`, `object`.
- **Most used in real projects: `list(object)`.**

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `string` | Text only | AWS region, resource names |
| `number` | Numeric values only | Instance count, disk size |
| `bool` | `true`/`false` only | Enable/disable a public IP |
| `list` | Multiple values, in order | A list of subnet CIDRs |
| `map` | Key-value pairs | Resource tags |
| `object` | Structured data, fields can have different types | One server's full configuration |
| `list(object)` | A list of structured objects — the most-used real-world type | Multiple subnets, each with its own CIDR + AZ |
| The three-file flow | `variables.tf` (shape) → `main.tf` (`var.x` usage) → `terraform.tfvars` (real value) | Change the value in one place, every usage updates |
| Variable into a module | A `module` block's argument connects a root variable to the module's own, same-named-or-not | `module "x" { instance_type = var.dev_instance_type }` |
| Why types matter | Catches the wrong kind/shape of value before it's ever applied | `instance_count = "three"` fails immediately |
