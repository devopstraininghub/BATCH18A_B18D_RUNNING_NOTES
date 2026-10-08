# Batch 18 — AWS Cloud Running Notes: 8 October 2026

**Topic: Quiz 2 — Questions & Answer Key (VPC, S3, IAM, EC2)**

Friends, this is the full quiz, with the correct answer marked ✅, for **Quiz 2** — covering VPC fundamentals through S3, IAM, and EC2 CLI basics, i.e. `9September_VPC.md`, `21September_S3.md`, `18September_IAM.md`, `23September_IAMRole.md`, and `22September_CLI.md`. Each question is followed by the reasoning behind the correct answer — and, where a wrong option is a *common* trap rather than just obviously wrong, why that one's wrong too.

---

### Q1. Which of the following statements accurately describes the purpose and function of a NAT Gateway in an AWS VPC?

- A) NAT Gateway allows inbound traffic from the internet to reach private instances in a VPC.
- B) ✅ **NAT Gateway translates private IP addresses of instances in a private subnet to public IP addresses for outbound internet access.**
- C) NAT Gateway is used for direct communication between instances in different VPCs.
- D) NAT Gateway provides a direct and public-facing IP address to instances in a public subnet.

**Why:** NAT Gateway is **outbound-only** — it does **not** let the Internet initiate connections *into* private instances (that would need a public IP or a Bastion/ALB, ruling out A). It also has nothing to do with cross-VPC communication (that's VPC Peering, ruling out C) or handing out public IPs directly (that's an EIP on a public-subnet instance, ruling out D).
**Easy memory trick:** NAT = "private instance wants to go OUT, not be reached FROM outside." See `11September_NATGateway.md`.

---

### Q2. What is the maximum size of an object in an S3 bucket?

- A) 10 million
- B) Unlimited
- C) ✅ **5 TB**
- D) 1 B

**Why:** AWS caps a single S3 object at **5 TB**. A single `PutObject` call itself tops out at 5 GB — anything bigger (up to the 5 TB ceiling) must go through a **multipart upload**. Don't confuse this with Q16 below — that one asks about the **bucket's** size limit, which is a completely different number (and a completely different answer).

---

### Q3. Which storage classes are available in Amazon S3 for storing objects with low-latency access?

- A) ✅ **STANDARD**
- B) INTELLIGENT_TIERING
- C) GLACIER
- D) ONEZONE_IA

**Why:** millisecond first-byte latency is a property of the *default access tier* — **STANDARD**, **INTELLIGENT_TIERING**, and **ONEZONE_IA** are all actually designed for immediate, low-latency retrieval. **GLACIER** is the one that does **NOT** qualify — it trades latency for cost, with retrieval taking **minutes to hours**, not milliseconds, by design (that's the whole point of archival storage). If the form only accepts one answer, **STANDARD** is the safest single pick — it's the class built specifically around low-latency access with no caveats attached. Full spec table is in `21September_S3.md`'s storage-classes section.

---

### Q4. You have uploaded a file to S3. What HTTP code would indicate that the upload was successful?

- A) HTTP 404
- B) HTTP 501
- C) HTTP 307
- D) ✅ **HTTP 200**

**Why:** `404` = not found, `501` = not implemented, `307` = temporary redirect — none of those mean "your PUT succeeded." `200 = OK` is the universal "it worked" code across almost every HTTP-based AWS API, not just S3.

---

### Q5. Which port number is commonly used for the Hypertext Transfer Protocol (HTTP) and Hypertext Transfer Protocol Secure (HTTPS)?

- A) 80 & 22
- B) 443 & 80
- C) ✅ **80 & 443**
- D) 443 & 22

**Why:** HTTP = port **80**, HTTPS = port **443**. Options A and D both swap in port 22, which is SSH, not a web protocol at all. Same fact as `29September_ACM.md` §3 — worth having cold, since it comes up constantly (ALB listeners, Security Group rules, CloudFront viewer protocol).

---

### Q6. You want to explicitly "deny" certain traffic to the instance running in your VPC. How do you achieve this?

- A) Using a security group
- B) Adding an entry in the route table
- C) By putting the instance in a private subnet
- D) ✅ **Using a Network ACL**

**Why:** Security Groups are **allow-only** — there's no "deny" rule in a Security Group, you can only choose what to allow (anything not explicitly allowed is implicitly denied, but you can't write an explicit DENY statement, ruling out A). **NACLs**, on the other hand, support both **explicit ALLOW and explicit DENY** rules, evaluated in numbered order. Putting the instance in a private subnet or editing the route table (B, C) doesn't "deny traffic" in this sense at all — those control *reachability*, not *inspection-and-decision* on specific traffic. See `11September_NACL.md`.

---

### Q7. What is the range of CIDR blocks that can be used inside a VPC?

- A) Between /18 to /24
- B) Between /18 to /28
- C) ✅ **Between /16 to /28**
- D) Between /00 to /24

**Why:** `/16` = the largest VPC you're allowed (65,536 IPs), `/28` = the smallest (16 IPs, AWS reserves 5 of those per subnet, so effectively 11 usable). Covered with worked examples in `9September_VPC.md`.

---

### Q8. Which AWS service is used to store and retrieve objects, such as images, videos, and documents?

- A) ec2
- B) ✅ **s3**
- C) elb
- D) none

**Why:** EC2 = compute, ELB = traffic distribution — neither is a storage service. S3 is purpose-built **object storage**.

---

### Q9. What is the difference between a user and a role in IAM?

- A) ✅ **A user is a person who uses a system, while a role is a collection of permissions that can be granted to a user.**
- B) A user is a temporary identity that is used to access a system, while a role is a permanent identity that is assigned to a user.
- C) A user is a person who is authorized to access a system, while a role is a way of granting that authorization.
- D) All of the above

**Why:** Option A is the simplified textbook phrasing — but it's worth knowing the **more precise version** we actually use in this course (`23September_IAMRole.md` §1):
- **IAM User** = a **permanent** identity (a person or an app) with its own long-term credentials.
- **IAM Role** = a **temporary** identity, assumed only when needed, with **no permanent credentials** of its own.

⚠️ **Watch option B — it has this completely backwards.** It says a *user* is temporary and a *role* is permanent, which inverts the single most important fact about Users vs Roles. That's exactly why **D ("All of the above") is wrong** too — "all of the above" can't be correct when one of "the above" directly contradicts the real fact.

---

### Q10. Which of the following is used to control access to AWS resources?

- A) IAM users
- B) IAM roles
- C) ✅ **IAM policies**
- D) IAM groups

**Why:** Users, Roles, and Groups (A, B, D) are all **identities** (or containers of identities) — they're *who* is asking. The **Policy** is the actual document that says *what* they're allowed to do. Policies are what you attach to a User, Role, or Group to grant permissions in the first place.

---

### Q11. What are the different types of storage classes in S3?

- A) ✅ **Standard, Standard-IA, One Zone-IA, and Glacier**
- B) Instance, Block, and Object
- C) General Purpose, Compute Optimized, and Memory Optimized
- D) Other:

**Why:** The other options are real AWS categories — just from the **wrong service**. "Instance, Block, Object" (B) describes storage *types* generally (EBS = block, S3 = object) — not S3-specific storage classes. "General Purpose, Compute Optimized, Memory Optimized" (C) describes **EC2 instance type families**, not S3 at all.

---

### Q12. What is the purpose of versioning in S3?

- A) ✅ **To enable access to previous versions of objects, even after they have been overwritten**
- B) To protect objects from accidental deletion
- C) To encrypt objects at rest
- D) To replicate objects across multiple Availability Zones

**Why:** It's a nice side effect that versioning also helps *protect against* accidental deletion/overwrite (B) — a delete just adds a delete marker, the old version is still there — but the *purpose* is keeping every version accessible, not encryption (C, that's SSE) or cross-AZ replication (D, that's Cross-Region Replication) — two entirely different S3 features.

---

### Q13. What is the purpose of a static website hosting configuration in an S3 bucket?

- A) ✅ **To store website files and serve them directly from the S3 bucket**
- B) To host a database instance for a web application
- C) To provide a load balancing service for web traffic
- D) To enable access to S3 objects through a secure HTTPS connection

**Why:** S3 is not a database engine (B) and not a load balancer (C) — static website hosting literally means "this bucket can respond to HTTP requests for `index.html` and friends, directly." (D is also a distractor — static website hosting's own endpoint is actually HTTP-only, not HTTPS; HTTPS on a custom domain needs CloudFront + ACM in front of it, per `29September_ACM.md`/`30September_CloudFront.md`.)

---

### Q14. Which of the following options allows you to control access to S3 buckets and objects using AWS Identity and Access Management (IAM) policies?

- A) ✅ **Bucket Policies**
- B) Access Control Lists (ACLs)
- C) Both A and B
- D) Neither A nor B

**Why:** This is a sharper distinction than it looks. **Bucket Policies** are written in the exact same JSON policy language as IAM policies (`Effect`/`Principal`/`Action`/`Resource`). **ACLs** are a separate, older, XML-based permission system that predates IAM policies entirely and uses a totally different syntax. So while both ACLs and Bucket Policies *can* control S3 access in general, only **Bucket Policies** satisfy the question's specific wording — "using AWS IAM policies" — which rules out C and D. AWS's own current guidance, for what it's worth, recommends Bucket Policies (or IAM policies) over ACLs for new buckets — ACLs are considered close to legacy at this point.

---

### Q15. What AWS service can be used to automate the process of moving objects between different storage classes in S3?

- A) AWS S3 Transfer Acceleration
- B) AWS S3 Select
- C) ✅ **AWS S3 Lifecycle**
- D) AWS S3 Transfer Manager

**Why:** Transfer Acceleration (A) speeds up *uploads* over long distances, S3 Select (B) lets you query *inside* an object without downloading the whole thing — neither moves objects between storage tiers. "S3 Transfer Manager" (D) isn't a real AWS feature name. Lifecycle rules are exactly the mechanism covered in `21September_S3.md`'s lifecycle section (all 6 action types).

---

### Q16. What is the maximum size of an S3 bucket?

- A) 5 GB
- B) 5 TB
- C) none
- D) ✅ **Unlimited**

**Why:** Don't confuse this with Q2 — that one's about a single **object** (capped at 5 TB, option B here). The **bucket itself** has no overall size or object-count limit — you can keep adding objects indefinitely.

---

### Q17. What AWS CLI command is used to delete an S3 bucket?

- A) `aws s3 delete-bucket bucket_name`
- B) `aws s3 rm-bucket bucket_name`
- C) `aws s3 remove-bucket bucket_name`
- D) ✅ **`aws s3 rb bucket_name`**

**Why:** There's no `delete-bucket`, `rm-bucket`, or `remove-bucket` subcommand in the high-level `aws s3` CLI (A, B, C don't exist) — `rb` ("remove bucket") is the real one, mirroring `mb` ("make bucket") used for creation (see Q25). ⚠️ Note the bucket must be **empty** first, or you need `--force` to also delete everything inside it.

---

### Q18. How can you grant public read access to all objects in an S3 bucket using a bucket policy?

- A) ✅ **Set the Effect to Allow and Principal to `*` for the specified actions.**
- B) Add a condition to the policy allowing access from any IP address.
- C) Use the `aws s3 cp` command to set public read permissions on each object.
- D) Configure the bucket ACL to grant public access.

**Why:** `Principal: "*"` means "anyone, unauthenticated" — combined with `Effect: Allow` and an action like `s3:GetObject`, that's the standard public-read bucket policy pattern. B confuses "any IP" with "any principal" — a policy could restrict by source IP and still not be public, or vice versa, so that's not the mechanism. C isn't how `aws s3 cp` works (it copies files, it doesn't set permissions). D (ACLs) *could* technically achieve something similar, but it's the legacy mechanism — the bucket-policy approach in A is what the question is actually asking about, consistent with Q14's distinction.
⚠️ Worth a safety note even in an answer key: AWS blocks this by default via **S3 Block Public Access** — you'd need to explicitly turn that off for the bucket before a policy like this takes effect.

---

### Q19. What does the "Effect" attribute in an S3 bucket policy specify?

- A) The type of encryption used for objects in the bucket.
- B) ✅ **Whether the policy allows or denies the specified actions.**
- C) The storage class for objects in the bucket.
- D) The versioning status of the bucket.

**Why:** `Effect` is always either `Allow` or `Deny` — nothing to do with encryption (A), storage class (C), or versioning (D), which are all separate, unrelated configuration areas.

---

### Q20. What command is used to create an EC2 instance in AWS?

- A) `aws ec2 create-instance`
- B) `aws ec2 launch-instance`
- C) ✅ **`aws ec2 run-instance`**
- D) `aws ec2 start-instance`

**Why:** None of `create-instance` (A), `launch-instance` (B), or `start-instance` (D) exist as real AWS CLI commands — `start-instances` *is* real, but it **starts a stopped instance**, it doesn't create a new one. ⚠️ Worth getting exactly right for actual use: the real AWS CLI command is **`aws ec2 run-instances`** — plural, with a trailing "s" that this quiz's option C is missing.

---

### Q21. How can you delete an EC2 instance using AWS CLI?

- A) ✅ **`aws ec2 terminate-instances`**
- B) `aws ec2 remove-instances`
- C) `aws ec2 delete-instances`
- D) `aws ec2 stop-instances`

**Why:** **Terminate** = permanently deletes the instance (and its root EBS volume, by default). **Stop** (D) just powers it off — the instance still exists and you're still billed for its storage, so it's not a "delete." B and C aren't real AWS CLI subcommands at all. This distinction matters a lot in real cost-management situations, not just quiz answers.

---

### Q22. How do you attach an IAM role to an EC2 instance?

- A) By configuring it in the EC2 instance's user data
- B) By associating it with a specific IAM user
- C) ✅ **By attaching it during the EC2 instance creation process or later by modifying the instance settings.**
- D) IAM roles cannot be attached to EC2 instances

**Why:** Roles are **not** set via user data (A — that's for boot-time scripts, not permissions), and they're **not** tied to an IAM user (B — an EC2 instance assumes a role directly, independent of any IAM user). D is simply false — roles absolutely can be, and routinely are, attached to EC2. See the Instance Profile detail in `23September_IAMRole.md` §7 for what's actually happening behind this console action.

---

### Q23. Which command would you use to delete an object named `file.txt` from an S3 bucket called `mcdevopsbucket1`?

- A) `aws s3 rm s3://mcdevopsbucket1/file.txt`
- B) `aws s3 delete s3://mcdevopsbucket1/file.txt`
- C) `aws s3api delete-object --bucket mcdevopsbucket1 --key file.txt`
- D) ✅ **Both A and C**

**Why:** **A** is the high-level CLI way; **C** is the low-level API-mirroring way — both genuinely work and produce the same result. **B** isn't a real subcommand at all — there is no `delete` verb in the `aws s3` CLI, which is exactly why it's the trap option here.

---

### Q24. How would you copy a file named `file.txt` from your local machine to an S3 bucket named `mcdevopsbucket1` using AWS CLI?

- A) `aws s3 cp mcdevopsbucket1 file.txt`
- B) `aws s3 mv file.txt s3://mcdevopsbucket1`
- C) ✅ **`aws s3 cp file.txt s3://mcdevopsbucket1`**
- D) `aws s3 upload file.txt mcdevopsbucket1`
- *(also listed: "Both B & C", "Other:")*

**Why:** **C** has the correct syntax and the correct verb for a *copy*. **B** (`mv`) would also land the file in S3 — but `mv` **deletes the local original** afterward. The question specifically asks for a **copy**, so `mv` changes the outcome (you no longer have the local file) even though the destination result looks identical — which is why "Both B & C" is not the right pick either. **A** has the source/destination arguments reversed, and **D** (`aws s3 upload`) isn't a real command.

---

### Q25. Which command can be used to create a new S3 bucket named `mcdevopsbucket1` in the us-west-1 region?

- A) ✅ **`aws s3 mb s3://mcdevopsbucket1 --region us-west-1`**
- B) `aws s3 mb s3://mcdevopsbucket1`
- C) `aws s3 mb s3://mcdevopsbucket1 us-west-1`
- D) none

**Why:** **B** omits `--region` entirely — the bucket would be created in whatever region your CLI is currently configured for, **not necessarily `us-west-1`**, so it doesn't satisfy the question as asked. **C** bolts the region onto the end with no flag — `mb` doesn't accept a bare positional region argument, so that's invalid syntax. **A** is the correct, explicit form.

---

## Quick Recap Table

| # | Topic | Correct answer | One-line reasoning |
|---|---|---|---|
| 1 | NAT Gateway | Translates private→public IP for outbound access | Outbound-only, never inbound |
| 2 | S3 object size limit | 5 TB | Multipart upload needed beyond 5 GB per part |
| 3 | S3 low-latency classes | STANDARD (+ INTELLIGENT_TIERING, ONEZONE_IA) | GLACIER is the odd one out — minutes/hours, not ms |
| 4 | Successful upload code | HTTP 200 | Universal "it worked" |
| 5 | HTTP/HTTPS ports | 80 & 443 | Also the ALB/CloudFront listener defaults |
| 6 | Explicit deny in a VPC | Network ACL | Security Groups can't explicitly deny |
| 7 | VPC CIDR range | /16 to /28 | /16 largest, /28 smallest |
| 8 | Object storage service | S3 | Not EC2, not ELB |
| 9 | User vs Role | User = permanent identity, Role = temporary | Watch the reversed trap option (B) |
| 10 | Controls access to resources | IAM Policies | Users/Roles/Groups are identities, Policies are the rules |
| 11 | S3 storage classes | Standard / Standard-IA / One Zone-IA / Glacier | The other options are EC2/EBS terms |
| 12 | Purpose of versioning | Access previous object versions | Not primarily about encryption or replication |
| 13 | Static website hosting | Serves website files directly from the bucket | Not a database or load balancer feature |
| 14 | IAM-policy-style S3 access control | Bucket Policies | ACLs use older, separate syntax |
| 15 | Automates storage-class transitions | S3 Lifecycle | Not Transfer Acceleration or S3 Select |
| 16 | S3 bucket size limit | Unlimited | Different from the 5 TB per-object limit |
| 17 | CLI: delete a bucket | `aws s3 rb bucket_name` | `rb` = remove bucket |
| 18 | Public read via bucket policy | `Effect: Allow`, `Principal: *` | Still blocked by default via Block Public Access |
| 19 | "Effect" attribute | Allow or Deny | Nothing to do with encryption/storage class |
| 20 | CLI: create an EC2 instance | `run-instance(s)` | Real command has a trailing "s" |
| 21 | CLI: delete an EC2 instance | `aws ec2 terminate-instances` | Stop ≠ delete — instance still exists if stopped |
| 22 | Attach IAM role to EC2 | At creation, or later via instance settings | Not via user data, not tied to an IAM user |
| 23 | CLI: delete an S3 object | Both `aws s3 rm` and `aws s3api delete-object` | `aws s3 delete` isn't a real command |
| 24 | CLI: copy a file to S3 | `aws s3 cp file.txt s3://bucket` | `mv` deletes the local copy — not a "copy" |
| 25 | CLI: create a bucket in a specific region | `aws s3 mb s3://bucket --region us-west-1` | Omitting `--region` uses your default region instead |
