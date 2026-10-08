# Batch 18 — AWS Cloud Running Notes: 8 October 2026

**Topic: Quiz 2 — Answer Key (VPC, S3, IAM, EC2)**

Friends, this is the answer key for **Quiz 2**, covering everything from VPC fundamentals through S3, IAM, and EC2 CLI basics — the topics from `9September_VPC.md`, `21September_S3.md`, `18September_IAM.md`, `23September_IAMRole.md`, and `22September_CLI.md`. Each question below has the correct answer marked ✅, with the reasoning behind it — and, where a wrong option is a *common* trap rather than just obviously wrong, why that one's wrong too.

---

### Q1. What does a NAT Gateway actually do in a VPC?

- ✅ **NAT Gateway translates private IP addresses of instances in a private subnet to public IP addresses for outbound internet access.**
- Why the others fail: NAT Gateway is **outbound-only** — it does **not** let the Internet initiate connections *into* private instances (that would need a public IP or a Bastion/ALB). It also has nothing to do with cross-VPC communication (that's VPC Peering) or handing out public IPs directly (that's an EIP on a public-subnet instance).
- **Easy memory trick:** NAT = "private instance wants to go OUT, not be reached FROM outside." See `11September_NATGateway.md`.

---

### Q2. Maximum size of a single object in S3?

- ✅ **5 TB**
- A single `PutObject` call tops out at 5 GB — anything bigger (up to the 5 TB ceiling) must go through a **multipart upload**, not that this quiz question is testing that detail, but worth knowing.
- Don't confuse this with Q16 below — that one asks about the **bucket's** size limit, which is a completely different number.

---

### Q3. Which S3 storage classes offer low-latency (millisecond) access?

- ✅ **STANDARD, INTELLIGENT_TIERING, and ONEZONE_IA all qualify** — the one that does **NOT** is **GLACIER**.
- **Why:** millisecond first-byte latency is a property of the *default access tier* — STANDARD, INTELLIGENT_TIERING (in its frequent/infrequent tiers), and ONEZONE_IA are all designed for immediate retrieval.
- **GLACIER** trades latency for cost — retrieval takes **minutes to hours**, not milliseconds, by design (that's the whole point of archival storage).
- If this question only allows one answer on your form, pick **STANDARD** — it's the one built specifically around low-latency access with no caveats attached. Full spec table is in `21September_S3.md` §storage classes.

---

### Q4. HTTP status code for a successful S3 upload?

- ✅ **HTTP 200**
- `404` = not found, `501` = not implemented, `307` = temporary redirect — none of those mean "your PUT succeeded."
- **Easy memory trick:** `200 = OK`, the universal "it worked" code across almost every HTTP-based AWS API, not just S3.

---

### Q5. Standard ports for HTTP and HTTPS?

- ✅ **80 & 443** (HTTP = 80, HTTPS = 443)
- Same fact as `29September_ACM.md` §3 — worth having cold, since it comes up constantly (ALB listeners, Security Group rules, CloudFront viewer protocol).

---

### Q6. How do you explicitly *deny* traffic to an instance in your VPC?

- ✅ **Using a Network ACL**
- **The key distinction:** Security Groups are **allow-only** — there's no "deny" rule in a Security Group, you can only choose what to allow (anything not explicitly allowed is implicitly denied, but you can't write an explicit DENY statement).
- **NACLs**, on the other hand, support both **explicit ALLOW and explicit DENY** rules, evaluated in numbered order.
- Putting the instance in a private subnet or editing the route table doesn't "deny traffic" in this sense at all — those control *reachability*, not *inspection-and-decision* on specific traffic. See `11September_NACL.md`.

---

### Q7. Allowed CIDR block range for a VPC?

- ✅ **Between /16 and /28**
- `/16` = the largest VPC you're allowed (65,536 IPs) → `/28` = the smallest (16 IPs, AWS reserves 5 of those per subnet, so effectively 11 usable).
- Covered with worked examples in `9September_VPC.md`.

---

### Q8. Which AWS service stores and retrieves objects like images, videos, and documents?

- ✅ **S3**
- EC2 = compute, ELB = traffic distribution — neither is a storage service. S3 is purpose-built **object storage**.

---

### Q9. What's the actual difference between an IAM User and an IAM Role?

- ✅ **Closest correct option: "A user is a person who uses a system, while a role is a collection of permissions that can be granted to a user."**
- This is the simplified textbook phrasing, but it's worth knowing the **more precise version** we actually use in this course (`23September_IAMRole.md` §1):
  - **IAM User** = a **permanent** identity (a person or an app) with its own long-term credentials.
  - **IAM Role** = a **temporary** identity, assumed only when needed, with **no permanent credentials** of its own.
- ⚠️ **Watch the trap option:** *"A user is a temporary identity... while a role is a permanent identity..."* has this **completely backwards** — it's the single most important fact to get right about Users vs Roles, and this option inverts it. That's why **"All of the above" is wrong** too — one of "the above" is a direct contradiction of the correct fact.

---

### Q10. What's actually used to *control* access to AWS resources?

- ✅ **IAM Policies**
- Users, Roles, and Groups are all **identities** (or containers of identities) — they're *who* is asking. The **Policy** is the actual document that says *what* they're allowed to do. Policies are what you attach to a User, Role, or Group to grant permissions in the first place.

---

### Q11. What are the actual storage classes in S3?

- ✅ **Standard, Standard-IA, One Zone-IA, and Glacier**
- The other options are real AWS categories — just from the **wrong service**: "Instance, Block, Object" describes storage *types* generally (EBS = block, S3 = object), and "General Purpose, Compute Optimized, Memory Optimized" describes **EC2 instance type families**, not S3 at all.

---

### Q12. What's the actual purpose of S3 versioning?

- ✅ **To enable access to previous versions of objects, even after they have been overwritten**
- It's a nice side effect that this also helps *protect against* accidental deletion/overwrite (a delete just adds a delete marker, the old version is still there) — but the *purpose* is keeping every version accessible, not encryption or cross-AZ replication (that's SSE and Cross-Region Replication, two entirely different features).

---

### Q13. What does static website hosting on an S3 bucket actually do?

- ✅ **To store website files and serve them directly from the S3 bucket**
- S3 is not a database engine and not a load balancer — static website hosting literally means "this bucket can respond to HTTP requests for `index.html` and friends, directly."

---

### Q14. Which mechanism controls S3 access using actual IAM-policy-style JSON?

- ✅ **Bucket Policies**
- This is a sharper distinction than it looks: **Bucket Policies** are written in the exact same JSON policy language as IAM policies (`Effect`/`Principal`/`Action`/`Resource`). **ACLs** are a separate, older, XML-based permission system that predates IAM policies entirely and uses a totally different syntax.
- So while both ACLs and Bucket Policies *can* control S3 access in general, only **Bucket Policies** satisfy the question's specific wording — "using AWS IAM policies."
- AWS's own current guidance, for what it's worth, recommends Bucket Policies (or IAM policies) over ACLs for new buckets — ACLs are considered close to legacy at this point.

---

### Q15. Which AWS feature automates moving objects between S3 storage classes?

- ✅ **AWS S3 Lifecycle**
- Transfer Acceleration speeds up *uploads* over long distances, S3 Select lets you query *inside* an object without downloading the whole thing — neither moves objects between storage tiers. Lifecycle rules are exactly the mechanism covered in `21September_S3.md`'s lifecycle section (all 6 action types).

---

### Q16. Maximum size of an S3 **bucket**?

- ✅ **Unlimited**
- Don't confuse this with Q2 — that one's about a single **object** (capped at 5 TB). The **bucket itself** has no overall size or object-count limit — you can keep adding objects indefinitely.

---

### Q17. AWS CLI command to delete an S3 bucket?

- ✅ **`aws s3 rb bucket_name`** (`rb` = "remove bucket")
- There's no `delete-bucket`, `rm-bucket`, or `remove-bucket` subcommand in the high-level `aws s3` CLI — `rb` is the real one, mirroring `mb` ("make bucket") for creation.
- ⚠️ Note the bucket must be **empty** first, or you need `--force` to also delete everything inside it.

---

### Q18. How do you grant public read access to every object in a bucket, via a bucket policy?

- ✅ **Set the Effect to Allow and Principal to `*` for the specified actions.**
- `Principal: "*"` means "anyone, unauthenticated" — combined with `Effect: Allow` and an action like `s3:GetObject`, that's the standard public-read bucket policy pattern.
- ⚠️ Worth a safety note even in an answer key: AWS blocks this by default via **S3 Block Public Access** — you'd need to explicitly turn that off for the bucket before a policy like this takes effect.

---

### Q19. What does the "Effect" attribute in an S3 bucket policy actually specify?

- ✅ **Whether the policy allows or denies the specified actions.**
- `Effect` is always either `Allow` or `Deny` — nothing to do with encryption, storage class, or versioning (those are separate configuration areas entirely).

---

### Q20. AWS CLI command to create an EC2 instance?

- ✅ **Closest correct option: `aws ec2 run-instance`**
- ⚠️ Worth getting exactly right for real use: the actual AWS CLI command is **`aws ec2 run-instances`** (plural, with an "s") — none of the other options (`create-instance`, `launch-instance`, `start-instance`) exist at all. `start-instances` is a real command, but it **starts a stopped instance** — it doesn't create a new one.

---

### Q21. AWS CLI command to delete an EC2 instance?

- ✅ **`aws ec2 terminate-instances`**
- **Terminate** = permanently deletes the instance (and its root EBS volume, by default). **Stop** just powers it off — it still exists and is still billed for storage. This distinction matters a lot in real cost-management situations, not just quiz answers.

---

### Q22. How do you attach an IAM role to an EC2 instance?

- ✅ **By attaching it during the EC2 instance creation process, or later by modifying the instance settings.**
- Roles are **not** set via user data (that's for boot-time scripts, not permissions), and they're **not** tied to an IAM user — an EC2 instance assumes a role directly, independent of any IAM user. See the Instance Profile detail in `23September_IAMRole.md` §7 for what's actually happening behind this console action.

---

### Q23. Command to delete `file.txt` from bucket `mcdevopsbucket1`?

- ✅ **D) Both A and C**
- **A) `aws s3 rm s3://mcdevopsbucket1/file.txt`** — the high-level CLI way.
- **C) `aws s3api delete-object --bucket mcdevopsbucket1 --key file.txt`** — the low-level API-mirroring way, same result.
- **B) `aws s3 delete ...`** isn't a real subcommand at all — there is no `delete` verb in the `aws s3` CLI, which is exactly why it's a trap option.

---

### Q24. Command to copy `file.txt` from your local machine to bucket `mcdevopsbucket1`?

- ✅ **C) `aws s3 cp file.txt s3://mcdevopsbucket1`**
- **B) `aws s3 mv ...`** would also land the file in S3 — but `mv` **deletes the local original** afterward. The question specifically asks for a **copy**, so `mv` changes the outcome (you no longer have the local file) even though the destination result looks the same.
- **A** has the source/destination reversed, and **D** (`aws s3 upload`) isn't a real command.

---

### Q25. Command to create a new S3 bucket `mcdevopsbucket1` in `us-west-1`?

- ✅ **A) `aws s3 mb s3://mcdevopsbucket1 --region us-west-1`**
- **B** omits `--region` entirely — the bucket would be created in whatever region your CLI is currently configured for, **not necessarily `us-west-1`**, so it doesn't satisfy the question as asked.
- **C** bolts the region onto the end with no flag — `mb` doesn't accept a bare positional region argument, so this is invalid syntax.

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
| 9 | User vs Role | User = permanent identity, Role = temporary | Watch the reversed trap option |
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
