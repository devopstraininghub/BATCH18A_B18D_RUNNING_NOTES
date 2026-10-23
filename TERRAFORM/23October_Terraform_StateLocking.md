# Batch 18 — Terraform Running Notes: 23 October 2026

**Topic: Terraform State File Locking**

Friends, right after Workspaces (`23October_Terraform_Workspaces.md`) — which is all about **separating** state files per environment — today's second topic is about **protecting** a state file once you're sharing it with a team: what happens if two people run `terraform apply` on the same state file at the same time, and how Terraform stops that from becoming a disaster.

---

## 1. What is the Terraform state file, again?

- `terraform.tfstate` stores the **current state** of your infrastructure.
- It tracks: resource IDs, their configurations, and the mapping between your code and the real resources in AWS (or wherever).
- Already covered in `13October_Terraform.md` §3 — today adds the missing piece: what protects it in a **team** setting.

---

## 2. What is state file locking?

- **State locking** prevents **multiple users from modifying the infrastructure at the same time.**
- Only **ONE** person or process can run `terraform apply` or `terraform destroy` against a given state file at a time.

---

## 3. Why do we need state locking?

**Without locking** — if multiple users ran `terraform apply` at the same time, you'd get:
- Conflicts.
- Resource duplication.
- State file corruption.
- Actual infrastructure breakage.

**Locking ensures:** safe, consistent updates — only one change happening at a time, applied cleanly.

---

## 4. How state locking actually works

**When you run `terraform apply`, Terraform:**
1. **Acquires** the lock.
2. Performs the changes.
3. **Releases** the lock.

**If a second person tries to run `apply` while the lock is held:**
```
Error: State is locked by another process
```
They simply have to wait until the first `apply` finishes and releases the lock.

---

## 5. Where is the lock actually stored?

**It depends entirely on your backend:**

| Backend | Locking behavior |
|---|---|
| **Local backend** | No proper locking — **not safe for team use.** |
| **S3 + DynamoDB** | Lock is stored in **DynamoDB.** |
| **Terraform Cloud** | Locking is **managed for you.** |
| **Consul** | Locking is supported. |

⚠️ If your state file is just sitting on your own laptop (the local backend), there's no real protection at all — this is exactly why real team projects move to a remote backend.

---

## 6. Real DevOps setup — the standard best practice

**Use S3 (to store the state) + DynamoDB (to lock it):**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
  }
}
```
- `bucket` — the S3 bucket that holds the actual `terraform.tfstate` file.
- `key` — the path/filename inside that bucket (here, scoped under `dev/` — note this pairs naturally with the `dev`/`qa`/`prod` workspace or `.tfvars` pattern from earlier files).
- `dynamodb_table` — the DynamoDB table Terraform uses purely to coordinate the **lock** — one row per state file, held only while an `apply`/`destroy` is actually running.

---

## 7. What happens if the lock gets stuck?

- Sometimes a lock doesn't get released properly — usually because of a **crash** or a **network issue** mid-`apply`.

**Error you'd see:**
```
Error acquiring the state lock
```

**Solution:**
```bash
terraform force-unlock <LOCK_ID>
```
⚠️ **Use this carefully.** Force-unlocking while another `apply` is genuinely still in progress can lead to exactly the conflicts/corruption locking exists to prevent in the first place — only force-unlock once you're sure the original process actually crashed and isn't still running.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| State file locking | Only one `apply`/`destroy` at a time, on a given state | Prevents two engineers from colliding on the same infra |
| Local backend | No real locking — unsafe for teams | Fine solo, never for a shared project |
| S3 + DynamoDB backend | The standard team setup | S3 stores state, DynamoDB holds the lock |
| "State is locked by another process" | Someone else's `apply`/`destroy` is currently running | Just wait for it to finish |
| `terraform force-unlock <LOCK_ID>` | Manually clears a stuck lock | Only after confirming the original process actually crashed |
| Workspaces vs locking | Two different protections | Workspaces separate state per environment; locking protects *one* state file from concurrent writes |
