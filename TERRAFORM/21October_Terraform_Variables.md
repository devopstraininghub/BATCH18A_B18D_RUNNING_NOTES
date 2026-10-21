# Batch 18 — Terraform Running Notes: 21 October 2026

**Topic: Terraform File Segregation & Variables**

Friends, every `main.tf` so far (`13October_Terraform.md` through `16October_Terraform_MiniProject.md`) has had its values — AMI IDs, instance types, regions — typed directly into the resource blocks. Today's topic, **Terraform Variables**, fixes that: instead of hardcoding, we split the project into separate files and make the same code reusable across dev, sandbox, UAT, and production, just by swapping which values file we point at.

---

## 1. Why Terraform variables?

- Variables make infrastructure code **reusable and flexible**.
- Instead of hardcoding values like region, instance type, or environment name, we **define a variable** and pass its actual value in from an external file.
- This lets the **same Terraform code** be reused for multiple environments — dev, staging, production — without copy-pasting or editing `main.tf` each time.

---

## 2. Declaring a variable

```hcl
variable "region" {
  description = "AWS region"
  type        = string
}
```
- `description` — a plain-English note on what this variable is for (shows up in `terraform plan`/`apply` prompts too).
- `type` — the kind of value expected (`string`, `number`, `bool`, and more complex types like `list`/`map`).

**Using the variable elsewhere in the code:**
```hcl
provider "aws" {
  region = var.region
}
```
- `var.region` means: *"the actual value comes from a variable file, not from this line."*

---

## 3. `terraform.tfvars` — the default variable file

- `terraform.tfvars` is the **default** variable file.
- Terraform **automatically loads it** — no extra flag needed.

**Example:**
```hcl
region        = "ap-south-1"
instance_type = "t2.micro"
environment   = "dev"
```
- Run `terraform plan` or `terraform apply` as normal, and Terraform reads this file by itself.

---

## 4. Custom `.tfvars` files — one per environment

- Beyond the default file, you can create **custom** variable files, usually one per environment.

**Common naming:**
```
dev.tfvars
qa.tfvars
prod.tfvars
sbx.tfvars   (sandbox environment)
```

**Example `sbx.tfvars`:**
```hcl
region        = "ap-south-1"
instance_type = "t3.micro"
environment   = "sandbox"
```

**How to actually use a custom file — pass it explicitly with `-var-file`:**
```bash
terraform plan -var-file="sbx.tfvars"
terraform apply -var-file="sbx.tfvars"
```
- Unlike `terraform.tfvars`, a custom-named file is **never** loaded automatically — you must always pass it with `-var-file`.
- **Easy memory trick:** `terraform.tfvars` = the file Terraform reaches for on its own. Anything else = you have to hand it over yourself, every time.

---

## 5. What about `vars.yaml` or `provider.yaml`?

| | Is it a real Terraform file? | What it's actually for |
|---|---|---|
| **`vars.yaml`** | No — not natively read by Terraform | A YAML-formatted variable file, sometimes used in CI/CD automation pipelines that convert it into `.tfvars` before running Terraform |
| **`provider.yaml`** | No — not a standard Terraform file at all | Sometimes used by automation systems to store provider config separately; real Terraform provider configuration belongs in a `.tf` file (like `provider.tf`), not YAML |

- Terraform itself only understands `.tf` and `.tfvars` files natively — YAML files like these only work if some other script or pipeline tool converts them first.

---

## 6. A real DevOps project structure

```
terraform-project/
    main.tf           ← the actual resources
    variables.tf       ← every variable's declaration (name, type, description, default)
    provider.tf         ← provider configuration

    terraform.tfvars    ← default values (auto-loaded)
    dev.tfvars
    prod.tfvars
    sbx.tfvars           ← one values-file per environment
```
- **Easy memory trick:** `variables.tf` = the *shape* of each variable. `*.tfvars` = the *actual values* that fill that shape in, differently per environment.

---

## 7. Hands-on — today's actual practice folder

Today's practice code split exactly like §6, across four files — and ended with all three environment `.tfvars` files genuinely filled in.

**`provider.tf`:**
```hcl
provider "aws" {
  region = "us-east-1"
}
```

**`variables.tf`:**
```hcl
variable "ami_id" {
  description = "AWS AMI ID"
  type        = string
  # default     = "ami-0567589d25e06853e"
}

variable "instance_type" {
  description = "Type of AWS instance"
  type        = string
  # default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
  # default     = "mckey"
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  # default     = 2
}

variable "instance_env" {
  description = "Environment for the instance"
  type        = string
  # default     = "Lab-Instance"
}
```
- ⚠️ **Every `default` line is commented out.** A variable with **no default is a required variable** — Terraform **must** get its value from somewhere else (a `.tfvars` file, a `-var` flag, or it will stop and interactively prompt you for it). This is the opposite of yesterday's first draft, which had real defaults for everything.
- A fifth variable, **`instance_env`**, was added — used purely for tagging, so each environment's instances are labeled by their own name.

**`main.tf`:**
```hcl
resource "aws_instance" "server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  count         = var.instance_count

  tags = {
    Name = var.instance_env
  }
}
```
- `tags.Name` is now `var.instance_env` instead of a fixed string — so the exact same `main.tf` labels its instances `"lab"`, `"Sandbox"`, or `"test"`, purely depending on which `.tfvars` file you hand it.

**The four environment files, actually filled in:**

| File | `instance_env` | `key_name` | `instance_type` | `ami_id` | `instance_count` |
|---|---|---|---|---|---|
| `lab.tfvars` | `lab` | `test` | `t2.micro` | `ami-0567589d25e06853e` | `1` |
| `sbox.tfvars` | `Sandbox` | `jenkinskeys` | `t2.micro` | `ami-0567589d25e06853e` | `1` |
| `terraform.tfvars` | `test` | `madhu` | `t2.micro` | `ami-0567589d25e06853e` | `1` |
| `prod.tfvars` | `prod` | `ramanikey` | `t3.micro` | `ami-0b6d9d3d33ba97d99` | `1` |

```bash
terraform apply -var-file="lab.tfvars"     # creates an instance tagged "lab"
terraform apply -var-file="sbox.tfvars"    # creates an instance tagged "Sandbox"
terraform apply -var-file="prod.tfvars"    # creates a bigger t3.micro instance tagged "prod"
terraform apply                             # terraform.tfvars loads automatically — tagged "test"
```
- Notice `prod.tfvars` deliberately uses a **bigger instance type** (`t3.micro` vs `t2.micro` everywhere else) and its own AMI — exactly the kind of per-environment difference variables exist to make easy.
- Since every variable is required (no defaults), every single one of these files **must** supply all five values — leaving one out means Terraform stops and asks for it interactively, which is exactly the safety net a required variable is for.
- **Easy memory trick:** `default` set = optional, falls back quietly. `default` commented out/missing = required, Terraform will *always* ask — one way or another.

---

## 8. Workflow, end to end

1. Write the Terraform code, split into `main.tf` / `variables.tf` / `provider.tf`.
2. `terraform init` — same as every other project.
3. Run with the environment's variable file:
   ```bash
   terraform plan -var-file="sbox.tfvars"
   ```
4. Apply once you're happy with the plan:
   ```bash
   terraform apply -var-file="sbox.tfvars"
   ```

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `variable` block | Declares a variable's name, type, description, default | Lives in `variables.tf` |
| `var.<name>` | References a variable's value inside a resource/provider block | `instance_type = var.instance_type` |
| `terraform.tfvars` | The default values file — loaded automatically | No extra flag needed |
| Custom `.tfvars` (e.g. `sbox.tfvars`) | A per-environment values file | Must be passed explicitly |
| `-var-file="..."` | The flag that tells Terraform which custom file to use | `terraform apply -var-file="sbox.tfvars"` |
| `default` in a variable | Fallback value if no `.tfvars` overrides it | `apply` still works with zero `.tfvars` files |
| No `default` = required variable | Terraform must get the value from somewhere, or it prompts you | Today's `variables.tf` — every default commented out |
| Same `main.tf`, different tags | One resource block, environment-specific output | `Name = var.instance_env` → `"lab"`/`"Sandbox"`/`"test"` |
| File segregation | Splitting one project into `main.tf`/`variables.tf`/`provider.tf` | Keeps resources, variable shapes, and provider config separate |
| `vars.yaml` / `provider.yaml` | Not native Terraform formats | Only usable via an automation pipeline that converts them first |
