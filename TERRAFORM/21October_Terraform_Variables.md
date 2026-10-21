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

Today's practice code split exactly like §6, across four files:

**`provider.tf`:**
```hcl
provider "aws" {
  region = "us-east-1"
}
```

**`variables.tf`:**
```hcl
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the key pair to use for the EC2 instance"
  type        = string
  default     = "my-key-pair"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}
```

**`main.tf`:**
```hcl
resource "aws_instance" "my_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  count         = var.instance_count

  tags = {
    Name = "MyInstance"
  }
}
```

- Notice `main.tf` now has **zero hardcoded values** — every single argument is a `var.*` reference back to `variables.tf`.
- Each variable also has a **`default`** — so even without any `.tfvars` file at all, `terraform apply` still works, using these defaults (`t2.micro`, 1 instance, etc.).
- Three `.tfvars` files were also created for this exercise — `terraform.tfvars`, `sbox.tfvars`, `lab.tfvars` — set up as the environment-specific override files from §4, ready to be filled in with different values per environment (e.g. a bigger `instance_type` and higher `instance_count` for `prod`, smaller for `sbox`/`lab`). **A `.tfvars` file only needs to list the variables you actually want to override** — any variable left out just falls back to its `default` from `variables.tf`.

**Example of what a filled-in `sbox.tfvars` would look like, following §4's pattern:**
```hcl
instance_type  = "t2.micro"
instance_count = 1
```
```bash
terraform apply -var-file="sbox.tfvars"
```

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
| File segregation | Splitting one project into `main.tf`/`variables.tf`/`provider.tf` | Keeps resources, variable shapes, and provider config separate |
| `vars.yaml` / `provider.yaml` | Not native Terraform formats | Only usable via an automation pipeline that converts them first |
