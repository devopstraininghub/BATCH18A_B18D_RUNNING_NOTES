# Batch 18 — Terraform Running Notes: 28 October 2026

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
