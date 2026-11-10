# Batch 18 — Terraform Running Notes: 10 November 2026

**Topic: Terraform `for_each`**

Friends, every "multiple of the same thing" example so far (`4November_Terraform_Module_Network.md`'s subnets, `26October_Terraform_Modules.md`'s module calls) used **`count`** — plain numbers, `[0]`, `[1]`, `[2]`. Today's topic, **`for_each`**, is the other way to create multiples — using **names** instead of numbers. We'll build the exact same "one EC2 per environment" idea **three different ways**, so the differences are concrete, not just theoretical.

---

## 1. What is `for_each`?

- `for_each` is a **meta-argument** — same category as `count`, just a different approach.
- It creates **multiple instances of a resource or module**, driven by a **map** or a **set of strings** — not a plain number.
- Instead of writing the same `resource` block three times, you write it **once**, and `for_each` repeats it once per entry.

**Why use it:**
- Avoid duplicate Terraform code.
- Manage each resource **individually** (each one gets tracked separately in state).
- Give each resource different names and settings.
- Make the code reusable and scalable.

---

## 2. The syntax

```hcl
resource "RESOURCE_TYPE" "RESOURCE_NAME" {
  for_each = MAP_OR_SET

  ARGUMENT = each.value
}
```

- `for_each = ...` — tells Terraform to create one instance **per entry** in the map or set.
- `each.key` — the current entry's **key** (for a map) or the element itself (for a set).
- `each.value` — the current entry's **value** (for a map) or the same element again (for a set).

---

## 3. Hands-on — the exact same idea, built three different ways

Today's practice built "one EC2 instance per environment" **three separate times**, each with a slightly different `for_each` input type — this is the clearest way to actually see how `each.key`/`each.value` change shape depending on what you hand `for_each`.

### Version 1 — `for_each` over a **set of strings** (the simplest case)

**`variables.tf`:**
```hcl
variable "environments" {
  description = "Unique environment names"
  type        = set(string)
  default     = ["dev", "qa", "prod"]
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
```
- ⚠️ **Notice `type = set(string)` directly on the variable** — the list `["dev", "qa", "prod"]` written in the `default` gets automatically treated as a set because the variable's own *type* says so. You don't need to wrap it in `toset()` here — that function is only needed when you're converting a **plain list value** into a set *inline*, not when the variable itself is already typed as one.

**`main.tf`:**
```hcl
resource "aws_instance" "web" {
  for_each = var.environments

  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true

  tags = {
    Name        = "mindcircuit-${each.value}"
    Environment = each.value
    ManagedBy   = "Terraform"
  }
}
```
- With a **set of strings**, `each.key` and `each.value` are **the exact same thing** — just the string itself (`"dev"`, `"qa"`, or `"prod"`). This file only uses `each.value`, but `each.key` would print the identical value.
- **What actually gets created:** `aws_instance.web["dev"]`, `aws_instance.web["qa"]`, `aws_instance.web["prod"]` — every instance uses the **same** `instance_type`, just a different name/tag.

---

### Version 2 — `for_each` over a **map of strings** (key → a single value)

**`variables.tf`:**
```hcl
variable "instances" {
  description = "Map of environment names to EC2 instance types"
  type        = map(string)
  default = {
    dev  = "t3.micro"
    qa   = "t3.micro"
    prod = "t3.small"
  }
}
```

**`main.tf`:**
```hcl
resource "aws_instance" "web" {
  for_each = var.instances

  ami                         = var.ami_id
  instance_type               = each.value
  associate_public_ip_address = true

  tags = {
    Name        = "mindcircuit-${each.key}"
    Environment = each.key
    ManagedBy   = "Terraform"
  }
}
```
- Now `each.key` and `each.value` are genuinely **different** — `each.key` is `"dev"`/`"qa"`/`"prod"`, and `each.value` is that key's matching instance type (`"t3.micro"`/`"t3.micro"`/`"t3.small"`).
- This is the version that actually delivers on "different settings per environment" — `prod` quietly gets a bigger instance than `dev`/`qa`, from the **same** resource block.

---

### Version 3 — `for_each` over a **map of objects** (key → several values at once)

**`variables.tf`:**
```hcl
variable "instances" {
  description = "EC2 instance configuration by environment"
  type = map(object({
    instance_type = string
  }))
}
```

**`terraform.tfvars`:**
```hcl
instances = {
  dev  = { instance_type = "t3.micro" }
  qa   = { instance_type = "t3.micro" }
  prod = { instance_type = "t3.small" }
}
```

**`main.tf`:**
```hcl
resource "aws_instance" "web" {
  for_each = var.instances

  ami                         = var.ami_id
  instance_type               = each.value.instance_type
  associate_public_ip_address = true

  tags = {
    Name        = "mindcircuit-${each.key}"
    Environment = each.key
    ManagedBy   = "Terraform"
  }
}
```
- Here `each.value` is a whole **object**, not just one string — so you reach into it with `.`, exactly like `3November_Terraform_VariableTypes.md` §7's object field access: `each.value.instance_type`.
- This is the version that actually scales — if you later needed to add `disk_size` or `az` per environment, you'd just add another field to the object, with **no change** to the `main.tf` resource block's overall shape (only the one line referencing the new field).

**Easy memory trick, across all three versions:** a **set** gives you `each.key == each.value`, one plain string. A **map of strings** gives you a key *and* a single matching value. A **map of objects** gives you a key *and* a whole bundle of matching values, reached with `.field`.

---

## 4. A real best practice, visible in how these files were committed: `.tfvars.example`

- Two of today's three projects ship a **`terraform.tfvars.example`** file — not a real `terraform.tfvars`.
- The `.example` file is safe to commit: placeholder/non-sensitive values, showing exactly what shape the real file needs.
- The **real** `terraform.tfvars` (with your actual AMI ID, your actual region, etc.) stays **local, untracked** — a teammate clones the repo, copies `terraform.tfvars.example` to `terraform.tfvars`, fills in their own real values, and never accidentally commits anything sensitive.
- This is a cleaner version of the same goal behind this repo's own `.gitignore` rule for `*.tfvars` (`13October_Terraform.md` onward) — instead of just *excluding* the real file, you also commit a *template* so nobody has to guess what belongs in it.

---

## 5. Reading `for_each` outputs — including a genuinely new kind of `for` expression

Every `for` expression we've used before (`4November_Terraform_Module_Network.md` §4) produced a **list**: `[for s in aws_subnet.public : s.id]`. Today's outputs introduce the **map-producing** version:

```hcl
output "ec2_details" {
  description = "EC2 instance details by environment"

  value = {
    for environment, instance in aws_instance.web : environment => {
      instance_id = instance.id
      public_ip   = instance.public_ip
      private_ip  = instance.private_ip
    }
  }
}
```
**Step by step, since this line genuinely looks intimidating the first time:**

**1. What `aws_instance.web` actually is, after `for_each`.** Because this resource has `for_each = var.instances`, Terraform doesn't create one `aws_instance.web` — it creates a whole **bundle of them, each labeled by a key**, like a dictionary:
```
aws_instance.web = {
  "dev"  → (the dev instance's full details: id, public_ip, private_ip, ...)
  "qa"   → (the qa instance's full details)
  "prod" → (the prod instance's full details)
}
```
That's the thing the `for` expression is about to loop over.

**2. `for environment, instance in aws_instance.web` — a loop, exactly like Python's `for key, value in some_dict`.** `environment` and `instance` are **not** special Terraform keywords — they're just **two names I'm choosing**, one for the current key and one for the current value. I could have written `for k, v in aws_instance.web` instead and it would mean exactly the same thing. They're named this way simply because that's what they represent — the environment's name, and that environment's instance object.

So this loop runs **once per entry**:

| Iteration | `environment` (the key) | `instance` (the value) |
|---|---|---|
| 1 | `"dev"` | the dev instance's object |
| 2 | `"qa"` | the qa instance's object |
| 3 | `"prod"` | the prod instance's object |

**3. The colon `:`** just separates "what I'm looping over" (what you just read) from "what I want to build for each one" (next).

**4. `environment => { instance_id = instance.id, public_ip = instance.public_ip, private_ip = instance.private_ip }`** — the "for each item, produce this key → this value" part:
- **Left of `=>`** (`environment`) becomes the **key** in the new map — `"dev"`, `"qa"`, `"prod"`.
- **Right of `=>`** is a **brand-new small object**, built right here by reaching into `instance` (this iteration's EC2 object) and pulling out its `.id`, `.public_ip`, `.private_ip`.

**Putting all three iterations together, this is what the output actually becomes:**
```hcl
ec2_details = {
  "dev"  = { instance_id = "i-0111...", public_ip = "3.1.1.1", private_ip = "10.0.1.1" }
  "qa"   = { instance_id = "i-0222...", public_ip = "3.2.2.2", private_ip = "10.0.1.2" }
  "prod" = { instance_id = "i-0333...", public_ip = "3.3.3.3", private_ip = "10.0.1.3" }
}
```
Now you can type `ec2_details["prod"].public_ip` and get prod's IP directly — no need to remember which position in a list "prod" happened to land at.

**Why `{ }` instead of `[ ]`?** `{ for ... : key => value }` (curly braces + `=>`) builds a **map**. `[ for ... : value ]` (square brackets, no `=>`) builds a plain **list** — that's what `4November_Terraform_Module_Network.md`'s `[for s in aws_subnet.public : s.id]` does instead. Same `for` keyword, same looping idea — the brackets around it decide whether you end up with a list or a map.

**Other ways to reach into `for_each` resources**, straight from the raw notes:
```hcl
# One specific instance's ID:
aws_instance.web["dev"].id

# Every instance's ID, as a list:
values(aws_instance.web)[*].id

# Every instance's bucket name, as a list (for an S3 example):
[for bucket in aws_s3_bucket.buckets : bucket.bucket]
```
- ⚠️ **A resource built with `for_each` is a *map* of resource instances, not a numbered list** — that's why you reach a specific one with `["dev"]`, not `[0]`.

---

## 6. More real-time examples from the raw notes (conceptual, not hands-on today)

**Multiple Security Groups, one block:**
```hcl
variable "security_groups" {
  default = {
    web = "Web server security group"
    app = "Application security group"
    db  = "Database security group"
  }
}

resource "aws_security_group" "sg" {
  for_each    = var.security_groups
  name        = "${each.key}-sg"
  description = each.value
  vpc_id      = "vpc-xxxxxxxx"
}
```
- Creates `web-sg`, `app-sg`, `db-sg` — matching exactly the per-tier Security Group split already built by hand across `4November_Terraform_Module_Security.md`'s single wide-open SG — this is what the *parameterized, per-tier* version of that same idea would look like.

**Multiple IAM users, one block:**
```hcl
variable "iam_users" {
  default = toset(["developer", "tester", "admin"])
}

resource "aws_iam_user" "users" {
  for_each = var.iam_users
  name     = each.key
}
```
⚠️ Creating these users does **not** grant them any permissions by itself — policies/group memberships (`18September_IAM.md`) are still a separate step.

**`for_each` with a module, not just a resource:**
```hcl
module "s3_buckets" {
  source      = "./modules/s3"
  for_each    = toset(["dev", "test", "prod"])
  bucket_name = "my-company-${each.key}-bucket"
}
```
- Same mechanics as module composition (`4November_Terraform_3TierProject.md` §2) — just now the *same* module gets instantiated once per entry, as `module.s3_buckets["dev"]`, `module.s3_buckets["test"]`, `module.s3_buckets["prod"]`, instead of being called once per environment by hand.

---

## 7. `for_each` vs `count`

| | `count` | `for_each` |
|---|---|---|
| Driven by | A number | A map, or a set of strings |
| Resource addresses | `resource[0]`, `resource[1]`, `resource[2]` | `resource["dev"]`, `resource["qa"]`, `resource["prod"]` |
| Access inside the block | `count.index` | `each.key` / `each.value` |
| Best fit | Identical, interchangeable resources | Resources with meaningful names or different settings per instance |

**Easy memory trick:** `count = HOW MANY?` `for_each = WHICH ONES?`

---

## 8. Important rules worth knowing before using it for real

1. `for_each` accepts a **map**, or a **set of strings** — not a plain list directly (convert a list with `toset()` if needed, as several examples above do).
2. Map keys / set values must be **known** before Terraform touches real infrastructure — something computed only *during* `apply` can't be used as a `for_each` key.
3. **Sensitive values can't be used as `for_each` keys** — keys show up in plans and resource addresses, so Terraform won't let a `sensitive = true` value (`4November_Terraform_Module_RDS.md` §2) be used that way.
4. Every instance is tracked **separately** in state.
5. `each.key`/`each.value` only exist inside a block that actually has `for_each` set.
6. ⚠️ **Changing a map key (or a set element) changes that resource's *address*.** Terraform doesn't see "renamed" — it sees one resource disappearing and a different one appearing, and will plan to **destroy and recreate** unless you deliberately migrate the state first. Renaming `"qa"` to `"staging"` in one of today's examples, for instance, would destroy the `"qa"` instance and create a brand-new `"staging"` one — not simply relabel the existing instance.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `for_each` | Create multiple resource/module instances from a map or set | One block → `dev`/`qa`/`prod` instances |
| `each.key` / `each.value` | The current entry's key and value | Identical for a set; different for a map |
| Set of strings | `each.key == each.value`, a plain string | `toset(["dev", "qa", "prod"])` |
| Map of strings | Key + one matching value | `{ dev = "t3.micro", prod = "t3.small" }` |
| Map of objects | Key + several matching values, via `each.value.field` | Same pattern as `3November_Terraform_VariableTypes.md` §7 |
| `.tfvars.example` | A safe, committed template for the real (untracked) `.tfvars` | Teammates copy it and fill in their own real values |
| Map-producing `for` expression | `{ for k, v in resource : k => {...} }` — curly braces, not square | Looks up `ec2_details["prod"].public_ip` directly |
| Resource built with `for_each` | A map of instances, addressed by key, not by number | `aws_instance.web["dev"]`, never `aws_instance.web[0]` |
| `for_each` vs `count` | Meaningful keys vs plain numbers | `count = HOW MANY?`, `for_each = WHICH ONES?` |
| Changing a `for_each` key | Terraform sees a different resource, not a rename | Plans destroy + recreate unless state is migrated |
