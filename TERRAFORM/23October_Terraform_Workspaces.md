# Batch 18 — Terraform Running Notes: 23 October 2026

**Topic: Terraform Workspaces**

Friends, on 21–22 October we managed multiple environments by swapping `.tfvars` files (`21October_Terraform_Variables.md`, `22October_Terraform_MiniProject_Variables.md`) — but every one of those `apply` runs still shared the **same state file**. Today's topic, **Workspaces**, is a different way to separate environments: same code, but a genuinely **separate state file** per environment.

---

## 1. What are Terraform Workspaces?

- **Workspaces** let you manage multiple environments (dev, test, prod) using the **exact same Terraform code**.
- Each workspace has its **own separate state file**.
- Every project starts with one workspace, called **`default`**.

---

## 2. Why do we need workspaces?

| | Without workspaces | With workspaces |
|---|---|---|
| Code | Separate folders or copied code per environment | **Same code**, reused as-is |
| State | One shared state file (or manually separated folders) | **Separate state file** per environment |
| Example | Copy-paste the whole project to make a "dev" version | `dev` → small instance, `prod` → large instance, same files |

---

## 3. How workspaces actually work

- Terraform keeps a **separate state file for each workspace**, even though all workspaces share the same `.tf` code.

**Example:**
```
default workspace → terraform.tfstate
dev workspace     → terraform.tfstate (its own copy, for the dev workspace)
prod workspace    → terraform.tfstate (its own copy, for the prod workspace)
```
- Switching workspaces doesn't change your code at all — it only changes **which state file** Terraform reads and writes to.

---

## 4. Important commands

```bash
terraform workspace list              # list every workspace
terraform workspace new dev           # create a new workspace called "dev"
terraform workspace select dev        # switch to the "dev" workspace
terraform workspace show              # show which workspace is currently active
terraform workspace delete dev        # delete the "dev" workspace
```

---

## 5. Real-time DevOps use case

**Scenario:** you have 3 environments — `dev`, `qa`, `prod`.

```bash
terraform workspace new dev
terraform workspace new qa
terraform workspace new prod

terraform workspace select dev
terraform apply

terraform workspace select prod
terraform apply
```
- **Result:** the **same code**, applied twice, produces two **completely separate** sets of infrastructure — because each `apply` ran against a different workspace's own state file.

---

## 6. Workspaces vs `.tfvars` — these solve two different problems

| | Workspaces | `.tfvars` |
|---|---|---|
| What changes | **Separate state files** | **Different input values** |
| Code | Same code | Same code (or different environments) |

- **Best practice: use both together.** `.tfvars` decides *what values* an environment gets (CIDR, instance type, tags — exactly what `22October_Terraform_MiniProject_Variables.md` did); a workspace decides *where that environment's state is tracked*, separately from every other environment's state.
- **Easy memory trick:** `.tfvars` = different **inputs**. Workspace = different **state**. Neither one replaces the other.

---

## 7. When to actually use workspaces

**Good fit for:**
- Small to medium projects.
- Multiple environments (dev/test/prod) that share the same basic infrastructure pattern.

**Avoid for:**
- Very complex architectures.
- Large enterprise setups — use **separate backends** instead (a dedicated state backend per environment, rather than one backend split into workspaces).

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Workspace | Same code, separate state file per environment | `dev`, `qa`, `prod` workspaces off one codebase |
| `default` workspace | The workspace every project starts in | Exists automatically, no setup needed |
| `terraform workspace new <name>` | Creates a new workspace | `terraform workspace new dev` |
| `terraform workspace select <name>` | Switches which workspace is active | `terraform workspace select prod` |
| `terraform workspace show` | Shows the currently active workspace | Quick sanity check before `apply` |
| Workspaces vs `.tfvars` | Separate state vs separate input values | Best practice: use both together |
| When to avoid workspaces | Very complex/large enterprise setups | Use separate backends instead |
