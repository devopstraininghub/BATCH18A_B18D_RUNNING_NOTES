# Batch 18 — Terraform Running Notes: 28 October 2026

**Topic: Terraform Provisioners (and why User Data usually beats them)**

Friends, every mini project so far (`16October_Terraform_MiniProject.md` onward) got its application installed via `user_data` — a script that runs automatically when the instance boots. Today's topic, **Provisioners**, is a *different* way to do the same job: Terraform itself connects into the instance (over SSH) and runs commands directly, right after creating it. We'll build the exact same mini project both ways and see why `user_data` usually wins.

---

## 1. What are provisioners?

- **Provisioners** execute scripts or commands **on a resource**, either **after it's created** or **before it's destroyed**.
- Think of them as a **"last-mile" configuration step** — the resource already exists, provisioners just finish setting it up.

---

## 2. The three types of provisioners

| Type | What it does |
|---|---|
| **`file`** | Copies a file from your **local machine** to the resource. |
| **`remote-exec`** | Runs commands **on the remote resource**, over SSH or WinRM. |
| **`local-exec`** | Runs commands on your **local machine** instead — not on the resource at all. |

---

## 3. Real-time use case

**Scenario:** launch an EC2 instance and automatically install Apache/httpd, so the server is ready immediately after creation — without relying on `user_data`.

**Teaching example:**
```hcl
resource "aws_instance" "prod_server" {
  ami           = "ami-0f559c3642608c138"
  instance_type = "t3.micro"
  key_name      = "madhukiran"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.prod_eni.id
  }

  tags = {
    Name = "Prod-fb-Server"
  }

  provisioner "local-exec" {
    command = "echo 'this is facebook server IP: ${aws_eip.prod_eip.public_ip}' > fb-server-ip.txt"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/keys/madhukiran.pem") # path to your own key file
    host        = aws_eip.prod_eip.public_ip
  }

  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/indx.html"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo cp /tmp/indx.html /var/www/html/index.html",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
    ]
  }
}
```
- `local-exec` here runs on **your own laptop** — it writes the server's public IP to a local text file, nothing to do with the EC2 instance itself.
- `connection` tells Terraform **how to reach the instance** (SSH, which user, which key, which host) — needed by both `file` and `remote-exec`.
- `file` copies `index.html` from your machine straight onto the instance.
- `remote-exec` then runs the actual setup commands **on the instance**, using the file `file` just copied over.

---

## 4. Execution flow

1. Terraform creates the EC2 instance.
2. Establishes an SSH connection, using the key pair from the `connection` block.
3. Executes the provisioner commands on the instance.
4. Apache/httpd ends up installed and running.

---

## 5. Important notes — why provisioners aren't the default choice

- Provisioners are **NOT recommended for regular use.**
- They are **not fully idempotent** — re-running them can cause issues (e.g. re-copying a file, re-running an install command that isn't safe to run twice).
- Should only be used when **no better alternative exists.**

**Preferred alternatives:**
- `user_data` / cloud-init scripts.
- Configuration management tools — Ansible, Chef, Puppet.

**Easy memory trick:** Provisioners = Terraform **reaching into** the box after it exists. `user_data` = the box **setting itself up** the moment it boots. The second one doesn't need Terraform to stay connected, SSH-reachable, or even online at the exact right moment.

---

## 6. Provisioners vs AWS User Data

| | Provisioners | User Data |
|---|---|---|
| **Execution time** | **After** the resource is created | **During** instance boot (passed at launch time) |
| **Dependency** | Needs network access (SSH/WinRM) | No external connection needed |
| **Reliability** | Less reliable — can fail if the connection fails | More reliable — runs internally on the instance |
| **Idempotency** | Not fully idempotent | Can be made idempotent with careful scripting |
| **Terraform's own stance** | Treated as a **last-resort** feature | The **preferred** method for initialization |

**Side-by-side comparison:**

**Using a provisioner:**
```hcl
resource "aws_instance" "example1" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo systemctl start nginx"
    ]
  }
}
```

**Using User Data (same end result):**
```hcl
resource "aws_instance" "example2" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash
              yum install nginx -y
              systemctl start nginx
              systemctl enable nginx
              EOF
}
```

**Execution flow, side by side:**

| Step | Provisioner flow | User Data flow |
|---|---|---|
| 1 | Terraform creates the EC2 instance | Terraform creates the EC2 instance |
| 2 | Waits for the instance to be reachable | Instance boots |
| 3 | Connects via SSH | Script runs automatically, inside the instance |
| 4 | Executes the commands | No external connection needed at all |

**Best practice:**
- **Use User Data** for installing packages, bootstrapping instances, and production environments.
- **Use Provisioners** only when `user_data` genuinely isn't sufficient, or for edge cases/quick fixes.

**Easy memory trick:** Provisioners = **external**, post-creation configuration. User Data = **internal**, boot-time initialization. User Data wins in most real-world scenarios.

---

## 7. Hands-on — rebuilding the mini project with provisioners

Today's lab took the exact same VPC/IGW/Subnet/SG/ENI/EIP/EC2 mini project from `16October_Terraform_MiniProject.md`, and swapped out `user_data = file("facebook.sh")` for **all three** provisioner types on one resource — `file`, `remote-exec`, and `local-exec` together:

```hcl
resource "time_sleep" "wait_60sec" {
  depends_on      = [aws_eip.prod-eip]
  create_duration = "30s"
}

resource "aws_instance" "prod-fb-srv" {
  ami           = "ami-0ed59cbb87dfa8dba"
  instance_type = "t2.micro"
  key_name      = "madhukey"

  network_interface {
    network_interface_id = aws_network_interface.prod-eni.id
    device_index         = 0
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/batch18keys/madhukey.pem") # path to your own key file
    host        = aws_eip.prod-eip.public_ip
  }

  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "sudo mv /tmp/index.html /var/www/html/index.html"
    ]
  }

  provisioner "local-exec" {
    command = "echo 'THIS IS A TEST FILE TO TEST LOCAL EXEC PROVISIONER' >> localfile.txt"
  }

  tags = {
    Name = "prod-facebook-srv"
  }
}

output "instance_public_ip" {
  value = aws_eip.prod-eip.public_ip
}
```

- Now all three provisioner types from §2 appear in one real resource: **`file`** copies the page over, **`remote-exec`** installs/starts httpd and moves the page into place, and **`local-exec`** runs right there too — writing a line to `localfile.txt` on the machine running Terraform, **not** on the EC2 instance at all. After this `apply`, `localfile.txt` sits locally next to the `.tf` files, proof that `local-exec` really does run outside the resource entirely.

### A genuinely new gotcha, only visible in the real code: `time_sleep`

- `resource "time_sleep" "wait_60sec"` comes from the separate `hashicorp/time` provider — it does nothing except **wait**.
- `depends_on = [aws_eip.prod-eip]` means: *after* the Elastic IP is assigned, pause before continuing. ⚠️ Note the resource is *named* `wait_60sec` but its `create_duration` is actually `"30s"` — a naming/value mismatch worth catching with your own eyes rather than trusting a resource's name to describe its current settings.
- **Why the wait is needed at all:** an EC2 instance can show as "created" and have its EIP assigned, while the instance's SSH daemon genuinely isn't ready to accept connections yet. Without this deliberate pause, the `remote-exec` provisioner can try to SSH in **too early** and fail — exactly the "less reliable, can fail if the connection fails" downside called out in §6's comparison table, happening in practice, not just in theory.
- **Easy memory trick:** `time_sleep` is Terraform explicitly admitting *"the SSH connection provisioners depend on isn't instant — give the instance a moment to actually be ready."* This specific problem is one reason `user_data` is preferred — it runs *inside* the instance, so it never has to wait for the instance to become reachable from the outside first.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Provisioner | Runs commands on a resource after creation (or before destroy) | `file`, `remote-exec`, `local-exec` |
| `file` provisioner | Copies a file from local machine to the resource | `index.html` → `/tmp/index.html` on the instance |
| `remote-exec` provisioner | Runs commands on the remote resource, over SSH/WinRM | Installing and starting httpd |
| `local-exec` provisioner | Runs a command on your own machine, not the resource | Writing the server's IP to a local file |
| `connection` block | Tells Terraform how to reach the resource | `type`, `user`, `private_key`, `host` |
| Provisioners vs User Data | External/post-creation vs internal/boot-time | User Data preferred for production bootstrapping |
| `time_sleep` (hashicorp/time) | Deliberately pauses before the next step | Waiting for SSH to actually be ready before `remote-exec` |
| All three provisioners on one resource | `file` + `remote-exec` + `local-exec` can all live in the same `resource` block | Today's hands-on build did exactly this |
| Provisioners' idempotency | Not fully idempotent — re-running can cause issues | Use sparingly, only when `user_data` isn't enough |
