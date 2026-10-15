# Batch 18 — Terraform Running Notes: 15 October 2026

**Topic: Terraform Properties, Immutable vs Mutable, Idempotency, Multi-Region, and Multi-Cloud**

Friends, with the fundamentals (`13October_Terraform.md`) and Providers (`14October_Terraform_Providers.md`) in place, today covers three core concepts every Terraform user needs to reason correctly about *what actually happens* when you run `apply` — and then puts that understanding to work across **multiple regions**, and even **multiple cloud providers**, in a single configuration.

---

## 1. Terraform properties (arguments)

- **Properties** (more precisely called **arguments**) are the key-value pairs inside a resource block that define exactly how that resource should be configured.

**Example:**
```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags = {
    Name = "example-instance"
  }
}
```
- `ami` — specifies the Amazon Machine Image to boot from.
- `instance_type` — specifies the instance's compute size.
- `tags` — a map defining metadata for the instance (its `Name`, in this case).

Nothing new mechanically here versus every resource block we've already written — this is just the formal name for "the settings you put inside the `{ }`."

---

## 2. Immutable vs Mutable infrastructure

| | Immutable infrastructure | Mutable infrastructure |
|---|---|---|
| Definition | Once created, a resource is **never modified** — any change means destroying it and creating a new one | Existing resources **can be modified in place** after creation |
| Example | Replacing an EC2 instance entirely to change its AMI | SSH-ing into a running server and manually editing its config |
| Risk of drift | Low — every environment is rebuilt from the same code | High — manual in-place changes accumulate and go untracked |

- **Terraform promotes immutable infrastructure** — by encouraging **declarative configuration** (you declare the end state, not the steps) backed by **version control**, the "fix" for almost any problem becomes "change the code, re-apply," not "log in and hand-edit something."
- This doesn't mean Terraform *never* modifies resources in place — some changes (like adding a tag) genuinely do update the existing resource. But Terraform's overall philosophy, and the behavior it nudges you toward, is replace-don't-patch wherever the underlying resource allows it.

**Easy memory trick:** Mutable = "fix the same server." Immutable = "throw it away, build a new one from the same code." Terraform leans hard toward the second.

---

## 3. Idempotent

- **Idempotent** = applying the **same configuration multiple times** produces the **same result** every time — running `terraform apply` again when nothing has actually changed does **nothing**, rather than creating duplicates or erroring out.
- Terraform achieves this by comparing your `.tf` configuration against the **state file** (`13October_Terraform.md` §3) on every run — it only acts on the *difference* between what's declared and what's already there.

**Example:**
```
terraform apply   → creates 1 EC2 instance
terraform apply   → (nothing changed) → "No changes. Your infrastructure matches the configuration."
terraform apply   → (again) → still nothing happens
```
**Easy memory trick:** Idempotent = "doing it twice is the same as doing it once." This is precisely *why* `terraform plan` before every `apply` is safe and useful — you're always seeing the actual delta, never a blind re-run of everything from scratch.

---

## 4. Terraform in multi-region (single cloud, two regions)

**The problem:** one `provider "aws"` block only points at one region. What if you need resources in **two AWS regions at once**, inside the same configuration?

**The answer: provider `alias`.**

```hcl
provider "aws" {
  region = "us-east-1"
  alias  = "nv"
}

provider "aws" {
  region = "ap-south-1"
  alias  = "mumbai"
}

resource "aws_instance" "sbox_nv" {
  ami           = "ami-053a45fff0a704a47"
  instance_type = "t2.micro"
  key_name      = "madhukey"

  provider = aws.nv

  tags = {
    Name = "sbox-nv"
  }
}

resource "aws_instance" "sbox_mumbai" {
  ami           = "ami-0ddfba243cbee3768"
  instance_type = "t2.micro"
  key_name      = "mumbaib15"

  provider = aws.mumbai

  tags = {
    Name = "sbox-mumbai"
  }
}
```

**What's happening, piece by piece:**
- Two `provider "aws"` blocks, each given a unique **`alias`** (`nv`, `mumbai`) so Terraform can tell them apart — without an alias, Terraform wouldn't know which one a resource should use.
- Each `resource` then explicitly picks one via `provider = aws.<alias>`.
- Same resource type (`aws_instance`), same `.tf` file, same single `terraform apply` — only the `provider = ...` line decides which region each instance actually lands in.
- ⚠️ **AMI IDs are region-specific** — that's exactly why this example uses two *different* `ami` values for the two instances, even though both are the same `t2.micro` type. An AMI from `us-east-1` simply doesn't exist in `ap-south-1`.

**Why this matters in real projects:** disaster recovery (a standby copy in a second region), lower latency for users in different geographies (the same underlying motivation as CloudFront's edge locations — `30September_CloudFront.md` — just at the compute layer instead of the CDN layer), and data-residency/compliance requirements that pin certain workloads to a specific region.

---

## 5. Terraform on multiple cloud providers

Provider aliasing isn't limited to *one* cloud, either — the exact same pattern works **across** AWS, GCP, and Azure in a single configuration, because each is just a different `provider` block.

```hcl
provider "aws" {
  region = "us-east-1"
  alias  = "aws"
}

provider "google" {
  project = "my-gcp-project"
  region  = "us-central1"
  alias   = "gcp"
}

provider "azurerm" {
  features {}
  alias = "azure"
}
```

**Creating one resource per cloud, each pinned to its own provider:**

```hcl
# EC2 instance in AWS
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  provider      = aws.aws

  tags = {
    Name = "example-aws-instance"
  }
}

# VM in GCP
resource "google_compute_instance" "example" {
  name         = "example-gcp-instance"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  provider     = google.gcp

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

# VM in Azure
resource "azurerm_virtual_machine" "example" {
  name                  = "example-azure-vm"
  location              = "East US"
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_B1s"
  provider              = azurerm.azure

  storage_os_disk {
    name              = "example-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "adminuser"
    # admin_password intentionally omitted here — see the callout below
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
```

**What's genuinely new here, versus §4's AWS-only example:**
- Three **completely different provider types** (`aws`, `google`, `azurerm`) in the **same configuration** — each resource (`aws_instance`, `google_compute_instance`, `azurerm_virtual_machine`) is a type that only exists because its matching provider is declared, exactly like §3 of `14October_Terraform_Providers.md`.
- This is the real meaning of "multi-cloud" with Terraform: **one tool, one workflow, one `apply`**, managing infrastructure that physically lives on three unrelated companies' infrastructure, side by side.
- Each cloud's resource syntax is naturally different (GCP uses `boot_disk`/`network_interface`, Azure uses `storage_os_disk`/`os_profile`) — the *providers* differ, but the overall Terraform workflow (`write → init → plan → apply → destroy`) stays identical across all three.

⚠️ **Worth flagging plainly, since the course has repeated this rule since `25September_RDS.md` and `13October_Terraform.md`:** the original raw-notes example for the Azure VM included a hardcoded `admin_password = "P@ssw0rd1234!"` directly in the `.tf` file. **Never do this in real code** — it's shown here (with the line removed above) purely as the kind of mistake to actively avoid. Any VM password, like any database password or AWS access key, belongs in a secrets manager (Azure Key Vault, AWS Secrets Manager, HashiCorp Vault) or at minimum a Terraform variable marked `sensitive = true` and fed in some way other than plaintext in version-controlled code — never typed directly into a `.tf` file that goes into Git.

---

## 6. Mini real-time project — homework for 16 October

**Task, to be built hands-on tomorrow:**
1. Create a **VPC** — `10.81.0.0/16`
2. Create an **Internet Gateway**
3. Create a **Custom Route Table**
4. Create a **public Subnet** — `10.81.3.0/24`
5. Associate the subnet with the route table
6. Create a **Security Group** allowing ports 22, 80, 443 (or all ports/traffic, for this exercise)
7. Create a **Network Interface** with an IP in the subnet from step 4
8. Assign an **Elastic IP** to the network interface from step 7
9. Create an **EC2 instance** using it — and launch an application on it

This is, in effect, the exact same VPC/IGW/Subnet/SG/ENI/EIP/EC2 architecture already built by hand through the console back in `9September_VPC.md` through `11September_ENI.md` — the point of tomorrow's exercise is writing **all nine of those steps as Terraform resources**, so the same familiar architecture gets created with one `terraform apply` instead of nine separate console actions.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Property / argument | A key-value setting inside a resource block | `instance_type = "t2.micro"` |
| Immutable infrastructure | Change = destroy + recreate, not edit-in-place | Replacing an EC2 instance instead of SSH-ing in to patch it |
| Idempotent | Re-running the same config changes nothing if nothing changed | A second `terraform apply` reports "No changes" |
| Provider `alias` | Distinguishes multiple providers of the same type | `alias = "nv"` vs `alias = "mumbai"`, both `provider "aws"` |
| Multi-region | One config, multiple regions of the same cloud | `aws.nv` (us-east-1) + `aws.mumbai` (ap-south-1) |
| Multi-cloud | One config, multiple different cloud providers | `aws`, `google`, `azurerm` providers side by side |
| Never hardcode secrets in `.tf` | Same rule as DB/AWS credentials, now for VM passwords too | Use a secrets manager or a `sensitive = true` variable instead |
| Tomorrow's mini project | The familiar VPC/IGW/Subnet/SG/ENI/EIP/EC2 build — now in Terraform | Same architecture as `9September_VPC.md`–`11September_ENI.md`, written as code |
