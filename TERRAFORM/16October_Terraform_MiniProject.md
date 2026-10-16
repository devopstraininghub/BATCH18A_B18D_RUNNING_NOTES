# Batch 18 — Terraform Running Notes: 16 October 2026

**Topic: Mini Project — The VPC + EC2 Architecture, Built With Terraform**

Friends, yesterday's homework (`15October_Terraform.md` §6) was to rebuild a familiar architecture — VPC → Internet Gateway → Route Table → Subnet → Security Group → Network Interface → Elastic IP → EC2 — but this time in Terraform, instead of clicking through the console like we did back in `9September_VPC.md` through `11September_ENI.md`. Today we built it, end to end, and it worked. This file walks through the real `main.tf` we ran in class.

---

## 1. The full build, resource by resource

**Provider:**
```hcl
provider "aws" {
  region = "us-east-1"
}
```

**Step 1 — VPC:**
```hcl
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.81.0.0/16"

  tags = {
    Name = "prod-vpc"
  }
}
```
- Same CIDR (`10.81.0.0/16`) as the original console-built project in `17September_MiniProject.md`.

**Step 2 — Internet Gateway:**
```hcl
resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-igw"
  }
}
```
- `vpc_id = aws_vpc.prod-vpc.id` — attaches this IGW to the VPC created in Step 1.

**Step 3 — Route Table:**
```hcl
resource "aws_route_table" "prod-rt" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-igw.id
  }

  tags = {
    Name = "prod-rt"
  }
}
```
- One route: anything (`0.0.0.0/0`) goes out through the Internet Gateway from Step 2 — this is what makes the subnet below a **public** subnet.

**Step 4 — Public Subnet:**
```hcl
resource "aws_subnet" "prod-subnet" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.81.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod-subnet"
  }
}
```

**Step 5 — Associate the subnet with the route table:**
```hcl
resource "aws_route_table_association" "prod-rta" {
  subnet_id      = aws_subnet.prod-subnet.id
  route_table_id = aws_route_table.prod-rt.id
}
```
- Without this association, the subnet would just use the VPC's **default** route table — which has no route to the Internet Gateway, so nothing in it would be reachable from outside.

**Step 6 — Security Group (22, 80, 443 in; everything out):**
```hcl
resource "aws_security_group" "prod-sg" {
  name        = "prod-sg"
  description = "Allow all port 22 80 443 traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prod-sg"
  }
}
```
- Three separate `ingress` blocks — one per port (22 = SSH, 80 = HTTP, 443 = HTTPS).
- `protocol = "-1"` in the `egress` block means **all protocols** — this is Terraform's/AWS's way of writing "allow everything outbound," same idea as the "allow all" egress rule in `17September_MiniProject.md`'s single-SG setup.

**Step 7 — Network Interface, with a fixed private IP:**
```hcl
resource "aws_network_interface" "prod-eni" {
  subnet_id       = aws_subnet.prod-subnet.id
  private_ips     = ["10.81.3.33"]
  security_groups = [aws_security_group.prod-sg.id]

  tags = {
    Name = "prod-eni"
  }
}
```
- `private_ips = ["10.81.3.33"]` pins the ENI to a specific private IP inside the subnet's range, instead of letting AWS pick one automatically.

**Step 8 — Elastic IP, attached to that ENI:**
```hcl
resource "aws_eip" "prod-eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.prod-eni.id
  associate_with_private_ip = "10.81.3.33"
  depends_on                = [aws_internet_gateway.prod-igw] # EIP needs the IGW attached first

  tags = {
    Name = "prod-eip"
  }
}
```
- ⚠️ **`depends_on` here is a genuinely new Terraform concept — see §2 below.**

**Step 9 — The EC2 instance itself, using that ENI, with a startup script:**
```hcl
resource "aws_instance" "prod-fb-srv" {
  ami           = "ami-0ed59cbb87dfa8dba" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  key_name      = "mckey"

  network_interface {
    network_interface_id = aws_network_interface.prod-eni.id
    device_index         = 0
  }

  user_data = file("facebook.sh")

  tags = {
    Name = "prod-facebook-srv"
  }
}
```
- The instance doesn't get its own plain `subnet_id`/`security_groups` arguments — instead, it attaches directly to the **ENI** built in Step 7, which already has its subnet and Security Group baked in.

**Step 10 — Output the public IP once everything's created:**
```hcl
output "instance_public_ip" {
  value = aws_eip.prod-eip.public_ip
}
```
- After `terraform apply` finishes, this prints the Elastic IP straight to your terminal — no need to go hunting for it in the console.

---

## 2. Two genuinely new Terraform concepts, seen for the first time today

### The implicit dependency graph
- Every time you write `aws_vpc.prod-vpc.id` inside another resource, you're not just grabbing a value — you're telling Terraform **"this resource depends on that one."**
- Terraform builds a full dependency graph from these references automatically, and creates resources in the **correct order** on its own — VPC first, then IGW, then route table, then subnet, and so on — without you ever writing "create the VPC before the subnet" anywhere.
- This is why the `main.tf` above can list resources in a fairly natural top-to-bottom order and still work correctly even if you reordered the blocks — the *references* are what decide the real build order, not the order they're written in.

### `depends_on` — the explicit override
- Normally, Terraform figures out ordering on its own (above) — but sometimes two resources are related in a way that **isn't** expressed through a direct attribute reference.
- The Elastic IP in Step 8 needs the Internet Gateway to be **fully attached** to the VPC before AWS will let the EIP associate correctly — but the EIP resource itself never actually references `aws_internet_gateway.prod-igw` through any of its own arguments, so Terraform's automatic graph wouldn't otherwise know about this relationship.
- `depends_on = [aws_internet_gateway.prod-igw]` is how you **manually** tell Terraform "wait for this other resource first, even though I'm not referencing one of its values directly."
- **Easy memory trick:** most of the time, just reference the other resource's `.id` and Terraform figures out the order for free. Reach for `depends_on` only when there's a real-world ordering requirement that *isn't* visible in any attribute reference.

---

## 3. The `facebook.sh` startup script

```bash
#!/bin/bash

yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd

cat > /var/www/html/index.html <<'EOF'
... (styled HTML page, "Sample MC Facebook App") ...
EOF
```
- Same idea as the User Data scripts already covered in `4September_LB_UserData.md` — a shell script that runs once, automatically, the first time the instance boots.
- `yum install -y httpd` + `systemctl enable/start httpd` — installs and starts Apache, exactly like the original console-based mini project.
- The `cat > /var/www/html/index.html <<'EOF' ... EOF` block writes the actual webpage Apache serves — this time a small styled "Sample MC Facebook App" page instead of the plain page from `17September_MiniProject.md`.
- `user_data = file("facebook.sh")` in the `aws_instance` block (Step 9) is how Terraform reads the script's contents and hands it to AWS as the instance's User Data — you write the script as its own file, and Terraform just loads it in.

---

## 4. Full architecture — what actually got built

```
                    INTERNET
                       │
                       ▼
                 Internet Gateway (prod-igw)
                       │
                       ▼
                Route Table (prod-rt)
                 0.0.0.0/0 → IGW
                       │
                       ▼
            Public Subnet (prod-subnet)
               10.81.3.0/24, us-east-1a
                       │
                       ▼
         Network Interface (prod-eni)
          private IP: 10.81.3.33
          Security Group: prod-sg (22, 80, 443 in)
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
   Elastic IP (prod-eip)      EC2 Instance (prod-fb-srv)
   attached to the ENI         Amazon Linux 2, t2.micro
                                Apache + facebook.sh page
```
- This is exactly the same shape as `17September_MiniProject.md`'s console-built architecture — the only thing that changed is **how** it got built: nine console clicks became one `main.tf` and one `terraform apply`.

---

## 5. Verifying it worked

```bash
terraform init
terraform plan
terraform apply
```
- After `apply` finishes, Terraform prints the `output` block from Step 10 straight to the terminal:
```
Outputs:

instance_public_ip = "<the Elastic IP that was assigned>"
```
- Opening `http://<that IP>` in a browser should show the "Sample MC Facebook App" page from `facebook.sh` — the same end-to-end verification step as the original console-built project, just reached through Terraform this time.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Resource reference (`aws_vpc.prod-vpc.id`) | Links one resource to another, and tells Terraform the build order | Subnet/IGW/Route Table all reference the VPC's `id` |
| Implicit dependency graph | Terraform orders resource creation automatically from these references | No need to manually sequence VPC → IGW → Subnet → EC2 |
| `depends_on` | Manually forces an order Terraform can't infer on its own | EIP waiting for the IGW to be attached first |
| `protocol = "-1"` | Means "all protocols" in a Security Group rule | Used for the "allow all" egress rule |
| ENI-first EC2 networking | Attach the instance to a pre-built ENI, instead of a bare subnet+SG | `network_interface { network_interface_id = ... }` |
| `user_data = file("facebook.sh")` | Loads a separate shell script as the instance's boot-time script | Installs Apache and writes `index.html`, same as `4September_LB_UserData.md` |
| `output` block | Prints a value from the created infrastructure after `apply` | `instance_public_ip` printed straight to the terminal |
| Same architecture, two ways | Console (`17September_MiniProject.md`) vs Terraform (today) | Same VPC/IGW/Subnet/SG/ENI/EIP/EC2 shape, built two different ways |
