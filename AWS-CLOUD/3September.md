# Batch 18 — AWS Cloud Running Notes: 3 September 2026

**Topic: NFS & Amazon EFS (Elastic File System), EFS Lifecycle Policies, Mount Targets, A Few More Linux Commands**

Friends, yesterday we worked with EBS — storage attached to **one** server at a time. Today we look at **EFS**, storage that many servers can share **at the same time**, how it's different from EBS, and a few more everyday Linux file/folder commands.

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

## 4. How to configure EFS

**In the AWS Console:**
1. EFS dashboard → **"Create file system."**
2. Configure file system settings:
   - **Name** — a descriptive name.
   - **VPC** — which VPC this file system belongs to.
   - **Lifecycle management** — pick the storage classes/policy (section 8 below).
3. Optional settings — encryption, tags, performance mode.
4. **Network settings** — security groups and subnets (this is where mount targets get created — see section 9).
5. Review → **"Create file system."** Takes a few minutes to become available.

**On each EC2 instance — mounting EFS the recommended way:**
```
sudo yum install -y amazon-efs-utils
sudo mkdir efs
sudo mount -t efs -o tls fs-097d6a8288a8afd46:/ efs
```
- **`amazon-efs-utils`** — AWS's own EFS helper package; installing it first gives you the `efs` mount type and extra options (like `tls`) that a plain `mount` command doesn't have on its own.
- **`-t efs -o tls`** — mounts using the `efs` type with **TLS encryption in transit** enabled — the recommended, more secure way to mount, versus a bare NFS mount.
- `fs-097d6a8288a8afd46` is the EFS file system's ID.

A plain NFS mount also works, without the `efs-utils` package, if you have the file system's DNS name instead of its ID:
```
sudo mount -t nfs4 <efs-dns-name>:/ /mnt/efs
```

**Real-time example:** A team running the same web application on 3 EC2 instances behind a load balancer mounts the same EFS at `/mnt/uploads` on all three — a file uploaded by a user, no matter which server handled that request, is instantly visible to the other two as well.

**Easy memory trick:** EFS mount looks just like an EBS mount, except the "disk" (the EFS ID or DNS name) is shared across many servers, not owned by just one.

---

## 5. Key features of EFS

- Fully managed — no capacity planning needed.
- Auto-scaling storage.
- Multi-AZ availability.
- Highly durable.
- Shared file access across many EC2 instances at once.
- Pay only for the storage actually used.
- Uses the **NFS protocol**, so it's compatible with a wide range of applications/tools that already support NFS.
- Integrates with EC2, AWS Lambda, Amazon ECS, and more.

**Performance modes — two options when creating a file system:**
- **General Purpose** — suitable for a wide variety of workloads. The default, and what most use cases need.
- **Max I/O** — optimized for high-performance, latency-sensitive workloads, at the cost of slightly higher per-operation latency for typical use.

**Easy memory trick:** General Purpose → the right choice almost always. Max I/O → only for genuinely I/O-heavy workloads.

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

| Storage class | Used for | Approx. cost (US East, per GB-month) | Notes |
|---|---|---|---|
| **Standard** | Frequently accessed files | ~$0.30 | High performance, no retrieval charge |
| **Infrequent Access (IA)** | Not accessed for 30+ days (configurable) | ~$0.016 | Plus a small per-GB charge (~$0.01/GB) each time a file is actually read back |
| **Archive** | Rarely accessed data | ~$0.008 | Cheapest tier, but higher access latency + its own retrieval charge |

⚠️ These are approximate US East (N. Virginia) prices at the time of writing — AWS pricing changes over time and varies by Region, so always check the [official EFS pricing page](https://aws.amazon.com/efs/pricing/) or the AWS Pricing Calculator before quoting a number in a real cost estimate.

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

---

## Quick Recap Table

| Command / Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| NFS (port 2049) | Protocol for sharing files over a network | The technology underneath EFS |
| EFS | Managed, shared file storage — many EC2s at once | Shared uploads folder across web servers behind a load balancer |
| `mount -t efs -o tls fs-id:/ efs` | Mount an EFS file system, with TLS in transit | Making shared storage usable on a server, the recommended way |
| Performance mode (General Purpose / Max I/O) | Chosen when creating the file system | General Purpose for almost everything; Max I/O only for heavy, latency-sensitive I/O |
| EFS lifecycle policy | Auto-moves files between Standard/IA/Archive | Cutting storage cost on old, rarely-accessed files |
| Mount Target | EFS's access point inside one subnet/AZ | One per AZ, required for EC2 in that AZ to reach EFS |
| `touch` / `mkdir` | Create empty files / new folders | Basic setup before writing or organizing anything on a server |
| `ll` / `ls` / `cd` / `cd ..` | List contents / move between folders | Everyday navigation on any Linux server |
