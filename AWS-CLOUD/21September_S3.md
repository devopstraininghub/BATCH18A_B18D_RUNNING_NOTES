# Batch 18 — AWS Cloud Running Notes: 21 September 2026

**Topic: Amazon S3 (Simple Storage Service)**

Friends, today's topic — **S3**, one of the oldest and most-used AWS services. Unlike EBS/EFS (which act like disks), S3 stores **objects**, reachable over plain HTTP/HTTPS, with practically unlimited scale.

---

## 1. What is S3?

- **S3** = **S**imple **S**torage **S**ervice — an **object storage** service in AWS.
- Stores data as **objects** (not as a disk/filesystem).
- Highly durable — **11 nines** (99.999999999%) durability.
- Infinitely scalable.
- Accessible over HTTP/HTTPS.
- No server management required.

---

## 2. Basic terminology

- **Bucket** — the container that stores objects. Bucket names must be **globally unique** across all of AWS.
- **Object** — a file stored in S3 (its data + metadata + key).
- **Key** — the unique name of the object **inside** its bucket.
- **Region** — a bucket is created in one specific AWS Region.

---

## 3. S3 Versioning

- Versioning keeps **multiple versions** of the same object.
- Protects against accidental delete.
- Protects against accidental overwrite.
- Every new upload creates a new **Version ID**.
- States: **Enabled**, **Suspended**, or **Never enabled**.

---

## 4. Delete Marker

- When versioning is **enabled**, deleting an object doesn't actually erase it — it creates a **Delete Marker** instead.
- The object appears deleted.
- The old versions still exist underneath.
- You can restore the object by removing the delete marker.

**Easy memory trick:** with versioning on, "delete" just hides the object — it doesn't destroy the data.

---

## 5. S3 Lifecycle Policy

- Automatically **moves or deletes** objects based on time-based rules.

**Example:**
```
After 30 days  → move to Standard-IA
After 90 days  → move to Glacier
After 365 days → Delete
```
Used for cost optimization — see `3September_EFS.md` §8 for the same idea applied to EFS.

---

## 6. What is a static website?

- Contains only **HTML, CSS, JavaScript, images** — no backend processing, no database, no server-side logic.
- Examples: a portfolio site, a landing page, a company info page.

**How to host a static website in S3:**
1. Create an S3 bucket (bucket name = domain name is recommended).
2. Upload `index.html`, `error.html`, CSS/JS files.
3. Enable **Static Website Hosting** — set the index document and the error document.
4. Update the **Bucket Policy** to allow public read access.
5. Use the generated S3 website URL.
6. *(Optional)* Put CloudFront in front of it for HTTPS + CDN.

**Why S3 is good for this:** no server required, no EC2 cost, highly scalable, very low cost, high availability, easy deployment, integrates with CloudFront. Perfect for React/Angular apps, documentation sites, landing pages.

---

## 7. S3 storage classes

| Storage class | Best for | Notes |
|---|---|---|
| **Standard** | Frequently accessed, active data | High availability, low latency, higher cost |
| **Standard-IA** | Rarely accessed data | Lower storage cost, small retrieval fee |
| **One Zone-IA** | Secondary backups, re-creatable data | Single AZ only — cheaper, but less resilient |
| **Intelligent-Tiering** | Unpredictable access patterns | Auto-moves data between tiers; small monitoring fee |
| **Glacier Instant Retrieval** | Archived but occasionally needed data | Lower cost than Standard, retrieval is immediate |
| **Glacier Flexible Retrieval** | Long-term backups, rarely accessed archives | Very low cost, retrieval takes minutes to hours |
| **Glacier Deep Archive** | Legal/compliance, 7+ year retention | Lowest cost, retrieval takes hours |

**Simple decision guide:**
```
Frequent access      → Standard
Rare access          → Standard-IA
Single AZ + cheaper   → One Zone-IA
Unknown pattern       → Intelligent-Tiering
Archive + fast read   → Glacier Instant Retrieval
Archive + low cost    → Glacier Flexible Retrieval
Very long-term        → Glacier Deep Archive
```

**Easy memory trick:** Standard = active data. IA = less-frequently-used data. Glacier = archive data. Intelligent-Tiering = "let AWS figure it out for me."

---

## 8. S3 vs EBS vs EFS

| | S3 | EBS | EFS |
|---|---|---|---|
| Type | Object storage (HTTP-based) | Block storage (attached disk) | Shared file storage (NFS-based) |
| Attached to | Nothing — accessed over HTTP | One EC2 at a time | Many EC2 instances at once |

(Full EBS/EFS details: `2September_EBS.md`, `3September_EFS.md`.)

---

## 9. Real DevOps projects using S3

**Project 1 — static website + CI/CD:**
```
Developer pushes code → GitHub → CI/CD builds app
→ build output uploaded to S3 → CloudFront serves it globally
```
Steps: create the S3 bucket with static hosting enabled → create a CloudFront distribution with S3 as its origin → CI/CD (GitHub Actions/Jenkins) builds, uploads to S3, and invalidates the CloudFront cache. **Why S3:** no EC2 needed, auto-scaling, very low cost, highly available.

**Project 2 — log storage + monitoring:**
```
EC2/containers generate logs → pushed to S3 → queried with Athena → CloudWatch alerts on errors
```
**Why S3:** cheap long-term storage, lifecycle rules move old logs to Glacier automatically, durable.

**Project 3 — backup & disaster recovery:**
```
RDS snapshot / DB dump → stored in S3 → replicated to another Region
```
**Benefits:** cross-Region replication, versioning protects the backups themselves, lifecycle rules reduce cost over time.

**Project 4 — Terraform remote state storage:**
- Create an S3 bucket, enable versioning, enable encryption, use DynamoDB for state **locking**.
- **Benefit:** team collaboration on the same Terraform state, state-file safety, prevents corruption from two people applying at once.

**Project 5 — CI/CD artifact storage:**
```
Code build → artifact generated (JAR/WAR/Docker layers) → uploaded to S3 → deployment server downloads it
```
**Why:** central, secure storage, easy to integrate into any pipeline.

---

## 10. Why S3 is perfect for DevOps

- Highly scalable, cost-effective, zero infrastructure to manage.
- Integrates easily with EC2, Lambda, CloudFront, Athena, Glue, and CI/CD tools.
- Fully automatable via the CLI and SDKs (see `22September_CLI.md`).

**In DevOps, S3 commonly handles:** static website hosting, backup storage, log storage, Terraform state, an artifact repository, and data lake storage.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| S3 Bucket / Object / Key | Container / file / the file's unique name | Storing build artifacts under a predictable key path |
| Versioning | Keeps every version of an object | Protection against an accidental overwrite or delete |
| Delete Marker | "Delete" hides the object, doesn't erase it | Restoring an accidentally deleted file by removing the marker |
| Lifecycle Policy | Auto-moves/deletes objects over time | Old logs sliding into Glacier after 90 days |
| Static website hosting | Serve HTML/CSS/JS directly from a bucket | A React app deployed with zero EC2 involved |
| Storage classes | Standard → IA → Glacier tiers | Matching cost to how often data is actually accessed |
| Terraform remote state in S3 | Shared, locked state file for a team | Preventing two engineers from corrupting the same state |
