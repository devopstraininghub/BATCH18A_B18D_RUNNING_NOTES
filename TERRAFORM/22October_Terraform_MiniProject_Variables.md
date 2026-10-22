# Batch 18 — Terraform Running Notes: 22 October 2026

**Topic: The Variablized Mini Project — Four Independent Environments, One Codebase**

Friends, today combines everything so far: the full VPC + EC2 mini project (`16October_Terraform_MiniProject.md`) and file segregation + variables (`21October_Terraform_Variables.md`). Instead of one hardcoded VPC, the **exact same `main.tf`** now spins up a completely separate, isolated environment — its own VPC, its own subnet, its own IP, its own server — just by pointing at a different `.tfvars` file. Four environments (`lab`, `sbox`, `terraform`/prod, `uat`) were actually built today, side by side.

---

## 1. The big idea — same code, four separate environments

- On 21 October (`21October_Terraform_Variables.md`), variables only changed small things — an instance type, a tag name.
- Today, variables drive the **entire network**, not just the EC2 instance — a different VPC CIDR, a different subnet CIDR, a different private IP, for each environment.
- This means each environment is a **fully isolated VPC**, not just a differently-labeled copy of the same one.

---

## 2. `main.tf` — now fully variablized

```hcl
resource "aws_vpc" "prod-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "prod-vpc"
  }
}

resource "aws_subnet" "prod-subnet" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod-subnet"
  }
}

resource "aws_network_interface" "prod-eni" {
  subnet_id       = aws_subnet.prod-subnet.id
  private_ips     = var.eni_pvt_ip
  security_groups = [aws_security_group.prod-sg.id]

  tags = {
    Name = "prod-eni"
  }
}

resource "aws_eip" "prod-eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.prod-eni.id
  associate_with_private_ip = var.eni_pvt_ip[0]
  depends_on                = [aws_internet_gateway.prod-igw]

  tags = {
    Name = "prod-eip"
  }
}

resource "aws_instance" "prod-fb-srv" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  count         = var.instance_count

  network_interface {
    network_interface_id = aws_network_interface.prod-eni.id
    device_index         = 0
  }

  user_data = file("facebook.sh")

  tags = {
    Name = var.tag_server_name
  }
}

output "instance_public_ip" {
  value = aws_eip.prod-eip.public_ip
}
```
- The Internet Gateway, Route Table, and Security Group blocks are unchanged from `16October_Terraform_MiniProject.md` — only the pieces that genuinely differ *per environment* (VPC, subnet, IP, instance details, tag) became variables.
- `facebook.sh` is the exact same startup script as 16 October — no changes needed there at all.

---

## 3. A genuinely new idea — list-type variables

```hcl
variable "eni_pvt_ip" {
  description = "Private IP for the network interface"
  type        = list(string)
}
```
- `type = list(string)` — this variable holds a **list** of strings, not just one.
- Why a list, when it's only ever used for one IP? Because `aws_network_interface.private_ips` itself expects a **list** (an ENI can technically hold more than one private IP) — the variable's type has to match what the resource argument actually expects.

**Using a list variable:**
```hcl
private_ips                = var.eni_pvt_ip        # the whole list
associate_with_private_ip  = var.eni_pvt_ip[0]      # just the first item in it
```
- `var.eni_pvt_ip` on its own = the full list, e.g. `["10.81.3.33"]`.
- `var.eni_pvt_ip[0]` = **index into the list** and grab just the first value — the same `[0]` indexing you'd use in almost any programming language.
- **Easy memory trick:** `string` = one value. `list(string)` = many values, and you can access any one of them by its position with `[0]`, `[1]`, and so on.

---

## 4. `variables.tf` — every variable required, as a deliberate choice

```hcl
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "eni_pvt_ip" {
  description = "Private IP for the network interface"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Key pair name for the EC2 instance"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances to deploy"
  type        = number
}

variable "tag_server_name" {
  description = "Tag name for the EC2 instance"
  type        = string
}
```
- Same pattern as `21October_Terraform_Variables.md` §7 — every `default` is commented out, so **all eight variables are required**.
- This is a deliberate safety choice here: with a full VPC's networking on the line, you *want* Terraform to refuse to run with an accidental blank value, rather than silently falling back to some default CIDR that might collide with another environment.

---

## 5. The four environments, actually built today

| File | VPC CIDR | Subnet CIDR | Private IP | Key pair | Tag name |
|---|---|---|---|---|---|
| `lab.tfvars` | `10.82.0.0/16` | `10.82.3.0/24` | `10.82.3.33` | `ghakey` | `LAB-facebook-srv` |
| `sbox.tfvars` | `10.83.0.0/16` | `10.83.3.0/24` | `10.83.3.33` | `ajakey` | `SBOX-facebook-srv` |
| `terraform.tfvars` | `10.81.0.0/16` | `10.81.3.0/24` | `10.81.3.33` | `mckey` | `prod-facebook-srv` |
| `uat.tfvars` | `10.84.0.0/16` | `10.84.3.0/24` | `10.84.3.33` | `jenkinskey` | `UAT-facebook-srv` |

- All four use the same `instance_type` (`t2.micro`), same `ami_id`, and `instance_count = 1` — only the networking and identity details actually differ, which is realistic: most environments share the same basic sizing, but absolutely must **never** share the same network range.
- ⚠️ **Notice the VPC CIDRs are all different** (`10.81.x` / `10.82.x` / `10.83.x` / `10.84.x`) — this is exactly how you'd keep four real environments from ever being able to collide or get peered together by accident.

```bash
terraform apply -var-file="lab.tfvars"    # builds the whole lab VPC + server
terraform apply -var-file="sbox.tfvars"   # builds a completely separate sandbox VPC + server
terraform apply -var-file="uat.tfvars"    # and a separate UAT VPC + server
terraform apply                            # terraform.tfvars loads automatically → the "prod" one
```
- Each command above creates a **fully separate VPC**, not just a renamed copy — running `apply` with `lab.tfvars` and then again with `sbox.tfvars` genuinely builds two independent networks, each with its own IGW, route table, subnet, SG, ENI, EIP, and EC2 instance.

---

## 6. Verifying it worked

- Same verification as `16October_Terraform_MiniProject.md` §5 — after each `apply`, the `output` block prints that environment's Elastic IP:
```
Outputs:

instance_public_ip = "<that environment's Elastic IP>"
```
- Opening `http://<that IP>` should show the same "Sample MC Facebook App" page from `facebook.sh` — and because each environment has its own EC2 instance tagged by `var.tag_server_name`, the AWS Console instantly shows which environment is which (`LAB-facebook-srv`, `SBOX-facebook-srv`, etc.) without needing to dig through IPs or IDs.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Variablizing a whole architecture | Not just instance settings — VPC CIDR, subnet, private IP too | Each `.tfvars` file builds a fully separate VPC |
| `type = list(string)` | A variable holding multiple values, not just one | `eni_pvt_ip = ["10.81.3.33"]` |
| List indexing `var.name[0]` | Grabs one specific value out of a list variable | `associate_with_private_ip = var.eni_pvt_ip[0]` |
| Required variables for infra-critical values | Forces an explicit value, prevents silent CIDR collisions | No `default` on any of the 8 variables here |
| Four environments, one codebase | Same `main.tf`, four different `.tfvars` | `lab` / `sbox` / `terraform` (prod) / `uat` |
| Non-overlapping CIDRs per environment | Each environment's VPC uses a different /16 range | `10.81.x` / `10.82.x` / `10.83.x` / `10.84.x` |
| Tag-per-environment | Instantly tells environments apart in the AWS Console | `var.tag_server_name` → `LAB-facebook-srv`, etc. |
