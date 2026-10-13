# Batch 18 — Terraform Running Notes: 14 October 2026

**Topic: Terraform in Multi-Region — Provider Aliases**

Friends, yesterday (`13October_Terraform.md`) we saw a single `provider "aws" { region = "ap-south-1" }` block. Today's question: what if you need Terraform to create resources in **two different AWS regions at the same time**, in the same configuration? That's exactly what **provider aliases** are for.

---

## 1. The problem — one provider block, but two regions needed

- Normally, a Terraform configuration has **one** `provider "aws"` block, and every `aws_*` resource in that file uses it.
- But real projects sometimes need infrastructure in **more than one region at once** — e.g. a disaster-recovery setup, or serving users in different parts of the world.
- You can't just write two plain `provider "aws" { region = ... }` blocks — Terraform needs a way to tell them **apart**. That's what `alias` is for.

---

## 2. Declaring multiple AWS providers with `alias`

```hcl
provider "aws" {
  region = "us-east-1"
  alias  = "nv"
}

provider "aws" {
  region = "ap-south-1"
  alias  = "mumbai"
}
```

- Each block is still a normal AWS provider — just pointed at a **different region**, and given a unique **`alias`** so Terraform (and you) can refer to it by name.
- The **first** provider for a given type (here, `aws`) doesn't strictly need an alias — it becomes the **default** provider, used by any resource that doesn't explicitly specify one. Giving *every* provider an explicit alias (as above) just makes which-is-which unambiguous, which is good practice once you're juggling more than one.

**Easy memory trick:** `alias = a nickname for "which AWS region am I talking about right now."`

---

## 3. Using a specific provider on a resource

Once you have multiple aliased providers, each resource picks which one to use via the `provider` argument:

```hcl
resource "aws_instance" "sbox_nv" {
  ami           = "ami-053a45fff0a704a47"
  instance_type = "t2.micro"
  key_name      = "madhukey"

  provider = aws.nv

  tags = {
    Name = "sbox-nv"
  }
}

resource "aws_instance" "sbox_mumbai" {
  ami           = "ami-0ddfba243cbee3768"
  instance_type = "t2.micro"
  key_name      = "mumbaib15"

  provider = aws.mumbai

  tags = {
    Name = "sbox-mumbai"
  }
}
```

**What's happening here, piece by piece:**
- `aws_instance.sbox_nv` → explicitly uses `provider = aws.nv` → gets created in **`us-east-1`**.
- `aws_instance.sbox_mumbai` → explicitly uses `provider = aws.mumbai` → gets created in **`ap-south-1`**.
- Both are plain `aws_instance` resources — **same resource type**, **same `.tf` file**, **same `terraform apply`** — the only thing that changes which region each one lands in is the `provider = aws.<alias>` line.
- ⚠️ The **AMI ID is region-specific** — an AMI from `us-east-1` is not valid in `ap-south-1` and vice versa, which is exactly why this example uses two *different* `ami` values for the two instances, even though both are the same `t2.micro` instance type. (Same AMI concept as `7September_AMI_LT.md` — an AMI is tied to the region it was created/copied into.)

---

## 4. Why this matters in real projects

- **Disaster recovery** — stand up a standby copy of your infrastructure in a second region, ready to take over if the primary region has an outage.
- **Latency/global reach** — serve users in different geographies from the region nearest them (the same underlying motivation as CloudFront's edge locations in `30September_CloudFront.md`, just at the compute layer instead of the CDN layer).
- **Compliance/data residency** — some workloads must legally stay in a specific region or country.
- Without provider aliasing, you'd need **two entirely separate Terraform configurations** (and two separate `apply` runs) to manage the same thing — aliasing lets one configuration, one `plan`, and one `apply` manage infrastructure across regions together, consistently.

---

## 5. One alias block, many resources

- You're not limited to one resource per aliased provider — once `aws.mumbai` is declared, as many `resource` blocks as you need can set `provider = aws.mumbai` (a VPC, a Security Group, an EC2 instance, all in Mumbai, say) — the alias is reusable across the whole configuration, not a one-time pairing.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Multiple providers | Terraform supports more than one AWS provider block per config | One for `us-east-1`, one for `ap-south-1` |
| `alias` | A unique name distinguishing providers of the same type | `alias = "nv"` vs `alias = "mumbai"` |
| Default provider | The first/un-aliased provider block for a type | Used automatically when a resource omits `provider = ...` |
| `provider = aws.<alias>` on a resource | Explicitly pins that resource to one specific provider/region | `aws_instance.sbox_mumbai` → `provider = aws.mumbai` |
| Region-specific AMIs | An AMI ID only works in the region it belongs to | Two different `ami` values for `us-east-1` vs `ap-south-1` |
| Why multi-region Terraform | DR, latency/global reach, compliance | One `apply` manages infrastructure in multiple regions at once |
