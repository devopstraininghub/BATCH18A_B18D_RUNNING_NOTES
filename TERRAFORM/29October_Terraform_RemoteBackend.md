# Batch 18 — Terraform Running Notes: 29 October 2026

**Topic: Terraform Remote Backend (S3 — with Native Locking)**

Friends, on 23 October (`23October_Terraform_StateLocking.md`) we covered *why* state locking matters, using the classic **S3 + DynamoDB** setup as the real DevOps best practice. Today updates that: DynamoDB-based locking is now **deprecated**, and S3 itself can handle locking natively. This file covers both the backend concept and the current recommended setup.

---

## 1. What is a Terraform backend?

- A **backend** defines **where Terraform stores its state file** (`terraform.tfstate`).
- **Default:** a local file — not safe for team use (same point already made in `13October_Terraform.md` §3 and `23October_Terraform_StateLocking.md` §5).
- **Remote backend:** stores the state file somewhere shared instead — S3, Terraform Cloud, Azure Blob Storage, or Google Cloud Storage (GCS).

---

## 2. What does a remote backend actually give you?

- **Team collaboration** — everyone works off the same state.
- **Centralized state** — one source of truth, not scattered laptop copies.
- **Backup & versioning** — especially when paired with S3 versioning (§6).
- **Secure access** — controlled through normal AWS IAM permissions on the bucket.

---

## 3. Why a remote backend is actually required for teams

**Problems with local state:**
- No sharing — it's just a file on one person's machine.
- Real risk of accidental deletion.
- No locking — nothing stops two people applying at once.
- Conflicts the moment more than one engineer touches the same infrastructure.

**What a remote backend solves:**
- Shared access for the whole team.
- Safe, coordinated updates.
- A real locking mechanism (§4).

---

## 4. State locking — the quick recap

- **State locking** prevents multiple users from modifying infrastructure at the same time.

```
User1 → terraform apply
User2 → blocked until User1 finishes
```
- Full mechanics (how a lock is acquired/released, what happens if one gets stuck, `force-unlock`) are already covered in `23October_Terraform_StateLocking.md` — this file is specifically about *where that lock itself now lives.*

---

## 5. The old approach — S3 + DynamoDB (now deprecated)

```hcl
terraform {
  backend "s3" {
    bucket         = "my-tf-state"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
  }
}
```
- **S3** stored the actual state file.
- **DynamoDB** handled the locking, in a separate table.

⚠️ **This exact setup is what `23October_Terraform_StateLocking.md` §6 described as "the real DevOps setup / best practice" — that framing is now outdated.** `dynamodb_table` is **deprecated** as of Terraform 1.11 (the underlying `use_lockfile` capability was introduced experimentally in Terraform 1.10). It still works today, but HashiCorp has said it will eventually be removed in a future minor version — don't build new projects around it.

---

## 6. The new approach — S3 native locking (Terraform 1.10+/1.11+)

- S3 now supports **native locking** — no DynamoDB table needed at all.
- Terraform achieves this using a small **lock file** (with a `.tflock` extension) stored right next to the state file in the same bucket, plus **S3 conditional writes** to make the locking safe.

**Recommended backend configuration:**
```hcl
terraform {
  backend "s3" {
    bucket       = "my-tf-state"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}
```

### What does `use_lockfile` actually do?

- Enables S3's **native locking.**
- When `terraform apply` runs:
  1. A lock file is created in S3.
  2. Other users are blocked from applying until it's released.
  3. The lock is released once the `apply` finishes.

⚠️ **Version caveat, worth being precise about:** this needs a reasonably recent Terraform — treat **Terraform 1.11 or later** as the safe minimum before relying on `use_lockfile` in a real project, since the feature was still experimental in 1.10.

---

## 7. S3 setup steps

1. **Create an S3 bucket** — e.g. `my-tf-state`.
2. **Enable versioning** on that bucket — **important**, since it protects the state file's history (lets you recover an earlier version if something goes wrong).
3. **Configure the backend** in your Terraform code, as shown in §6.

---

## 7a. Hands-on — bootstrapping the backend for real, before using it

Here's the part that's easy to miss on paper: **the S3 bucket your backend points at has to exist *before* you can configure your project to use it as a backend.** You can't have a project's own backend create its own bucket — so step one is a small, separate, one-off project just to create the bucket (and, if you want it, the table).

**`s3_dynamodb_bootstarp/main.tf` — a one-time setup project:**
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# S3 bucket to store Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "mc-b18-state-bucket-2026-unique"

  tags = {
    Name = "terraform-state-bucket"
  }
}

# Enable S3 versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable S3 encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table — built here too, purely so both approaches can be compared
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "terraform-state-lock"
  }
}
```
- Two new, genuinely useful S3-hardening resources beyond §7's basic steps:
  - **`aws_s3_bucket_server_side_encryption_configuration`** — encrypts everything in the bucket at rest (`AES256`). Your state file can contain sensitive values (IPs, resource IDs, sometimes secrets depending on what you provision) — encrypting the bucket is a sensible default, not an optional extra.
  - **`aws_s3_bucket_public_access_block`** — explicitly blocks every form of public access to the bucket. A state bucket should never, ever be reachable from the public internet.
- The DynamoDB table was built here too — **not because it's needed**, but specifically so the class could see the old (§5) and new (§6) approaches side by side, in the same bootstrap project.

**`project-prod/backend.tf` — the actual project, pointing at that bucket:**
```hcl
terraform {
  backend "s3" {
    bucket       = "mc-b18-state-bucket-2026-unique"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    # dynamodb_table = "terraform-state-lock"   ← old approach, left commented out
    use_lockfile = true
  }
}
```
- `encrypt = true` — a one-line setting that tells Terraform to encrypt the state file itself when writing it, on top of whatever bucket-level encryption §7a already configured. Worth setting explicitly even when the bucket is already encrypted.
- The `dynamodb_table` line is **commented out, not deleted** — a nice way to document "we considered the old approach, here's exactly what it would have looked like" without actually depending on it.
- `use_lockfile = true` is what's actually active — this project uses S3's native locking (§6), even though the DynamoDB table from §7a still exists in the account.

**`project-prod/main.tf` — a simple resource, just to prove the backend works:**
```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "prod-fb-srv" {
  ami           = "ami-0ed59cbb87dfa8dba"
  instance_type = "t2.micro"
  key_name      = "madhukey"
  count         = 1

  tags = {
    Name = "facebook server"
  }
}
```
- Nothing special about this resource itself — the whole point was proving that `terraform init`/`plan`/`apply` against it now reads and writes `prod/terraform.tfstate` inside the S3 bucket, with native locking, instead of a local file.

---

## 8. Workflow

```bash
terraform init
```
- Configures the backend, connects to S3, prepares locking.

```bash
terraform plan
```
- Reads the **remote** state (from S3), not a local file.

```bash
terraform apply
```
- Acquires the lock → updates the infrastructure → releases the lock.

---

## 9. Real DevOps use case

**Scenario:** a team of 5 engineers working on the same infrastructure.

**Without a remote backend:** ❌ conflicts, ❌ overwrites — whoever applies last silently wins, possibly erasing someone else's change.

**With an S3 backend (+ locking):** ✅ shared state, ✅ safe updates, ✅ locking actively prevents the conflict from happening in the first place.

---

## 10. Important notes

- DynamoDB-based locking is **deprecated** — it still works, but it's not recommended for new projects.
- S3 native locking (`use_lockfile`) is the **future standard.**
- **Always enable versioning** on the S3 state bucket, regardless of which locking approach you use.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Backend | Where Terraform stores its state file | Local (default) vs remote (S3, Terraform Cloud, Azure Blob, GCS) |
| Remote backend | Shared, centralized state storage | S3 bucket shared by the whole team |
| State locking | Only one `apply` at a time | `User2` blocked until `User1` finishes |
| Old: S3 + DynamoDB | The previous best practice — now deprecated | `dynamodb_table = "terraform-locks"` |
| New: S3 native locking | Current recommended approach | `use_lockfile = true`, no DynamoDB table |
| `.tflock` | The actual lock file S3 native locking uses | Sits next to `terraform.tfstate` in the same bucket |
| S3 versioning | Protects state file history | Recover an earlier state if something goes wrong |
| Minimum Terraform version | `use_lockfile` needs a recent Terraform | Treat 1.11+ as the safe minimum |
| Bootstrap project | A one-off project just to create the bucket/table first | `s3_dynamodb_bootstarp/` before `project-prod/` can use it |
| `encrypt = true` in `backend "s3"` | Encrypts the state file itself, on write | Separate from, and in addition to, bucket-level encryption |
| `aws_s3_bucket_public_access_block` | Blocks all public access to the state bucket | A state bucket should never be reachable from the internet |
