# Batch 18 — Terraform Running Notes: 30 October 2026

**Topic: Terraform Import**

Friends, every project so far has started the same way: write the `.tf` code first, then `terraform apply` creates the real infrastructure from scratch. Today's topic flips that around — **Terraform Import** is for the opposite situation: the real infrastructure **already exists** (someone built it by hand in the console, or with another tool), and you want Terraform to start managing it **without destroying and recreating it.**

---

## 1. What is Terraform Import?

- **Terraform Import** is a command that brings **existing infrastructure** (created outside Terraform) **under Terraform's management.**
- It lets Terraform **track and manage** resources that weren't originally created using Terraform at all.

---

## 2. Why is it needed?

- Infrastructure already exists — built manually, or via some other tool.
- You want to manage it with Terraform **going forward.**
- You need to **avoid recreating** the resource, since that could mean real downtime or data loss (imagine "recreating" a production RDS database just to bring it under Terraform).

---

## 3. Syntax

```bash
terraform import <resource_type>.<resource_name> <resource_id>
```

**Example:**
```bash
terraform import aws_instance.my_ec2 i-1234567890abcdef0
```
- `aws_instance.my_ec2` — the resource **address** in your `.tf` code (type + the local name you've given it).
- `i-1234567890abcdef0` — the **real AWS ID** of the instance that already exists.

---

## 4. Key points — what import actually does (and doesn't do)

- Import does **NOT** create configuration files for you.
- **You** must manually write the matching `.tf` code yourself.
- It only updates the **Terraform state file** — it tells Terraform "this resource ID is now tracked," nothing more.
- The resource must **already exist** in the provider (AWS, Azure, etc.) — you can't import something that isn't actually there.

**Easy memory trick:** Import only writes to the **state**, never to your `.tf` files. The code side is still 100% on you.

---

## 5. Real-time scenario

**Situation:** a company has an existing AWS EC2 instance, created manually through the AWS Console. Now they want to:
- Manage it using Terraform.
- Apply future updates (tags, security groups, etc.) through Terraform instead of the console.

### Step-by-step process

**Step 1 — Write a starting Terraform configuration:**
```hcl
resource "aws_instance" "my_ec2" {
  # minimal config to start — refine later
}
```

**Step 2 — Run the import command:**
```bash
terraform import aws_instance.my_ec2 i-0abcd1234efgh5678
```

**Step 3 — Verify the state:**
```bash
terraform state list
```

**Step 4 — Run a plan:**
```bash
terraform plan
```
- Terraform will show the **differences** between the real resource and your (still-minimal) config — this is expected at this stage, not an error.

**Step 5 — Update the configuration to match reality:**
- Add the missing attributes (AMI, instance type, and so on) until `terraform plan` shows **no differences** — meaning your code now genuinely describes the resource that already exists.

---

## 6. Important notes

- Import is a **one-time action** — it's a migration step, not something you run repeatedly.
- ⚠️ **An incorrect configuration after import can cause unwanted changes the next time you run `terraform apply`** — if your `.tf` code doesn't actually match the real resource, `apply` might "fix" it by changing or even replacing something that was working fine.
- **Always run `terraform plan` immediately after an import** — never jump straight to `apply`.

---

## 7. Common use cases

- Migrating manually-built infrastructure into Terraform.
- Adopting legacy systems that predate the team's Terraform adoption.
- Disaster-recovery scenarios (re-establishing management over surviving resources).
- Standardizing infrastructure management across a team or company.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Terraform Import | Brings existing, non-Terraform infrastructure under Terraform's management | `terraform import aws_instance.my_ec2 i-1234567890abcdef0` |
| What import updates | Only the **state file** | Never generates or edits `.tf` code |
| What you still have to do | Write the matching `.tf` config yourself | Keep refining until `terraform plan` shows no diff |
| Resource must already exist | Can't import something that isn't actually there | The ID passed in must be a real, existing resource |
| After import | Always run `terraform plan` before `apply` | Catches mismatches before they become unwanted changes |
| Common use case | Adopting manually-built or legacy infrastructure | A console-created EC2 instance, now Terraform-managed |
