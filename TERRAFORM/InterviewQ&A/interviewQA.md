# Batch 18 — Terraform Interview Questions & Answers

**Topic: Terraform Interview Q&A (combined reference)**

This combines the three separate FAQ files into one reference, with every answer checked for accuracy and a simple, correct example added or fixed wherever the original was incomplete, mismatched, or had a syntax error. Organized into three parts: **A) Basics, Workflow & State**, **B) Functions, Lifecycle, Provisioners & `null_resource`**, and **C) Modules, Workspaces & Tooling**.

---

## Part A — Terraform Basics, Workflow & State

### Q1. Which IaC tool do you use? Do you have experience with Terraform?
**Answer:** I'm familiar with cloud-native IaC tools too (AWS CloudFormation, Azure ARM Templates), but we've been using Terraform for infrastructure as code for the last few years — it's cloud-agnostic, which CloudFormation/ARM aren't.

---

### Q2. What are the frequently used Terraform commands?
```bash
terraform init      # initialize the working directory, download providers
terraform fmt        # auto-format the code
terraform validate   # check for syntax errors
terraform plan       # dry run — preview changes
terraform apply      # execute the planned changes
```

---

### Q3. What exactly does `terraform init` do?
**Answer:**
- Checks for the required provider plugins and downloads them if missing.
- Downloads any modules referenced by `source`.
- Configures the backend, if one is defined in the code (commonly a remote backend).

---

### Q4. How do you run `terraform apply` in non-interactive mode (e.g. in CI/CD)?
```bash
terraform apply --auto-approve
```
Skips the "do you want to perform these actions?" prompt — this is exactly how a CI/CD pipeline step runs it, since there's no human there to type "yes."

---

### Q5. What is a state file in Terraform?
**Answer:** `terraform.tfstate` — a JSON file Terraform uses to track the **current** state of the infrastructure it manages. By default it's created locally; it's strongly recommended to use a **remote backend** instead (S3, Azure Blob Storage, GCS, Terraform Cloud) for any real team project.

---

### Q6. Where do you store the state file?
**Answer:** On AWS projects, in an S3 bucket, with locking (historically via DynamoDB, now via S3's own native locking — see `29October_Terraform_RemoteBackend.md`). On Azure projects, in Azure Blob Storage, which has locking built in already.

**Example — AWS:**
```hcl
terraform {
  backend "s3" {
    bucket = "awsb63data"
    key    = "terraform-functions.tfstate"
    region = "us-east-1"
  }
}
```

**Example — Azure:**
```hcl
terraform {
  backend "azurerm" {
    storage_account_name = "azb63data"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

---

### Q7. What happens if the state file is deleted?
**Answer:** Terraform loses track of what it's already created. Running `terraform apply` afterward can try to **recreate** resources that already exist in AWS — causing duplicates, naming conflicts, or errors. This is exactly why the state file should live in a remote backend with versioning/backup enabled (`29October_Terraform_RemoteBackend.md` §7's "always enable versioning" rule), not just locally.

If there's genuinely no backup, you can rebuild tracking of the existing resources with `terraform import` (`30October_Terraform_Import.md`) instead of recreating them.

---

### Q8. How do you rename a resource in Terraform without destroying and recreating it?
**Answer:** You can't edit the state file by hand — use the `terraform state` command instead.
```bash
terraform state list                                             # list tracked resources
terraform state show aws_security_group.allow_all                 # show one resource's details
terraform state mv aws_security_group.allow_all aws_security_group.allow_all_new   # rename it in state
```
`state mv` updates the resource's address in the state file to match a renamed block in your code, without touching the real infrastructure at all.

---

### Q9. How do you create or destroy just one specific resource, not the whole project?
```bash
terraform apply   -target=aws_security_group.allow_all
terraform destroy -target=aws_security_group.allow_all
```
⚠️ `-target` is meant for troubleshooting/emergencies, not routine use — over-relying on it can let your state and your `.tf` code quietly drift apart.

---

### Q10. How do you run `terraform destroy` but keep one specific resource untouched?
**Answer:** In two steps:
1. **Remove the resource from the state file**, so Terraform stops tracking it:
   ```bash
   terraform state rm aws_s3_bucket.bucket_name
   ```
2. **Remove (or comment out) that resource's block** from your `.tf` code.
3. **Now run `terraform destroy`** — it only destroys what's still tracked in state, so the bucket survives, untouched and no longer managed by Terraform.

---

### Q11. A teammate made manual changes to the infrastructure — what happens if I run `terraform apply`?
**Answer:** Terraform's state file doesn't automatically know about manual changes. **Always run `terraform plan` first** — it shows you the difference between what's actually deployed and what your code says should exist. If `plan` shows unexpected changes caused by someone's manual edit, running `apply` directly (without reviewing `plan`) risks **overwriting or reverting** that manual change back to what the code says.

---

### Q12. What does `terraform refresh` do, and how do you detect manual changes?
```bash
terraform plan -refresh-only
```
**Answer:** This reconciles the state file with real infrastructure **without changing anything** — it just updates Terraform's own record of "what currently exists." It's the safe way to surface drift (manual changes) before deciding whether to update your code to match, or run a real `apply` to revert it.

---

### Q13. What's the difference between `variables.tf` and a `.tfvars` file?
**Answer:**
- `variables.tf` **declares** a variable — its name, type, and optionally a default. (The filename doesn't actually matter — you could call it anything — `variables.tf` is just the convention.)
- A `.tfvars` file (or `-var` on the command line) **supplies the actual value.**

**Example:**
```hcl
# variables.tf
variable "vpc_name" {
  type    = string
  default = "demovpc1"
}
```
```bash
# command line — this wins over terraform.tfvars
terraform apply -var 'vpc_name=demovpc1'
```

---

### Q14. Can you have multiple `.tfvars` files?
**Answer:** Yes — `terraform.tfvars` is the only one loaded automatically; any other name has to be passed explicitly.
```bash
terraform apply -var-file=dev.tfvars -var-file=prod.tfvars
```

---

### Q15. How do you get Terraform to load multiple `.tfvars` files *automatically*, without passing `-var-file` each time?
**Answer:** Name them with the `.auto.tfvars` suffix — Terraform loads every file matching that pattern on its own, in alphabetical order.
```
dev1.auto.tfvars
dev2.auto.tfvars
```

---

### Q16. What is the actual precedence order for Terraform variables?
**Answer:** From **lowest** to **highest** priority — later sources in this list win over earlier ones:
1. Environment variables (`TF_VAR_vpc_name=demovpc1`)
2. `terraform.tfvars`, if present
3. `terraform.tfvars.json`, if present
4. Any `*.auto.tfvars`/`*.auto.tfvars.json` files, in alphabetical order
5. Any `-var`/`-var-file` flags on the command line, in the order given

---

### Q17. How do you deploy the same code to multiple AWS regions at the same time?
**Answer:** Provider **aliasing** (`15October_Terraform.md` §4) — multiple `provider "aws"` blocks, each with its own `alias`, each resource picking one explicitly.

**Example:**
```hcl
provider "aws" {
  alias  = "ca_central_1"
  region = "ca-central-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_instance" "ca" {
  provider = aws.ca_central_1
  # ...
}

resource "aws_instance" "us" {
  provider = aws.us_east_1
  # ...
}
```

---

### Q18. I created a secret manually (e.g. in AWS Secrets Manager) — how do I read it from Terraform?
**Answer:** Use a **data source** — it reads information about something that already exists, without bringing it under Terraform's management.
```hcl
data "aws_secretsmanager_secret" "db" {
  name = "prod/db/password"
}

data "aws_secretsmanager_secret_version" "db" {
  secret_id = data.aws_secretsmanager_secret.db.id
}

# Used elsewhere, e.g.:
# password = data.aws_secretsmanager_secret_version.db.secret_string
```

---

### Q19. I have an existing Route 53 domain — how do I create new records under it with Terraform?
**Answer:** Same idea — a data source fetches the existing hosted zone, then a normal `resource` block creates the new record inside it.
```hcl
data "aws_route53_zone" "existing" {
  name = "example.com"
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.existing.zone_id
  name    = "app.example.com"
  type    = "A"
  ttl     = 300
  records = ["203.0.113.10"]
}
```
⚠️ **The key point about data sources:** they only *read* information — they never get added to the state file as something Terraform "owns," and `terraform destroy` never touches them.

---

### Q20. How do you bring a manually-created resource under Terraform's management?
```bash
terraform import aws_instance.my_ec2 i-0abcd1234efgh5678
```
Full walkthrough in `30October_Terraform_Import.md`. Once imported, `terraform destroy` **will** delete it — unlike a data source (Q19), an imported resource genuinely becomes something Terraform owns.

---

### Q21. What does your Terraform folder structure typically look like?
**Answer:** It depends on how similar the environments are:
- If **Dev/QA/Prod are structurally identical** → one codebase, driven by **workspaces** + per-environment `.tfvars` files (`23October_Terraform_Workspaces.md`).
- If **Dev/QA/Prod genuinely differ** → separate folders per environment.
- Either way, shared pieces (VPC, EC2, RDS patterns) get pulled into **modules** (`26October_Terraform_Modules.md`) and reused.

---

### Q22. How do you import a large number of existing resources into Terraform at once?
**Answer:** Doing it one `terraform import` at a time doesn't scale. A tool like **Terraformer** can scan an existing AWS account and generate matching `.tf` files + state automatically.
1. First, map out the dependencies between the resources.
2. Then import/generate them in an order that respects those dependencies.

---

### Q23. How are dependencies created between resources in Terraform?
**Answer:** Two kinds:
- **Implicit** — just by referencing another resource's attribute. Terraform figures out the build order on its own (`16October_Terraform_MiniProject.md` §2).
  ```hcl
  resource "aws_subnet" "example" {
    vpc_id = aws_vpc.default.id   # implicit dependency on aws_vpc.default
  }
  ```
- **Explicit** — using `depends_on`, for a real-world ordering requirement that *isn't* visible through any attribute reference (`16October_Terraform_MiniProject.md` §2).
  ```hcl
  resource "aws_instance" "app" {
    depends_on = [aws_db_instance.db]
  }
  ```

---

### Q24. How many resources does Terraform create in parallel, and can you change that?
**Answer:** Terraform creates/updates resources in parallel by default, up to **10 at a time**. You can change it:
```bash
terraform apply -parallelism=20
```

---

### Q25. Why don't we just commit the state file to a Git repo instead of using a remote backend?
**Answer:** **Security, not file size.** The state file commonly contains sensitive values (passwords, access keys, connection strings) in **plain text**. Committing it to Git means anyone with repo access — and anyone who ever clones it, forever, since Git keeps full history — can read those secrets. (File size isn't the real blocker either — Git LFS exists for large files.) This is exactly the same class of problem `2Nov_Vault.md`'s approach is meant to avoid.

---

### Q26. Terraform execution got interrupted and the state file is now locked — how do you unlock it?
```bash
terraform force-unlock <LOCK_ID>
```
⚠️ Only do this once you're sure the original process actually crashed and isn't still running — covered in `23October_Terraform_StateLocking.md` §7.

---

### Q27. What is Terragrunt, and why would you need it?
**Answer:** Terraform does **not** automatically look inside subfolders — if you have:
```
main.tf
dev/main.tf
prod/main.tf
```
running `terraform apply` at the root only sees the root's own `main.tf`; it ignores `dev/` and `prod/` entirely. **Terragrunt** is a thin wrapper around Terraform that *can* walk into subfolders and run Terraform in each one — useful for keeping many near-identical environment folders DRY and consistent.

---

### Q28. What's the actual difference between Terraform and Terragrunt?
**Answer:** **Terraform** is the IaC tool itself — it creates and manages real infrastructure. **Terragrunt** doesn't create anything on its own — it's an orchestration layer *on top of* Terraform, for running Terraform consistently across many folders/environments (remote-backend config reuse, consistent variable injection, running multiple modules in dependency order, etc.).

---

## Part B — Functions, Lifecycle, Provisioners & `null_resource`

### Q29. If you need to create 10 identical virtual machines, how do you do it?
**Answer:** `count` is the simplest fit here — identical resources, no meaningful individual names needed. (`for_each`, covered in `10November_Terraform_ForEach.md`, is the better fit once each instance needs its *own* name or settings.)
```hcl
resource "aws_instance" "web" {
  count         = 10
  ami           = "ami-0ed59cbb87dfa8dba"
  instance_type = "t3.micro"

  tags = {
    Name = "web-${count.index}"
  }
}
```

---

### Q30. What's the real difference between `count` and `for_each`?
**Answer:**
- `count` takes a **number** (or the length of a list) and gives you **numeric indexes**: `resource[0]`, `resource[1]`, ...
- `for_each` takes a **map or a set of strings** and gives you **named keys**: `resource["dev"]`, `resource["prod"]`, ... — full comparison and worked examples in `10November_Terraform_ForEach.md` §7.

**To pull a specific value out of a list by position (what `count` is really doing under the hood):**
```hcl
variable "azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}

resource "aws_subnet" "example" {
  count             = length(var.azs)
  availability_zone = var.azs[count.index]   # indexing into the list by position
  # ...
}
```

---

### Q31. What are some commonly used Terraform functions?

| Function | What it does | Example |
|---|---|---|
| `element(list, index)` | Picks one item from a list by position (wraps around if the index is too large) | `element(["a","b","c"], 1)` → `"b"` |
| `lookup(map, key, default)` | Looks up a value in a map by key, with a fallback | `lookup({"us-east-1"="ami-111","us-east-2"="ami-222"}, var.region, "ami-default")` |
| `length(list)` | Number of items in a list | `count = length(var.public_subnet_cidrs)` |
| `toset(list)` | Converts a list to a set — removes duplicates **and** drops ordering | `toset([80, 443, 22, 80]) → {22, 80, 443}` |
| `distinct(list)` | Removes duplicates but **keeps** the original order | `distinct([80, 443, 22, 80]) → [80, 443, 22]` |
| `lower()` / `upper()` | Changes text case | `lower("DEV")` → `"dev"` |
| `split(sep, string)` | Splits a string into a list | `split(",", "dev,qa,prod")` → `["dev","qa","prod"]` |
| `join(sep, list)` | Joins a list into one string | `join("-", ["dev","qa","prod"])` → `"dev-qa-prod"` |

⚠️ There's no actual function literally called `count()` in Terraform — `count` by itself is the **meta-argument**, and `count.index` is how you read the current position inside the block using it. If you need to pick a value out of a list by position, that's `list[count.index]` or the real `element()` function — not a `count(...)` call.

---

### Q32. What is Terraform Console, and when would you use it?
```bash
terraform console
```
**Answer:** A REPL for trying out expressions/functions against your current configuration and state, without running `plan` or `apply` — handy for checking "does this `lookup()` call return what I expect?" before committing it into real code.

---

### Q33. How do you write conditional ("if") logic in Terraform?
**Answer:** The ternary operator — `condition ? value_if_true : value_if_false`.
```hcl
# Simple conditional
locals {
  readable_env = var.environment == "prod" ? "Production" : "Non-Production"
}

# A common real use: size differently for prod
resource "aws_instance" "app" {
  count         = var.environment == "prod" ? 3 : 1
  instance_type = var.environment == "prod" ? "t3.medium" : "t3.micro"
}
```

---

### Q34. What are dynamic blocks in Terraform?
**Answer:** A way to generate **repeated nested blocks** (like multiple `ingress` blocks inside one Security Group) from a list or map, instead of writing each one out by hand — effectively `for_each`, but for a block *inside* a resource rather than for the whole resource.

```hcl
variable "ingress_ports" {
  default = [22, 80, 443]
}

resource "aws_security_group" "web" {
  name   = "web-sg"
  vpc_id = aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```
This creates **three separate `ingress` rules** (22, 80, 443) from one `dynamic` block — note the loop variable here is named `ingress` (matching the block's own name, `ingress.value`), not `each.value`.

---

### Q35. How do you protect a resource from being destroyed, or control the order of replace vs destroy, or stop Terraform from "fixing" a tag change you made outside Terraform?
**Answer:** All three are controlled by the **`lifecycle`** block (⚠️ one word — not `life_cycle`, a common typo).

```hcl
resource "aws_instance" "critical" {
  # ...

  lifecycle {
    prevent_destroy        = true
    create_before_destroy  = true
    ignore_changes          = [tags, instance_type]
  }
}
```
- `prevent_destroy = true` — blocks `terraform destroy`/any plan that would destroy this specific resource, outright.
- `create_before_destroy = true` — when a replacement is needed anyway, build the new one **first**, then remove the old one (same pattern already used for the ACM certificate in `4November_Terraform_Module_ACM.md`).
- `ignore_changes = [tags, instance_type]` — tells Terraform to stop proposing to "undo" changes to just these specific attributes, even if they drift from what the code says.

⚠️ In practice, you'd rarely combine all three in one block the way shown above — `prevent_destroy` and `create_before_destroy` solve different problems. Pick the one(s) that actually match your situation.

---

### Q36. What do `terraform taint` and `terraform untaint` do?
```bash
terraform taint aws_instance.web      # mark it for recreation on the next apply
terraform untaint aws_instance.web    # remove that mark
```
**Answer:** `taint` forces Terraform to destroy and recreate a specific resource on the next `apply`, even though nothing in its configuration actually changed — useful when a resource is "broken" in some way Terraform itself can't detect. (Newer Terraform versions also support `terraform apply -replace=aws_instance.web`, which does the same thing in one step.)

---

### Q37. What provisioner types does Terraform support?
**Answer:** `file`, `remote-exec`, and `local-exec` are the three genuinely common ones (full detail in `28October_Terraform_Provisioners.md`). Chef, Puppet, Ansible, and Salt-masterless provisioners also exist, but are rarely used in practice — most teams reach for a dedicated configuration-management tool run separately instead of a Terraform provisioner for that.

---

### Q38. What is a `null_resource`, and when would you use one?
**Scenario:** you have a script that changes periodically, and whenever it changes, you want it copied to a remote server and re-run.

**Answer:** A `null_resource` is a resource that doesn't create any real infrastructure — it exists purely to **run provisioners** (`local-exec`/`remote-exec`/`file`) on demand, typically combined with `triggers` to control exactly when it re-runs.

```hcl
resource "null_resource" "run_script" {
  triggers = {
    script_hash = filemd5("${path.module}/script.sh")
  }

  provisioner "file" {
    source      = "${path.module}/script.sh"
    destination = "/tmp/script.sh"

    connection {
      type = "ssh"
      user = "ec2-user"
      host = var.target_host
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo /tmp/script.sh"
    ]

    connection {
      type = "ssh"
      user = "ec2-user"
      host = var.target_host
    }
  }
}
```
- `triggers = { script_hash = filemd5(...) }` is the key piece — Terraform re-runs this `null_resource` (and its provisioners) **only when the script's content actually changes** (its MD5 hash changes), not on every `apply`.
- ⚠️ Using `terraform taint` to force a re-run (as the original notes suggested) works, but a `triggers` block like this is the cleaner, automatic way to get the same result.

---

### Q39. What's the difference between `null_resource` and `terraform_data`?
**Answer:** `terraform_data` is the modern replacement for `null_resource` (available natively in current Terraform, no `terraform init`/provider download needed for it specifically, and no `lifecycle` quirks to work around) — same job (a place to attach provisioners/triggers with no real infrastructure behind it), simpler setup.

---

### Q40. How do you make a `null_resource`/`terraform_data` re-run only when a specific resource's tag changes?
**Answer:** Use `triggers` (or `triggers_replace` for `terraform_data`), referencing the exact attribute you care about.
```hcl
resource "terraform_data" "on_tag_change" {
  triggers_replace = aws_instance.web.tags["Version"]

  provisioner "local-exec" {
    command = "echo 'Version tag changed, re-running'"
  }
}
```

---

## Part C — Modules, Workspaces & Tooling

### Q41. What are Terraform modules?
**Answer:** A module is just Terraform code, packaged for one specific purpose, that you can reuse across projects instead of copy-pasting (full coverage in `26October_Terraform_Modules.md`). Typical examples: a `network` module (VPC/subnets/IGW/NAT/route tables), an `ec2` module, an `rds` module — exactly the shape of `4November_Terraform_3TierProject.md`'s nine modules.

---

### Q42. Where are modules stored, and what is a "module registry"?
**Answer:** Modules are normally version-controlled in Git (their own repo, or a subfolder), tagged with **semantic versions** (`0.1.0`, `1.0.0`, etc.). A **module registry** (public, or a private one inside an org) is just a catalog teams publish versioned modules to, so other teams can pull a specific version by reference instead of copying files around. Any change to the module's behavior — a new feature, a bug fix — should bump its version.

---

### Q43. What files typically make up a module?
**Answer:**
- `main.tf` — the actual resources.
- `variables.tf` — the inputs the module expects.
- `output.tf` — the values the module hands back to whoever calls it.

(Exactly the three-file pattern used throughout `4November_Terraform_Module_*.md`.)

---

### Q44. What are module outputs, and how do you pass a value from one module into another?
**Answer:** Outputs are how a module hands information back out — sometimes called the module's "return values." Another module (or the root project) can then reference `module.<name>.<output>` as an input.

```hcl
module "network" {
  source   = "./modules/network"
  vpc_cidr = "10.0.0.0/16"
}

module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id   # output of "network" feeding into "security"
}
```
This is exactly the module-composition pattern documented across `4November_Terraform_3TierProject.md` §2.

---

### Q45. You need identical infrastructure for three environments (Dev/UAT/Prod) — how do you avoid duplicating code?
**Answer:** **Modules** for the shared infrastructure pattern + **workspaces** (or separate `.tfvars` files) for the per-environment values.
- The module avoids duplicating the *code*.
- Workspaces (`23October_Terraform_Workspaces.md`) give each environment its own **state file**, so they never collide, while still running the exact same module.

---

### Q46. In simple terms, what do Terraform workspaces actually do?
**Answer:** They let the **same code** produce **separate state files** — one per environment. See `23October_Terraform_Workspaces.md` for the full `terraform workspace new/select/list` walkthrough.

---

### Q47. What's the difference between a Terraform module and a Terraform workspace?
**Answer:** A **module** is reusable *code*. A **workspace** is a separate *state file* for the same code. You typically use **both together**: one module, called once, run separately per workspace.

---

### Q48. What is Terraform Enterprise (or Terraform Cloud)?
**Answer:** HashiCorp's own hosted/paid platform for running Terraform as a team, on top of plain open-source Terraform. Commonly cited features:
- Sentinel policy-as-code (governance rules on what `apply` is allowed to do)
- Cost estimation
- Team collaboration + VCS integration (triggers a run on a Git push)
- API access
- Audit logging
- A private module registry
- Built-in workspaces
- Managed remote state + locking

---

### Q49. How do you authenticate Terraform against Terraform Cloud/Enterprise to store state there?
**Answer:** Generate an API token in Terraform Cloud, then set it as an environment variable:
```bash
export TF_TOKEN_app_terraform_io="<your-real-token>"
```
⚠️ Exactly like every other credential in this course — never hardcode this token in a `.tf` file; it belongs in an environment variable or a secrets manager only.

---

### Q50. How do you scan Terraform code for security issues before it's applied?
**Answer:** Static-analysis tools built specifically for Terraform/IaC — **Checkov**, **tfsec**, and **Terrascan** are the common ones. They catch things like publicly-open Security Groups, unencrypted S3 buckets, or an RDS instance without `publicly_accessible = false` — exactly the kind of mistakes already flagged by hand throughout `4November_Terraform_3TierProject.md`.

---

### Q51. How do you test Terraform code / do "unit testing" for infrastructure?
**Answer:** **Terratest** (a Go-based testing framework) is the most common tool — it actually `apply`s your Terraform code into a real (usually short-lived/sandbox) environment, runs assertions against the result, then tears it back down. It's closer to real integration testing than classic unit testing, since it genuinely provisions infrastructure to verify it behaves correctly — there's no way to "unit test" infrastructure code without actually standing some of it up.

---

## Quick Recap Table

| Topic | One-line takeaway |
|---|---|
| State file | Tracks current infrastructure; never commit it to Git — it can contain secrets |
| Remote backend + locking | S3 (native locking, or legacy + DynamoDB) / Azure Blob (built-in locking) |
| `terraform import` vs data sources | Import = Terraform now owns and can destroy it. Data source = read-only, never destroyed |
| `count` vs `for_each` | Numeric indexes vs named keys — pick based on whether instances need individual identity |
| `lifecycle` (one word) | `prevent_destroy`, `create_before_destroy`, `ignore_changes` |
| `null_resource` → `terraform_data` | Same job (run provisioners with no real infra), `terraform_data` is the modern replacement |
| Modules vs workspaces | Modules avoid duplicating code; workspaces avoid duplicating state files |
| Security scanning | Checkov / tfsec / Terrascan, run before `apply` |
| Testing | Terratest — genuinely provisions and verifies real infrastructure |
