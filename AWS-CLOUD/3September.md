# Batch 18 — AWS Cloud Running Notes: 3 September 2026

**Topic: NFS & Amazon EFS (Elastic File System), EFS Lifecycle Policies, Mount Targets, A Few More Linux Commands (`yum`, `systemctl`, `vim`), Custom AMIs**

Friends, yesterday we worked with EBS — storage attached to **one** server at a time. Today we look at **EFS**, storage that many servers can share **at the same time**, how it's different from EBS, a few more everyday Linux commands (installing packages, managing services, using `vim`), and finally **Custom AMIs** — the "save a server as a template" trick that makes launching new, pre-configured servers fast and consistent.

---

## 1. What is NFS?

- **NFS** = **N**etwork **F**ile **S**ystem.
- A protocol used to **share files over a network** — allows multiple machines to access the same storage.
- Works like a shared folder, but across separate servers.
- Uses **port 2049**.

**Simple meaning:** NFS is the underlying technology that lets servers share files over the network.

---

## 2. What is EFS (Elastic File System)?

- **Amazon EFS** is a fully managed, scalable **file storage** service in AWS.
- It's **shared** file storage — multiple EC2 instances can access it **at the same time**.
- Works using the **NFS protocol** under the hood.
- **Automatically scales** its storage size — you don't pick a fixed size upfront.

**Simple meaning:** EFS = a shared network drive for many servers = AWS-managed NFS storage.

- **NFS** → the protocol/technology (port 2049).
- **EFS** → the AWS service that uses NFS to actually deliver this as a managed service.

---

## 3. Where is EFS used?

- Shared application data.
- Web servers that all need access to the same files.
- Container workloads (ECS, EKS).
- Content management systems.
- Analytics workloads.

---

## 4. How to configure EFS — simple steps

1. **Create EFS** — choose a VPC, select Availability Zones.
2. **Create Mount Targets** — one mount target per AZ, attach security groups.
3. **Configure Security Group** — allow NFS port `2049`, allow traffic from your EC2 instances.
4. **Launch EC2** in the same VPC.
5. **Mount EFS on EC2:**
   ```
   sudo mount -t nfs4 <efs-dns-name>:/ /mnt/efs
   ```
6. **Use it like a normal directory** — files written here are shared across every EC2 instance that has it mounted.

**Real-time example:** A team running the same web application on 3 EC2 instances behind a load balancer mounts the same EFS at `/mnt/uploads` on all three — a file uploaded by a user, no matter which server handled that request, is instantly visible to the other two as well.

**Easy memory trick:** EFS mount looks just like an EBS mount, except the "disk" (`<efs-dns-name>:/`) is shared across many servers, not owned by just one.

---

## 5. Key features of EFS

- Fully managed — no capacity planning needed.
- Auto-scaling storage.
- Multi-AZ availability.
- Highly durable.
- Shared file access across many EC2 instances at once.
- Pay only for the storage actually used.

---

## 6. EFS vs EBS

| | EBS (Elastic Block Store) | EFS (Elastic File System) |
|---|---|---|
| Storage type | Block-level storage | File-level storage |
| Attached to | **One** EC2 at a time | **Many** EC2 instances at once |
| Feels like | A hard disk | A shared network folder |
| Sizing | Choose size manually | Scales automatically |
| Typical use | OS / database storage | Shared application data |

**Simple comparison:**
- EBS → single server's disk. EFS → shared storage for many servers.
- EBS → fixed size. EFS → automatically grows.
- EBS → one instance at a time. EFS → many instances simultaneously.

---

## 7. When to use which?

**Use EBS when:**
- You need storage for one EC2.
- You need high IOPS for a database.
- You need a boot volume.

**Use EFS when:**
- Multiple EC2 instances need shared files.
- Applications need common storage.
- Containers need persistent shared storage.

**Easy memory trick:** EBS = block storage attached to a single EC2. EFS = managed, shared file storage for many EC2s at once.

---

## 8. EFS lifecycle policies — storage classes

EFS can automatically move files between storage classes to save cost, based on how often each file is actually accessed.

| Storage class | Used for | Cost | Notes |
|---|---|---|---|
| **Standard** | Frequently accessed files | Higher | High performance |
| **Infrequent Access (IA)** | Not accessed for 30+ days (configurable) | Lower | Small charge each time it's accessed |
| **Archive** | Rarely accessed data | Very low | Higher access latency |

**How it works — example:**
- File not accessed for 30 days → automatically moves to **IA**.
- File not accessed for 90 days → moves to **Archive**.
- If the file is accessed again → it automatically moves back to **Standard**.

**Real-time example:** Old uploaded documents on a content platform that nobody's opened in months automatically slide into cheaper storage classes, without anyone having to manually go find and move them — and if someone does open one again, it just moves back, no manual intervention either way.

⚠️ **Common mix-up:** these storage classes are **not** S3 storage classes, and files aren't secretly sitting inside an S3 bucket. "Standard," "Infrequent Access," and "Archive" are **EFS's own internal tiers** — files stay inside the same EFS file system the whole time, EFS just quietly moves them between its own tiers based on access. S3 has its own, separate set of storage classes (S3 Standard, S3 Glacier, etc.) that work the same *idea* but on entirely different storage. The similar naming is just AWS being consistent about the concept — it's not shared underlying storage.

**Easy memory trick:** Same idea, different service — EFS's tiers stay inside EFS; they don't hand your files off to S3.

---

## 9. Mount targets in EFS

- A **Mount Target** is a network endpoint inside a **subnet** that lets EC2 instances connect to EFS.
- It provides an IP address, in your subnet, for accessing EFS.

**Why we need them:**
- EFS is a **regional** service (spans multiple AZs).
- EC2 instances connect to EFS **through** mount targets.
- Each Availability Zone needs its **own** mount target, for high availability.

**Important rule:** one Mount Target per Availability Zone. Example: a VPC with `AZ-a`, `AZ-b`, `AZ-c` needs **3** mount targets, one in each.

**How it works:**
```
EC2 Instance → Mount Target (same AZ) → EFS File System
```

**Configuration steps:**
1. Create EFS.
2. Select VPC.
3. Choose subnets — one per AZ.
4. Attach a security group — allow NFS port `2049`.
5. EC2 mounts EFS using its DNS name.

**Security requirement:** the Security Group must allow port `2049` (NFS), with the source set to your EC2 instances' Security Group.

**Easy memory trick:** Mount Target → EFS's "front door" in each AZ. No mount target in an AZ, no EC2 in that AZ can reach EFS.

---

## 10. A few more Linux commands

- **`touch fname1 fname2`** — creates one or more empty files.
- **`mkdir dir1 dir2 dir3`** — creates one or more folders.
- **`ll`** / **`ls`** — list the contents of the current folder (`ll` = long format, with permissions/owner/size).
- **`cd dir1`** — moves into `dir1`.
- **`cd ..`** — moves up one level, to the parent folder.
- **`yum install pkg-name`** — installs a package using the `yum` package manager (RHEL/Amazon Linux).
- **`systemctl start/stop/status/restart service.name`** — controls a background service: `start` it, `stop` it, check its `status`, or `restart` it after a config change.
- **`systemctl enable service.name`** — makes the service start automatically on every future reboot (separate from `start`, which only starts it *right now*).
- **`vim fname`** — opens (or creates) a file in the `vim` editor. Press `i` to enter **Insert mode** and start typing; press `Esc` then type `:wq!` to save and force-quit.
- **`cat fname`** — prints a file's contents to the screen.

**Real-time example — installing and running a web server:**
```
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
```
`yum install` gets Apache (`httpd`) onto the server, `systemctl start` runs it right now, and `systemctl enable` makes sure it comes back up automatically if the server ever reboots — this exact three-line sequence is the standard way any Linux service gets installed and kept running in production.

**Easy memory trick:** `systemctl start` → "run it now." `systemctl enable` → "and keep running it, forever, even after a reboot."

---

## 11. Custom AMI (Amazon Machine Image)

- **AMI** = **A**mazon **M**achine **I**mage — a pre-configured template used to launch an EC2 instance.
- An AMI contains: the operating system, pre-installed software, settings/configurations, and an EBS snapshot of the root volume.
- Launching an EC2 instance = using an AMI as the blueprint.

**What an AMI is made of:**
- **Root volume** — contains the operating system, application server, and application software.
- **Block device mapping** — defines which EBS volumes get attached to the instance when it launches from this AMI.

**Types of AMIs — two ways they're commonly grouped:**

By **source**:
- **AWS-provided AMIs** — Amazon Linux, Ubuntu, Windows, RedHat.
- **Marketplace AMIs** — provided by third-party vendors (Nginx, Jenkins, Fortinet, etc.).
- **Custom AMIs** — your own configuration and setup, saved by you.

By **visibility**:
- **Public AMIs** — created by AWS or the AWS community, available for anyone to use. Common for standard operating systems/applications.
- **Private AMIs** — created and managed by an individual AWS account, restricted to that account (unless deliberately shared).

⚠️ **Security consideration:** be cautious using public AMIs from unknown sources — they may not follow good security practices. Whichever AMI you use, keep it regularly updated and patched.

**Why create a Custom AMI?**
- **Faster launch times** — install Java, Tomcat, Python, and your app code once, take a snapshot to create an AMI, and every future EC2 launched from it is ready in seconds.
- **Standardization** — every server launched from the same AMI has identical OS, packages, and versions.
- **Disaster recovery** — if an instance crashes, launch a fresh replacement straight from the AMI.
- **Auto Scaling Groups** — ASGs need a custom AMI to rapidly create new, identical instances during a traffic spike.
- **Pre-configured security hardening** — OS patches, firewall rules, and required packages are already baked in.
- **Golden Image pattern** — companies maintain one official, secure, prebuilt "Golden AMI" that every new server gets launched from — an industry-standard practice.

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

### Hands-on walkthrough — build a Custom AMI end to end

This is the exact flow practiced in class, tying everything together:

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
   Write a small sample page inside `index.html`, save with `:wq`, then open the instance's **public IP** in a browser (`http://<public-ip>`) to confirm the page loads — port 80 is the default for plain HTTP, so no `:port` needed in the URL.
3. **Create an AMI from this now-configured instance:** EC2 dashboard → "Instances" → select it → "Actions" → "Image and templates" → "Create Image" → give it a clear name/description → "Create Image." AMIs can be created from an instance whether it's **running or stopped**.
4. **Launch a brand-new instance from that AMI:** "Launch Instance" → "My AMIs" tab → pick the one just created → choose instance type, security group, key pair as usual → Launch.
5. **Verify:** connect to this new instance and confirm `httpd` and your `index.html` are already there, untouched — everything from the original server came along automatically, because it was baked into the AMI.

**Real-time example:** This is precisely how a company builds its "Golden AMI" for a web tier — configure one server exactly right, freeze it as an AMI, and every future server (manually launched, or by an Auto Scaling Group during a traffic spike) starts up already fully configured, in seconds, with zero manual setup repeated.

---

## 12. AWS Launch Template

- A **Launch Template** is a saved set of instance-launch parameters — AMI, instance type, key pair, security groups, and more — bundled together under one name.
- Instead of re-entering all these settings by hand every time, you create the template once and just **reference it** whenever you need to launch a matching instance.

**Key features:**
- **Versioning** — create and manage multiple versions of the same template as your standard configuration evolves.
- Specifies full instance details: AMI, instance type, key pair, block device mappings, network interfaces, and more.

**Use cases:**
- **Standardization** — every instance launched from the template has the same configuration.
- **Easy maintenance** — update settings in one place (the template) instead of every individual launch.
- **Scalability** — Launch Templates are what **EC2 Auto Scaling** and **EC2 Fleet** use to rapidly create new instances on demand.

**Real-time example:** A team defines a Launch Template pointing at their Golden AMI, `t2.micro`, and the correct security group — their Auto Scaling Group references that template, so whenever traffic spikes and new instances are needed, they come up with the exact right configuration automatically, no one manually re-picking settings under pressure.

**Easy memory trick:** AMI → what to launch (the server image). Launch Template → how to launch it (all the settings bundled together).

---

## Quick Recap Table

| Command / Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| NFS (port 2049) | Protocol for sharing files over a network | The technology underneath EFS |
| EFS | Managed, shared file storage — many EC2s at once | Shared uploads folder across web servers behind a load balancer |
| `mount -t nfs4 <dns>:/ /mnt/efs` | Mount an EFS file system on an EC2 instance | Making shared storage usable on a server |
| EFS lifecycle policy | Auto-moves files between Standard/IA/Archive | Cutting storage cost on old, rarely-accessed files |
| Mount Target | EFS's access point inside one subnet/AZ | One per AZ, required for EC2 in that AZ to reach EFS |
| `yum install pkg -y` | Install a package | Installing `httpd`, `java`, `git`, etc. |
| `systemctl start/enable service` | Run a service now / keep it running after reboot | Standing up and persisting a web server like `httpd` |
| `vim fname` | Edit a file interactively | Hand-editing a config file on a server |
| AMI (Amazon Machine Image) | A reusable template for launching EC2s | Auto Scaling Groups launching identical new servers instantly |
| Custom / Golden AMI | Your own pre-configured, saved server image | Standardized, fast, production-ready deployments company-wide |
| Launch Template | A saved bundle of launch settings (AMI, type, keys, SG) | What an Auto Scaling Group references to launch new instances |
