# Batch 18 — Terraform Running Notes: 13 October 2026

**Topic: Terraform Fundamentals — IaC, Architecture, Lifecycle**

Friends, this is a new folder — **Terraform** — separate from everything we've built so far in `AWS-CLOUD/`. Everything up to now (EC2, VPC, RDS, Route 53, ACM, CloudFront, WAF) was built by clicking through the AWS Console. Terraform is how you build the **exact same infrastructure** from **code** instead — written once, version-controlled, and re-run identically as many times as you need. Today covers the big picture and the core workflow; tomorrow (`14October_Terraform_Providers.md`) goes deeper into Providers specifically.

---

## 1. What is Terraform?

- **Terraform** = an open-source **Infrastructure as Code (IaC)** tool, built by **HashiCorp**.
- It lets you **define, provision, and manage infrastructure** (servers, databases, networks, load balancers, and more) using **declarative configuration files**.
- Written in **HCL (HashiCorp Configuration Language)**, or JSON.
- "Declarative" means: you describe the **end state** you want ("I want one EC2 instance, this VPC, this S3 bucket") — Terraform figures out *how* to get there, rather than you scripting each individual step yourself.

**Example of what Terraform manages:**
```
EC2
VPC
S3
Load Balancer
```

---

## 2. Why Terraform — the real benefits

- **Setup and maintenance** of infrastructure across many cloud providers, from one tool.
- **Automation** — no need to manually click through console screens.
- **Version control** — your infrastructure's definition lives in Git, exactly like application code (commit history, pull requests, rollbacks, all of it).
- **Repeatable** — run the exact same configuration in dev, staging, and production, and get the same result every time.
- **Multi-cloud** — the same tool, the same workflow, works across AWS, Azure, GCP, and more — only the *provider block* changes.

**Easy memory trick:** Terraform turns "click 40 times in the AWS console" into "run one command, get the same 40 things, every time."

---

## 3. Core architecture components

### Terraform Core (the CLI)
- Written in **Go**.
- **Parses** your `.tf` configuration files and figures out what needs to happen.

### Providers
- **Plugins** that let Terraform actually talk to a cloud/service's API — AWS, Azure, GCP, Kubernetes, Docker, GitHub, and many more.
- **Terraform itself cannot talk to AWS directly** — the provider is the bridge in between.
- Each provider **defines the types of resources** you can manage through it (e.g. the AWS provider is what makes `aws_instance`, `aws_vpc`, `aws_s3_bucket` exist as resource types at all).

### State File (`terraform.tfstate`)
- A **JSON file** that stores metadata about everything Terraform is currently managing.
- Used to **track the current state** of your infrastructure — what exists, and how it maps to your configuration.
- Can be stored **locally** (a file on disk) or **remotely** (e.g. an S3 bucket, Azure Blob Storage).
- Remote storage is what enables **team collaboration** on the same infrastructure.
- **State locking** (used with remote storage) stops two people running `apply` at the same time and corrupting the state.
- ⚠️ **Without the state file, Terraform has no way to track what it's already created.** It's the single most important file in any Terraform project — losing it is a genuinely painful problem in real projects.

**Easy memory trick:** `Core = the engine`, `Provider = the translator`, `State = the memory.`

---

## 4. The Terraform lifecycle (workflow)

Terraform always follows the same five-stage lifecycle:
```
1) Write  → 2) Init  → 3) Plan  → 4) Apply  → 5) Destroy
```

### Stage 1 — Write
- Create your configuration in `.tf` files.
- Typical file layout: `provider.tf`, `main.tf`, `variables.tf` — these files **define** the infrastructure you want.

### Stage 2 — `terraform init`
```bash
terraform init
```
**Purpose:**
- Initializes the working directory.
- **Downloads the required providers** (e.g. the AWS provider plugin).
- Creates a local `.terraform/` folder.
- Prepares the directory to actually run Terraform commands.
- You run this **once** per new/cloned project, and again any time you add a new provider.

### Stage 3 — `terraform plan`
```bash
terraform plan
```
**Purpose:**
- Shows exactly what Terraform **will** create, change, or delete — **nothing happens yet.**
- Effectively a **dry run** — your safety check before touching real infrastructure.

**Example output:**
```
+ create EC2 instance
~ modify security group
- delete resource
```
- `+` = will be created.
- `~` = will be modified in place.
- `-` = will be destroyed.
- Always read a `plan` output carefully before applying — it's your last chance to catch a mistake before it becomes a real change.

### Stage 4 — `terraform apply`
```bash
terraform apply
```
**Purpose:**
- **Actually creates or modifies** the infrastructure — executes the plan from Stage 3.
- Prompts for confirmation (`yes`) before proceeding, by default.
- After confirming: the resources genuinely get created in AWS (or whichever provider).

### Stage 5 — `terraform destroy`
```bash
terraform destroy
```
**Purpose:**
- **Deletes every resource** Terraform created for this configuration.
- Used for cleanup — e.g. tearing down a test/demo environment so you stop paying for it.
- ⚠️ Just like `apply`, this is irreversible once confirmed — there's no "undo" for a destroyed EC2 instance or deleted RDS database.

**Simple visual summary:**
```
Write code → terraform init → terraform plan → terraform apply → Infrastructure created
```

---

## 5. The real DevOps workflow — Terraform in a team/CI-CD setting

```
Developer writes Terraform code
         │
         ▼
Code stored in Git
         │
         ▼
CI/CD pipeline runs Terraform
         │
         ▼
Infrastructure created automatically
```
- This is the production version of the lifecycle in §4 above.
- Instead of a person typing `terraform apply` on their laptop, a pipeline (Jenkins, GitHub Actions, etc.) runs it automatically.
- This normally happens right after a code review/merge, not on every single commit.
- The state file is kept remote (§3) so the whole team shares one source of truth.

---

## 6. Installing Terraform and the AWS CLI

**Terraform:**
```
Download from: https://developer.hashicorp.com/terraform/install
```
- Install it, then confirm `terraform` works from any terminal (it should be on your PATH).

**AWS CLI** (needed so Terraform's AWS provider can actually authenticate):
```bash
aws configure
```
- Prompts for: **Access Key ID**, **Secret Access Key**, **Default region**, **Default output format**.
- Exactly the same `aws configure` flow already covered in `22September_CLI.md` §3.

⚠️ **Never hardcode your AWS Access Key/Secret Key into a `.tf` file, a script, or any file that goes into Git.**
- Same rule already flagged in `25September_RDS.md` for database passwords — it applies just as strongly here.
- Treat your AWS credentials exactly like a password.
- Configure them once via `aws configure` (stored outside your project, in your home directory).
- Let Terraform's AWS provider pick them up from there automatically — never paste them into a `.tf` file.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Terraform | HashiCorp's open-source IaC tool | Define EC2/VPC/S3 in code instead of clicking the console |
| HCL | The declarative language Terraform configs are written in | `.tf` files |
| Provider | Plugin bridging Terraform to a platform's API | `provider "aws" { region = "ap-south-1" }` |
| State file (`terraform.tfstate`) | Tracks what Terraform has already created | Store remotely (e.g. S3) for team collaboration + locking |
| `terraform init` | Downloads providers, prepares the working directory | Run once per project, and after adding a new provider |
| `terraform plan` | Dry run — shows what *would* change | `+ create`, `~ modify`, `- delete` |
| `terraform apply` | Actually creates/changes real infrastructure | Prompts for `yes` confirmation by default |
| `terraform destroy` | Deletes everything Terraform created | Cleanup after a demo/test environment |
| Real DevOps workflow | Code → Git → CI/CD pipeline → infrastructure | No one runs `apply` by hand in production |
| Credential handling | Never hardcode AWS keys in `.tf` files or Git | Use `aws configure` instead — same rule as DB passwords |
