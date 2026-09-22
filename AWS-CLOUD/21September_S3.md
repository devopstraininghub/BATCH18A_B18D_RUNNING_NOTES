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

- Automatically **moves or deletes** objects based on time-based rules — you set the rules once, and S3 keeps applying them forever with no manual work.
- S3 checks its lifecycle rules **once per day** — it evaluates every object that matches a rule's scope, and runs whatever action that rule specifies.
- Used for **cost optimization** — see `3September_EFS.md` §8 for the same idea applied to EFS.

**Simple example:**
```
After 30 days  → move to Standard-IA
After 90 days  → move to Glacier
After 365 days → Delete
```

### Creating a rule — what you actually configure

- **Rule name** — just a label to identify the rule.
- **Scope** — which objects the rule applies to: the whole bucket, or filtered by a prefix (e.g. `logs/`) and/or object tags.
- **Status** — the rule can be enabled or disabled without deleting it.
- **One or more actions** — see below; a single rule can combine several of these together.

### The lifecycle rule actions

A lifecycle rule's actions fall into these categories — it's worth knowing all of them individually, since each solves a different problem:

**1. Transition current version of objects between storage classes**
- Moves the **live, current** version of an object from one storage class to a cheaper one, after a set number of days.
- **Real-time example:** application logs move from Standard → Standard-IA after 30 days, then → Glacier after 90 days, since nobody reads a 3-month-old log unless there's an incident.

**2. Transition noncurrent versions of objects between storage classes**
- Only applies in a **versioning-enabled** bucket — moves **older, non-current** versions of an object (see §3, S3 Versioning) to a cheaper storage class.
- **Real-time example:** the current version of a config file stays in Standard for fast access, but every older version of it automatically drops to Glacier after 30 days, since old versions are only ever needed for rollback, not daily use.

**3. Expire current version of objects**
- Deletes the **current** version of an object once it reaches a certain age.
- In a **versioning-enabled** bucket, this doesn't actually erase the data — it just adds a **Delete Marker** (see §4) on top, so the object "disappears" from normal view but the old versions are still there underneath.
- **Real-time example:** temporary build artifacts that are only useful for 90 days after being produced.

**4. Permanently delete noncurrent versions of objects**
- Actually and permanently removes **old, noncurrent** versions of an object after a set number of days — this one genuinely deletes data, unlike action 3.
- **Real-time example:** keeping the last 30 days of every edit to a file for rollback purposes, then permanently clearing out anything older than that, so old versions don't quietly pile up storage cost forever.

**5. Delete expired object delete markers**
- In a versioning-enabled bucket, once every noncurrent version behind a Delete Marker has itself been cleaned up, that Delete Marker becomes pointless clutter — this action removes those leftover, "expired" delete markers automatically.
- **Real-time example:** housekeeping — keeps the bucket's version history tidy instead of accumulating orphaned delete markers with nothing left underneath them.

**6. Abort incomplete multipart uploads**
- A large file uploaded to S3 in multiple parts (a "multipart upload") that never finishes — because of a crashed script, a lost connection, etc. — leaves behind **partial data that still costs money**, even though it was never a complete, usable object.
- This action automatically cancels and cleans up any multipart upload that's been sitting incomplete for a set number of days.
- ⚠️ **Important:** normal object-expiration rules do **not** clean these up — an incomplete multipart upload needs this specific action.
- **Real-time example:** a CI/CD pipeline job that uploads a large build artifact and sometimes fails mid-upload — without this rule, those failed partial uploads would silently accumulate storage cost forever.

**Easy memory trick:**
```
Transition (current)     → move the live object to a cheaper class
Transition (noncurrent)  → move old versions to a cheaper class
Expire (current)         → "delete" the live object (adds a delete marker, if versioned)
Permanently delete (noncurrent) → actually erase old versions
Delete (expired markers) → clean up leftover, pointless delete markers
Abort (incomplete uploads) → stop paying for uploads that never finished
```

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

⚠️ **One thing true of every class below:** all of them give the same **11 nines (99.999999999%) durability** — durability means "will AWS ever lose this object," and that answer is the same everywhere. What actually changes between classes is **availability** (can you reach it right now), **retrieval speed**, **minimum storage duration**, and **cost**.

### S3 Standard

- Designed for **99.99% availability** — under ~52 minutes of downtime a year.
- Data is stored across **3 or more Availability Zones**.
- No minimum storage duration, no retrieval fee.
- Highest per-GB storage cost of the "hot" tiers, in exchange for the best availability and lowest latency.

**Real-time example:** a live application's assets, a website's images, or any file your application reads/writes constantly.

### S3 Standard-IA (Infrequent Access)

- Same 11-nines durability, but designed for **99.9% availability**, still across 3+ AZs.
- Storage cost is lower than Standard, but there's a **small per-GB retrieval fee** every time you read an object.
- **30-day minimum storage duration** — if you delete or transition an object before 30 days, you're still billed as if you'd kept it the full 30 days.

**Real-time example:** disaster-recovery copies, or backups you hope never to need, but must be able to read in full **immediately** if you ever do.

### S3 One Zone-IA

- Same low cost profile as Standard-IA, but roughly 20% cheaper again.
- Stored in **only one** Availability Zone — if that AZ is lost (a real, if rare, possibility), the data is lost with it.
- Same **30-day minimum storage duration** as Standard-IA.

**What "Best for: secondary / re-creatable data" actually means** — this class is only a safe choice when losing the object wouldn't actually be a disaster, which happens in two different situations:

- **"Secondary" data** — this copy is **not the only place the data exists**. The real, trusted copy lives somewhere else (in S3 Standard, on-premises, in another Region) — so if this One Zone-IA copy were lost, you'd still have the original to fall back on. You're just storing an extra copy here cheaply, not relying on it as your source of truth.
- **"Re-creatable" data** — this copy **can be regenerated** if it's lost, usually by re-running some process. Examples: a thumbnail image generated from an original photo, a video re-encoded into a different format, or a build artifact that can be rebuilt from source code. If it disappears, you shrug and regenerate it — you don't lose anything you can't get back.

**The rule of thumb:** never put your **only** copy of something genuinely important in One Zone-IA. Use it only when a copy being lost is an inconvenience, not a catastrophe.

**Real-time example:** a company keeps its production data in S3 Standard, and also drops a cheap secondary copy into One Zone-IA purely to save a bit of cost on top of an already-safe primary copy — never the other way around.

### S3 Intelligent-Tiering

- **Automatically moves objects between access tiers** based on actual usage — no lifecycle rules to write or maintain yourself.
- Built-in tiers: **Frequent Access** (default, new objects start here) → **Infrequent Access** (after 30 consecutive days with no access) → **Archive Instant Access** (after 90 days with no access) → optional **Archive Access** / **Deep Archive Access** tiers for data left untouched even longer.
- **No retrieval fees at all** on the Frequent/Infrequent/Archive Instant tiers — you're only ever charged for storage plus a small monitoring fee.
- Monitoring & automation fee: about **$0.0025 per 1,000 objects/month**.
- Objects smaller than **128 KB are never monitored or moved** — they always stay billed at Frequent Access rates, with no monitoring charge on them.
- If an object in a colder tier is accessed again, it moves straight back to Frequent Access automatically.

**Real-time example:** a shared team drive or a data lake where nobody can predict in advance how often any given file will actually get touched.

### S3 Glacier Instant Retrieval

- Same 11-nines durability, 99.9% availability, across 3+ AZs.
- Retrieval is **milliseconds** — the same speed as Standard, just at a much lower storage cost.
- **90-day minimum storage duration.**

**Real-time example:** medical imaging or news-archive photos — rarely opened, but must load instantly the moment someone does need one.

### S3 Glacier Flexible Retrieval

- Very low storage cost.
- **90-day minimum storage duration.**
- Three retrieval speed options, each a cost/time trade-off:
  - **Expedited** — typically 1–5 minutes.
  - **Standard** — typically 3–5 hours.
  - **Bulk** — typically 5–12 hours, and free.

**Real-time example:** long-term backups you occasionally need to restore, but where waiting a few hours is genuinely fine.

### S3 Glacier Deep Archive

- **Lowest storage cost** of any S3 class.
- **180-day minimum storage duration** — the longest of any class.
- Two retrieval options: **Standard** (~12 hours) or **Bulk** (~48 hours).
- Built for data you're required to keep for **7+ years**, and essentially never expect to open.

**Real-time example:** regulatory or audit records kept purely for legal/compliance reasons.

### ⚠️ The minimum-storage-duration trap

For any class with a minimum storage duration (Standard-IA/One Zone-IA: 30 days, Glacier Instant/Flexible: 90 days, Deep Archive: 180 days) — deleting or transitioning an object **before** that period ends still bills you for the **entire** minimum period, as if you'd kept it the whole time. A lifecycle policy that moves objects to a colder tier too aggressively (e.g. after just a few days) can end up costing **more**, not less, because of this.

### Quick reference table

| Storage class | Best for | Availability | Min. storage duration | Retrieval |
|---|---|---|---|---|
| Standard | Frequently accessed, active data | 99.99% | None | Instant, no fee |
| Standard-IA | Rarely accessed data | 99.9% | 30 days | Instant, small fee |
| One Zone-IA | Secondary/re-creatable data | Single AZ | 30 days | Instant, small fee |
| Intelligent-Tiering | Unpredictable access patterns | Matches underlying tier | None | Instant, no fee |
| Glacier Instant Retrieval | Archived but occasionally needed | 99.9% | 90 days | Milliseconds |
| Glacier Flexible Retrieval | Long-term backups | Multi-AZ | 90 days | Minutes to ~12 hours |
| Glacier Deep Archive | 7+ year legal/compliance retention | Multi-AZ | 180 days | ~12–48 hours |

**Simple decision guide:**
```
Frequent access       → Standard
Rare access           → Standard-IA
Single AZ + cheaper    → One Zone-IA
Unknown pattern        → Intelligent-Tiering
Archive + fast read    → Glacier Instant Retrieval
Archive + low cost     → Glacier Flexible Retrieval
Very long-term         → Glacier Deep Archive
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
