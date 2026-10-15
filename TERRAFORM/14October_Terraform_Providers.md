# Batch 18 — Terraform Running Notes: 14 October 2026

**Topic: Terraform Providers — Deep Dive + Hands-On**

Friends, on 13 October (`13October_Terraform.md`) Providers came up as one of three core architecture components, alongside Terraform Core and the State file. Today we go deeper into **just the Provider piece** — what it actually is, what it does, and then put it into practice with two real projects.

---

## 1. What is a Terraform Provider?

- A **Provider** is a plugin that lets Terraform interact with an external platform's API — AWS, Azure, Google Cloud, Kubernetes, Docker, GitHub, and more.
- Think of it as **a logical abstraction of an API** — it translates your `.tf` resource blocks into the actual API calls that platform understands.
- **Terraform itself cannot talk to AWS or any other service directly** — the provider is the bridge in between.

---

## 2. Example provider block

```hcl
provider "aws" {
  region = "ap-south-1"
}
```
This tells Terraform: *"use the AWS provider, and create resources in the `ap-south-1` region."*

---

## 3. What does a provider actually do?

Once configured, a provider is what performs every real operation against the platform's API:
- **Create** resources
- **Modify** resources
- **Delete** resources
- **Read** resource information (this is also how Terraform detects **drift** — when real infrastructure no longer matches what your `.tf` files say it should be)

**Each provider also defines which resource types even exist** — e.g. the AWS provider is the reason `aws_instance`, `aws_vpc`, and `aws_s3_bucket` are valid resource types at all. Without declaring the AWS provider, Terraform has no idea what an `aws_instance` even means.

**Example AWS resource types made available by the AWS provider:**
```
aws_instance
aws_vpc
aws_s3_bucket
```

---

## 4. Hands-on — what we actually built in class today

Two small practice projects, both under `terraform_practice/14OCT26/` — each with its own `main.tf`, each using the provider differently.

### Project 1 — two EC2 instances + an S3 bucket, same provider

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.68.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "prod_instance" {
  ami           = "ami-004d1eaf8eaa0107d"
  instance_type = "t3.micro"
  key_name      = "mckey"
  count         = 2

  tags = {
    Name = "Prod-Instance"
  }
}

resource "aws_s3_bucket" "prod_bucket" {
  bucket = "madhu-prod-bucket-terraform-2026"

  tags = {
    Name = "Madhu-prod-bucket-terraform-2026"
  }
}
```

**Two new things worth calling out that weren't in yesterday's notes:**

- **`required_providers` block** — pins the exact provider **source** (`hashicorp/aws`) and **version** (`6.68.0`). This matters because `terraform init` (§3 in `13October_Terraform.md`) downloads whatever version satisfies this constraint — pinning it means your team, and your CI/CD pipeline, all download the *same* provider version, instead of silently drifting to whatever's newest on a given day.
- **`count = 2`** — a **meta-argument** any resource block can use. With `count = 2`, Terraform creates **two** `aws_instance` resources from this one block, instead of you copy-pasting the whole block twice. Terraform refers to them internally as `aws_instance.prod_instance[0]` and `aws_instance.prod_instance[1]`.
- `aws_s3_bucket` shows the provider creating a resource of a completely different type (storage, not compute) from the exact same provider block — one provider, many resource types.

### Project 2 — a second, independent provider configuration

```hcl
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "test" {
  ami           = "ami-0cede6fe40e6ac719"
  instance_type = "t2.micro"
  key_name      = "mc-mumbaikey"

  tags = {
    Name = "TestInstance"
  }
}
```
- A completely separate project directory, its own provider block, pointed at a **different region** (`ap-south-1` instead of `us-east-1`) — and, because it's a separate project, its own independent state file too.
- This is the simplest possible lead-in to tomorrow's topic: what happens when you need **both** of these regions **inside one single configuration**, instead of two separate ones? That's exactly what provider *aliasing* solves — see `15October_Terraform.md`.

---

## 5. A note on what's actually in `terraform_practice/`

Running `terraform init` + `terraform apply` locally produces a few things alongside your `main.tf` that should **never** go into Git:
```
.terraform/              ← downloaded provider plugin binaries (large, per-OS, regenerable)
.terraform.lock.hcl       ← provider version lock file
terraform.tfstate         ← your infrastructure's current state
terraform.tfstate.backup  ← the previous state, kept as a safety copy
```
Only the **`main.tf`** (and any other hand-written `.tf` files) are source code. `.terraform/` is a huge, fully regenerable download (re-created by just running `terraform init` again) — never worth committing. `terraform.tfstate`/`.backup` can contain sensitive resource details (IPs, IDs, sometimes even secrets, depending on what you provision) — also excluded here. (One nuance worth knowing for later: in many real team projects, `.terraform.lock.hcl` *is* deliberately committed, specifically so everyone downloads the exact same provider version — but for this practice folder, the instruction is simply **main.tf only**, so it's excluded too.) See the repo's new root `.gitignore`, added specifically to keep these out of version control from now on.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Provider | Plugin bridging Terraform to a platform's API | `provider "aws" { region = "ap-south-1" }` |
| What a provider does | Create / modify / delete / read resources | Also how Terraform detects drift |
| `required_providers` | Pins the exact provider source + version | `hashicorp/aws`, version `6.68.0` |
| `count` meta-argument | Creates N copies of a resource from one block | `count = 2` → `prod_instance[0]`, `prod_instance[1]` |
| Resource types come from the provider | No AWS provider = no `aws_instance` at all | `aws_instance`, `aws_vpc`, `aws_s3_bucket` |
| Two projects, two providers | Separate directories = separate state, independently configured | `us-east-1` (project-1) vs `ap-south-1` (project-2) |
| What never goes into Git | `.terraform/`, `.terraform.lock.hcl`, `*.tfstate*` | Only `main.tf` (and other `.tf` source) is committed |
