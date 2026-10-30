# Batch 18 — Terraform Running Notes: 30 October 2026

**Topic: Terraform Quiz 1 — Questions & Answer Key**

Friends, this is the full quiz, with the correct answer marked ✅, for **Terraform Quiz 1** — covering everything from `13October_Terraform.md` through `30October_Terraform_Import.md`: fundamentals, providers, properties/immutability/idempotency, multi-region/multi-cloud, workspaces, state locking, modules, provisioners, remote backends, and import. Each question is followed by the reasoning behind the correct answer.

---

### Q1. What is Terraform?

- A) A configuration management tool
- B) An orchestration tool
- C) ✅ **An infrastructure as code (IaC) tool**
- D) A version control system

**Why:** Configuration management (A) describes tools like Ansible/Chef/Puppet — they configure *existing* servers, not provision infrastructure. Orchestration (B) describes tools like Kubernetes — managing already-running containers/workloads. Version control (D) is Git's job. Terraform's actual category is **IaC**. See `13October_Terraform.md` §1.

---

### Q2. What command is used to list all available workspaces in Terraform?

- A) `terraform workspaces list`
- B) `terraform list workspaces`
- C) `terraform show workspaces`
- D) ✅ **`terraform workspace list`**

**Why:** The subcommand is **singular** `workspace` (not `workspaces`), followed by `list`. A, B, and C all get the word order or pluralization wrong. See `23October_Terraform_Workspaces.md` §4.

---

### Q3. How can you create a new workspace named "production" in Terraform?

- A) `terraform workspace create production`
- B) `terraform create workspace production`
- C) ✅ **`terraform workspace new production`**
- D) `terraform new workspace production`

**Why:** The real subcommand is `workspace new`, not `workspace create` (A) or any `create`/`new` ordering that puts the verb first (B, D). See `23October_Terraform_Workspaces.md` §4.

---

### Q4. How can you pass values to Terraform variables from the command line?

- A) Using the `--set` flag followed by the variable name and value
- B) ✅ **By specifying variable values in a separate file and using the `-var-file` flag**
- C) Variables cannot be passed from the command line
- D) By setting environment variables with the naming convention `TF_VAR_variable_name`

**Why:** `--set` (A) isn't a real Terraform flag, and C is simply false — Terraform supports several ways to pass variables. This course's own hands-on used **`-var-file`** extensively (`21October_Terraform_Variables.md`, `22October_Terraform_MiniProject_Variables.md`) — e.g. `terraform apply -var-file="sbox.tfvars"` — which is why B is marked as the intended answer here.
⚠️ **Worth being precise, though:** D is *also* a genuinely real, documented way to pass variables — Terraform does read environment variables named `TF_VAR_<name>`. There's also a plain `-var "key=value"` flag (not listed as an option here) for a single value inline. If a quiz ever allows multiple correct answers, both B and D qualify — this question just isn't phrased that way.

---

### Q5. Which file is typically used to define resources in a Terraform configuration?

- A) ✅ **`main.tf`**
- B) `terraform.tfvars`
- C) `variables.tf`
- D) `outputs.tf`

**Why:** `terraform.tfvars` (B) holds *values*, `variables.tf` (C) holds variable *declarations*, `outputs.tf` (D) holds `output` blocks — none of these define the actual `resource` blocks. `main.tf` is the conventional home for your resources, as every file from `16October_Terraform_MiniProject.md` onward has shown.

---

### Q6. What is Terraform's scripting language for defining infrastructure configurations?

- A) YAML
- B) JSON
- C) ✅ **HCL (HashiCorp Configuration Language)**
- D) Shell script

**Why:** HCL is Terraform's own purpose-built, declarative language. Terraform *can* also read plain JSON (an alternative syntax), but HCL is the one actually used throughout this course and the one the question is really asking about. See `13October_Terraform.md` §1.

---

### Q7. What is the purpose of the `terraform plan` command?

- A) To apply changes to the infrastructure
- B) To destroy the current infrastructure
- C) To import existing infrastructure into Terraform
- D) ✅ **To show the execution plan for changes before applying them**

**Why:** A describes `apply`, B describes `destroy`, C describes `import` — `plan` is specifically the **dry run** step, showing `+`/`~`/`-` changes with nothing actually happening yet. See `13October_Terraform.md` §4.

---

### Q8. In Terraform, what does a resource represent?

- A) A set of variables
- B) A module
- C) ✅ **A piece of infrastructure, such as a virtual machine or network**
- D) A function or procedure

**Why:** A `resource` block is literally the thing being created — an EC2 instance, a VPC, an S3 bucket. Variables (A), modules (B), and functions (D) are all separate Terraform concepts that *configure* or *organize* resources, but aren't resources themselves.

---

### Q9. What command is used to initialize a Terraform working directory?

- A) ✅ **`terraform init`**
- B) `terraform setup`
- C) `terraform configure`
- D) `terraform start`

**Why:** `setup`, `configure`, and `start` aren't real Terraform subcommands. `terraform init` downloads providers and prepares the directory — see `13October_Terraform.md` §4.

---

### Q10. In Terraform, what is the purpose of a provider?

- A) It defines the configuration for a resource.
- B) It represents a set of resources and their configurations.
- C) It specifies the backend where Terraform stores its state.
- D) ✅ **It defines the credentials for connecting to a cloud or infrastructure API.**

**Why:** C actually describes a **backend** (`29October_Terraform_RemoteBackend.md` §1), not a provider — a common mix-up worth catching. B is closer to describing a **module**. A provider's real job (`14October_Terraform_Providers.md` §1) is broader than any single option here — it's the plugin/bridge that lets Terraform talk to a platform's API at all — but of the four choices, D captures the part of that job most options leave out entirely: a provider block is where region/credentials/account configuration for reaching that API actually lives.

---

### Q11. In Terraform, how can you switch to a different workspace named "testing"?

- A) `terraform switch workspace testing`
- B) `terraform select testing`
- C) ✅ **`terraform workspace select testing`**
- D) `terraform workspace switch testing`

**Why:** The real subcommand is `workspace select`, not `switch workspace` (A), a bare `select` (B), or `workspace switch` (D). See `23October_Terraform_Workspaces.md` §4.

---

### Q12. What does the `terraform destroy` command do?

- A) Initializes the working directory
- B) ✅ **Destroys the current infrastructure**
- C) Applies changes to the infrastructure
- D) Shows the execution plan without applying changes

**Why:** A describes `init`, C describes `apply`, D describes `plan`. `destroy` tears down every resource Terraform created for the configuration. See `13October_Terraform.md` §4.

---

### Q13. What is the main purpose of Terraform's state file?

- A) To store sensitive information
- B) To track changes made to the infrastructure
- C) ✅ **To maintain the current state of the infrastructure**
- D) To store provider configurations

**Why:** The state file's core job is tracking **what currently exists** and how it maps to your code — exactly the phrasing used in `13October_Terraform.md` §3 ("track the current state of your infrastructure"). B is close but describes more of a side effect (you can infer changes by comparing states over time) than the file's actual purpose. A and D are simply not what the state file is for — it can incidentally *contain* sensitive data, but that's not its purpose, and provider configuration lives in `.tf` files, not the state.

---

### Q14. How does Terraform manage infrastructure versions?

- A) Using a centralized server
- B) ✅ **Using state files**
- C) Using configuration management tools
- D) Using Docker containers

**Why:** Terraform isn't inherently client-server (A, unless you're using Terraform Cloud specifically), doesn't rely on separate config-management tools (C) to track its own infrastructure, and has nothing to do with Docker by default (D). The state file is what tracks the current version/snapshot of your infrastructure.

---

### Q15. What is a "backend" in Terraform?

- A) ✅ **A way to keep state files on remote storage**
- B) A configuration for managing container deployments
- C) A database configuration for Terraform
- D) A version control system

**Why:** This matches `29October_Terraform_RemoteBackend.md` §1 exactly: "Backend defines where Terraform stores its state file... Remote Backend: stores state in a remote location." B, C, and D aren't what a backend is at all.

---

### Q16. Which of the following is a Terraform provisioner?

- A) `local-exec`
- B) `file`
- C) `remote-exec`
- D) ✅ **All of the above**

**Why:** All three — `local-exec`, `file`, and `remote-exec` — are the three real provisioner types covered in `28October_Terraform_Provisioners.md` §2. None of them individually is "the" provisioner; they're all valid types.

---

### Q17. How can you import existing infrastructure into Terraform?

- A) Using `terraform apply`
- B) ✅ **Using `terraform import`**
- C) Using `terraform validate`
- D) Using `terraform plan`

**Why:** `apply` creates/changes infrastructure, `validate` checks syntax, `plan` previews changes — none of these bring *existing, unmanaged* infrastructure under Terraform's tracking. Only `terraform import` does that. See `30October_Terraform_Import.md` §3.

---

### Q18. How do you pass variables to a Terraform configuration?

- A) Using command-line flags
- B) Using a `terraform.tfvars` file
- C) Setting environment variables
- D) ✅ **All of the above**

**Why:** Unlike Q4 (which asked specifically about *command-line* methods), this question asks about variables in general — and all three really are valid: command-line flags (`-var`/`-var-file`), a `terraform.tfvars` file (auto-loaded, `21October_Terraform_Variables.md` §3), and `TF_VAR_*` environment variables. This question's "All of the above" is the direct confirmation that Q4's env-var option (D there) is genuinely valid too — it just wasn't the single best answer to Q4's narrower command-line-specific phrasing.

---

### Q19. How can you configure a subnet to route traffic to a custom route table in Terraform?

*(Open-ended — no multiple-choice options provided.)*

**Answer:**
```hcl
resource "aws_route_table_association" "prod-rta" {
  subnet_id      = aws_subnet.prod-subnet.id
  route_table_id = aws_route_table.prod-rt.id
}
```
- The `aws_route_table_association` resource is specifically what links a subnet to a route table — exactly the pattern used in `16October_Terraform_MiniProject.md` Step 5. Without this resource, a subnet just uses the VPC's default route table instead of your custom one.

---

### Q20. How do you create a VPC in Terraform?

*(Open-ended — no multiple-choice options provided.)*

**Answer:**
```hcl
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.81.0.0/16"

  tags = {
    Name = "prod-vpc"
  }
}
```
- The `aws_vpc` resource type, with a required `cidr_block` argument — the same first step used in every mini-project build since `16October_Terraform_MiniProject.md`.

---

## Quick Recap Table

| # | Topic | Correct answer | One-line reasoning |
|---|---|---|---|
| 1 | What is Terraform | IaC tool | Not config management, orchestration, or VCS |
| 2 | List workspaces | `terraform workspace list` | Singular "workspace" |
| 3 | Create a workspace | `terraform workspace new production` | `workspace new`, not `workspace create` |
| 4 | Pass variables via CLI | `-var-file` flag | What this course's hands-on actually used |
| 5 | File defining resources | `main.tf` | Not tfvars/variables.tf/outputs.tf |
| 6 | Terraform's language | HCL | Can also read JSON, but HCL is primary |
| 7 | Purpose of `terraform plan` | Shows execution plan before applying | Dry run — nothing happens yet |
| 8 | What a resource represents | A piece of infrastructure | Not a variable, module, or function |
| 9 | Initialize working directory | `terraform init` | Downloads providers, prepares the dir |
| 10 | Purpose of a provider | Defines credentials for the API connection | Not a backend, not a module |
| 11 | Switch workspace | `terraform workspace select testing` | `workspace select`, not `switch` |
| 12 | `terraform destroy` | Destroys the current infrastructure | Not init/apply/plan |
| 13 | Main purpose of state file | Maintains the current state of infrastructure | Not sensitive-data storage or provider config |
| 14 | How Terraform tracks versions | State files | Not a central server, CM tool, or Docker |
| 15 | What is a backend | Keeps state file on remote storage | Matches `29October_Terraform_RemoteBackend.md` exactly |
| 16 | Which is a provisioner | All of the above | `local-exec`, `file`, `remote-exec` all real |
| 17 | Import existing infra | `terraform import` | Not apply/validate/plan |
| 18 | Ways to pass variables | All of the above | CLI flags, tfvars file, env vars — all valid |
| 19 | Subnet → custom route table | `aws_route_table_association` | Links subnet_id + route_table_id |
| 20 | Create a VPC | `resource "aws_vpc" { cidr_block = ... }` | First step of every mini-project build |
