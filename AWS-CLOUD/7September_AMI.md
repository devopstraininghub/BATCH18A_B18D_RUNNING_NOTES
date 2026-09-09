# Batch 18 — AWS Cloud Running Notes: 7 September 2026

**Topic: Custom AMIs (Amazon Machine Image), AWS Launch Templates**

Friends, today is a deep dive on two closely related building blocks for automation: **Custom AMIs** — a frozen, ready-to-launch copy of a fully set-up server — and **Launch Templates** — a saved bundle of everything needed to launch matching EC2 instances. Together, these two (plus Auto Scaling Groups, which we'll get to soon) are what let a real DevOps team launch new servers automatically instead of configuring each one by hand.

---

## 1. What is an AMI?

- **AMI** = **A**mazon **M**achine **I**mage — a pre-configured template used to launch an EC2 instance.
- An AMI contains:
  - The operating system (Linux/Windows).
  - Pre-installed software.
  - Settings and configurations.
  - An EBS snapshot of the root volume.
- Launching an EC2 instance = using an AMI as the blueprint.

**What an AMI is made of:**
- **Root volume** — contains the operating system, application server, and application software.
- **Block device mapping** — defines which EBS volumes get attached to the instance when it launches from this AMI.

---

## 2. Types of AMIs

By **source**:
- **AWS-provided AMIs** — Amazon Linux, Ubuntu, Windows, RedHat.
- **Marketplace AMIs** — provided by third-party vendors (Nginx, Jenkins, Fortinet, etc.).
- **Custom AMIs** — your own configuration and setup, created by you.

By **visibility**:
- **Public AMIs** — created by AWS or the AWS community, available for anyone to use.
- **Private AMIs** — created and managed by an individual AWS account, restricted to that account (unless deliberately shared).

⚠️ **Security consideration:** be cautious using public AMIs from unknown sources — they may not follow good security practices. Whichever AMI you use, keep it regularly updated and patched.

---

## 3. Why create a Custom AMI?

- **Faster launch times** — install Java, Tomcat, Python, and your app code once, take a snapshot to create an AMI, and every future EC2 launched from it is ready in seconds.
- **Standardization** — every server launched from the same AMI has the same OS, packages, and versions.
- **Disaster recovery** — if an instance crashes, launch a fresh replacement straight from the AMI.
- **Auto Scaling Groups** — ASGs require a custom AMI to rapidly create new, identical instances during a traffic spike.
- **Pre-configured security hardening** — OS patches, firewall rules, and required packages are already baked in.
- **Golden Image pattern (industry standard)** — companies maintain one official, secure, prebuilt "Golden AMI" that every new server gets launched from.

**Real DevOps use cases:**
- Auto Scaling launch templates.
- Preinstalled Jenkins/Java/Nginx/httpd on EC2.
- Baking application code into the AMI (using a tool like Packer).
- Creating golden images for production.
- Backup of critical servers.

**AMI lifecycle — what you can do with one:**
- **Copy across Regions** — launch identical instances in a different geographic location.
- **Version it** — track changes and updates over time.
- **Share it** — with other AWS accounts, either publicly or privately.

**Interview one-liner:** An AMI is a machine template used to launch EC2 instances. Custom AMIs let you pre-install software, apply configurations, and create standardized, fast, production-ready server deployments.

**Easy memory trick:** AMI → a frozen, ready-to-launch copy of a fully set-up server.

---

## 4. Hands-on walkthrough — build a Custom AMI end to end

1. **Launch an EC2 instance** (Console: EC2 dashboard → "Launch Instance" → pick an Amazon Linux/Ubuntu AMI → `t2.micro` → select a key pair → in the Security Group, allow **HTTP, port 80** since a web server is coming → Launch).
2. **Install and configure a web server on it:**
   ```
   sudo yum update -y
   sudo yum install httpd -y
   sudo systemctl start httpd
   sudo systemctl status httpd
   sudo systemctl enable httpd
   cd /var/www/html
   sudo vim index.html
   ```
   Write a small sample page inside `index.html`, save with `:wq`, then open the instance's **public IP** in a browser (`http://<public-ip>`) to confirm the page loads.
3. **Create an AMI from this now-configured instance:** EC2 dashboard → "Instances" → select it → "Actions" → "Image and templates" → "Create Image" → give it a clear name/description → "Create Image." AMIs can be created from an instance whether it's **running or stopped**.
4. **Launch a brand-new instance from that AMI:** "Launch Instance" → "My AMIs" tab → pick the one just created → choose instance type, security group, key pair as usual → Launch.
5. **Verify:** connect to this new instance and confirm `httpd` and your `index.html` are already there, untouched — everything from the original server came along automatically, because it was baked into the AMI.

**Real-time example:** This is exactly how a company builds its "Golden AMI" for a web tier — configure one server exactly right, freeze it as an AMI, and every future server (manually launched, or by an Auto Scaling Group during a traffic spike) starts up already fully configured, in seconds, with zero manual setup repeated.

---

## 5. AWS Launch Template

- A **Launch Template** is a reusable configuration that defines **how** an EC2 instance should be launched.
- Instead of manually selecting the AMI, instance type, security groups, key pair, storage, User Data script, and networking settings every single time, you store all of it in a template and just reuse it.

**Why Launch Templates are needed** — they solve the problem of launching large numbers of EC2 instances **consistently**:
- **Standardization** — every instance launched uses identical settings.
- **Reusability** — the same template can be used for a plain EC2 launch **or** an Auto Scaling Group.
- **Versioning** — you can store multiple versions of the same template. Example: `v1` → Java 8, `v2` → Java 11, `v3` → Java 17.
- **Automation-ready** — used in CI/CD pipelines, and required by Auto Scaling Groups.
- **Faster launching** — everything is pre-configured, which reduces human error.

**What you can store in a Launch Template:**
- AMI ID.
- Instance type.
- Key pair.
- Security groups.
- EBS volumes.
- IAM roles.
- User Data script.
- Networking (subnets, network interfaces).
- Tags.
- Shutdown behavior.
- Monitoring settings.

**How they're used in real DevOps projects:**
- Auto Scaling Groups (mandatory — an ASG needs a Launch Template).
- Rolling deployments.
- Blue/Green deployments.
- Launching identical EC2 instances.
- Spot fleets using the same configuration.
- Jenkins pipelines launching EC2 dynamically.
- Terraform provisioning EC2 using templates.

**Interview one-liner:** A Launch Template is a reusable configuration for launching EC2 instances. It stores the AMI, instance type, networking, storage, and User Data, and is mainly used for Auto Scaling, Spot Fleets, and consistent server deployments.

**Easy memory trick:** AMI → **what** to launch (the server image). Launch Template → **how** to launch it (every setting, bundled together, versioned).

---

## Quick Recap Table

| Command / Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| AMI (Amazon Machine Image) | A reusable, frozen template for launching EC2s | Auto Scaling Groups launching identical new servers instantly |
| Public vs Private AMI | Who can use it — anyone, or just your account | Being cautious about unverified public AMIs |
| Custom / Golden AMI | Your own pre-configured, saved server image | Standardized, fast, production-ready deployments company-wide |
| AMI lifecycle (copy/version/share) | Move, track, and share AMIs | Launching the same server image in a different Region |
| Launch Template | A saved, versioned bundle of launch settings | What an Auto Scaling Group references to launch new instances |
| Launch Template versioning | Multiple saved versions of the same template | `v1` Java 8 → `v3` Java 17, without losing the older versions |
