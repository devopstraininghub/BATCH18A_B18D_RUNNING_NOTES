# Batch 18 — AWS Cloud Running Notes: 8 October 2026

**Topic: Quiz 3 — Questions & Answer Key (RDS, Route 53, ENI/EIP, CloudFront, ACM, Cloud Models, ELB/ASG, IAM, EBS, VPC, SQL)**

Friends, this is the full quiz, with the correct answer marked ✅, for **Quiz 3** — a broad review spanning almost everything covered so far: `25September_RDS.md`, `28September_Route53.md`, `11September_ENI.md`, `10September_IP_EIP.md`, `30September_CloudFront.md`, `29September_ACM.md`, `30September_CloudModels.md`, `8September_SNS_ASG.md`, `18September_IAM.md`, `2September_EBS.md`, `9September_VPC.md`, and `23September_Databases.md`. Each question is followed by the reasoning behind the correct answer, with common-trap callouts where relevant.

---

### Q1. What is the MySQL default port for connecting to an Amazon RDS instance?

- A) 1521
- B) 5432
- C) ✅ **3306**
- D) 1433

**Why:** `1521` = Oracle, `5432` = PostgreSQL, `1433` = SQL Server — each database engine has its own default port, and MySQL's is **3306**. Same fact as `25September_RDS.md` §9.

---

### Q2. What is the primary purpose of Amazon Route 53?

- A) Cloud storage for objects.
- B) ✅ **Domain name system (DNS) web service.**
- C) Object storage for media files.
- D) Compute resources on-demand.

**Why:** A and C both describe **S3**, D describes **EC2** — Route 53's whole job is DNS: converting domain names into IPs/AWS resources and routing traffic. See `28September_Route53.md` §1.

---

### Q3. In AWS, what is the primary purpose of an Elastic Network Interface (ENI)?

- A) Managing security groups
- B) Providing a unique identifier for instances
- C) ✅ **Facilitating communication between instances and the VPC**
- D) Configuring Amazon S3 storage

**Why:** An ENI is essentially a **virtual network card** — it's what actually gives an instance its private IP, MAC address, and network connectivity inside the VPC. Security Groups (A) *attach to* an ENI but aren't what the ENI itself is for; an instance's unique identifier (B) is its Instance ID, not the ENI; and S3 (D) is unrelated to networking entirely. See `11September_ENI.md`.

---

### Q4. In AWS, can you move an Elastic IP address from one ENI to another?

- A) ✅ **Yes, anytime without restrictions.**
- B) No, once associated, an Elastic IP is tied to a specific ENI.
- C) Yes, but only during instance launch.
- D) No, Elastic IPs can only be associated with the primary ENI.

**Why:** The entire point of an **Elastic** IP is that it's remappable — you can disassociate it from one ENI/instance and reassociate it with another essentially on demand, which is exactly what makes it useful for fast failover. B and D both falsely claim it's permanently fixed, and C wrongly limits this to launch time only. (In practice there are account-level EIP quotas and the usual "resource must exist" constraints — but nothing like the restrictions B–D describe.)

---

### Q5. Can you move an Elastic Network Interface (ENI) from one EC2 instance to another in AWS?

- A) Yes, at any time without restrictions.
- B) No, ENIs are permanently attached to specific instances.
- C) ✅ **Yes, but only when the instances are in the same subnet. With restrictions**
- D) No, only the primary ENI can be moved.

**Why:** A **secondary** ENI genuinely can be detached from one instance and attached to another — so B is wrong, and D is backwards (it's actually the opposite: the **primary** ENI/`eth0` is the one that *can't* be detached; only secondary ENIs can move). The real restriction AWS enforces is that the new instance must be in the **same Availability Zone** as the ENI — not strictly the same subnet, though same-subnet obviously implies same-AZ too, so C is the closest of the four options and correctly flags that restrictions exist. A overstates it ("without restrictions") when the AZ constraint is very real.

---

### Q6. What is Amazon CloudFront primarily designed for in AWS?

- A) Database storage
- B) ✅ **Content delivery**
- C) Virtual private networking
- D) DNS management

**Why:** CloudFront is AWS's **CDN** — it delivers cached and dynamic content from edge locations close to users. Not storage (A), not VPN (C), and DNS (D) is Route 53's job, not CloudFront's. See `30September_CloudFront.md` §1.

---

### Q7. What is the primary benefit of using Amazon CloudFront for content delivery?

- A) Low-level network configuration
- B) Improved security features
- C) ✅ **Low latency and high performance**
- D) Advanced machine learning analytics

**Why:** CloudFront's core value proposition is serving content from the edge location nearest the user — lower latency, faster delivery. Security (B, via WAF/Shield integration) and other benefits exist too, but they're secondary to the primary CDN purpose; A and D aren't things CloudFront does at all. See `30September_CloudFront.md` §2.

---

### Q8. What is the purpose of CloudFront behaviors in a CloudFront distribution?

- A) Configuring network security groups
- B) ✅ **Specifying caching behavior and origin settings**
- C) Defining Lambda@Edge functions
- D) Managing SSL/TLS certificates

**Why:** A **Cache Behavior** tells CloudFront "for requests matching this path pattern, use these specific caching/origin rules" — exactly B. Security Groups (A) and certificates (D) are configured elsewhere entirely; Lambda@Edge (C) is a related-but-separate CloudFront feature, not what "behaviors" themselves are for. See `30September_CloudFront.md` §13.

---

### Q9. Which HTTP status code does CloudFront return when it cannot establish a connection to the origin server?

- A) 404 Not Found
- B) ✅ **502 Bad Gateway**
- C) 503 Service Unavailable
- D) 200 OK

**Why:** `404` means the specific resource wasn't found (the connection worked fine) — not this. **502 Bad Gateway** is specifically "I (CloudFront) couldn't successfully talk to the origin," which is exactly this scenario. Matches `30September_CloudFront.md` §26's troubleshooting table exactly.

---

### Q10. What is the key pair used for when launching an EC2 instance?

- A) ✅ **Authentication to the EC2 instance**
- B) Specifying the instance type
- C) Configuring security groups
- D) Defining IAM roles

**Why:** An EC2 key pair is used for SSH (or RDP password decryption on Windows) — proving *who you are* when connecting, nothing to do with instance type, Security Groups, or IAM roles, which are all configured completely separately.

---

### Q11. What is a hosted zone in Amazon Route 53?

- A) A geographic region where DNS records are replicated
- B) A virtual private network for routing traffic
- C) ✅ **A collection of DNS records for a domain and its subdomains**
- D) A security group for controlling network access

**Why:** A Hosted Zone is simply the **container** holding all the DNS records (A, CNAME, MX, etc.) for a domain. It's not tied to a single geographic region (A), has nothing to do with VPNs (B), and isn't a security/access-control construct (D). See `28September_Route53.md` §6.

---

### Q12. What is the purpose of a CNAME record in Amazon Route 53?

- A) Redirecting HTTP to HTTPS
- B) ✅ **Associating an alias with another domain name**
- C) Mapping a domain name to an IP address
- D) Configuring mail server information

**Why:** A common trap — **C describes an A record**, not a CNAME. A CNAME maps one domain/subdomain **to another domain name** (an alias), not directly to an IP. HTTP→HTTPS redirects (A) are a Viewer Protocol Policy/listener setting, not a record type, and mail routing (D) is what MX records do. See `28September_Route53.md` §4.

---

### Q13. Which record type in Route 53 is used to map a domain name to an IPv4 address?

- A) CNAME
- B) ✅ **A**
- C) MX
- D) PTR

**Why:** This is the flip side of Q12 — the **A record** is specifically the one that maps a name directly to an IPv4 address. CNAME (A) maps to another name, MX (C) is for mail servers, and PTR (D) is for reverse DNS (IP→name), not this.

---

### Q14. What is the lifetime of an SSL/TLS certificate issued by AWS Certificate Manager (ACM)?

- A) 1 day
- B) 1 month
- C) ✅ **13 months** *(as originally intended by this question)*
- D) 2 years

⚠️ **Accuracy note, worth flagging rather than quietly passing over:** ACM-issued public certificates were valid for **13 months (395 days)** for a long time, which is clearly what this question was written against — so **C** is the intended answer. However, **as of February 2026, AWS reduced the maximum validity period for newly issued ACM public certificates to 198 days** (~6.5 months), in line with an industry-wide CA/Browser Forum change affecting *all* public certificate authorities, not just AWS. None of this question's four options reflect that current number — it simply predates the change. Good to know both: what this quiz intends (13 months) and what's actually true for a certificate issued today (198 days).

---

### Q15. What is the maximum number of SSL/TLS certificates that can be provisioned per AWS account in AWS Certificate Manager (ACM)?

- A) 5
- B) 10
- C) 50
- D) ✅ **Unlimited** *(best available option)*

⚠️ **Same kind of accuracy note as Q14:** none of these options match AWS's actual documented figure. The real default quota is **2,500 certificates per account at any given time** (with the ability to request up to 5,000 issuances per year), not a tiny number like 5/10/50 and not literally unlimited either — it's a large, adjustable soft quota. Given the four choices, **D ("Unlimited")** is the closest in spirit, since for virtually all real-world use you'll never come close to hitting 2,500 — but it's worth being precise that it's a quota, not infinite.

---

### Q16. Can AWS Certificate Manager (ACM) be used to manage SSL/TLS certificates for services outside of AWS, such as on-premises servers or other cloud providers?

- A) Yes, ACM supports all external services.
- B) ✅ **No, ACM is limited to AWS services and domains.**
- C) Yes, but with limited functionality.
- D) None

**Why:** ACM-issued certificates are designed to be used with **AWS-integrated services** (ALB, CloudFront, API Gateway, etc.) — you cannot export the private key of an ACM-issued certificate to install it on an arbitrary on-premises server or another cloud provider. (The one nuance: you *can* **import** a certificate you obtained elsewhere *into* ACM, so ACM can manage/store a cert that originated outside AWS — but that's different from ACM certificates being usable *outside* AWS, which is what this question asks.)

---

### Q17. In which cloud service model does the provider manage the underlying infrastructure, runtime, and users are responsible for managing applications and data?

- A) IaaS
- B) ✅ **PaaS**
- C) SaaS
- D) XaaS

**Why:** This is exactly the PaaS row from the responsibility table in `30September_CloudModels.md` §6 — provider manages infrastructure + OS/runtime, customer manages application + data. IaaS (A) would still leave the OS/runtime to the customer; SaaS (C) would leave the customer managing neither infra nor the application itself, just usage/config; "XaaS" (D) is a generic umbrella term, not a specific model with this responsibility split.

---

### Q18. What is an example of Infrastructure as a Service (IaaS) in cloud computing?

- A) ✅ **Amazon EC2**
- B) Microsoft Office 365
- C) Salesforce
- D) Google App Engine

**Why:** EC2 gives you a virtual machine — you manage the OS upward, which is the defining trait of IaaS. Office 365 and Salesforce (B, C) are SaaS — ready-to-use software. Google App Engine (D) is a PaaS — you deploy code without managing the underlying VM/OS. See `30September_CloudModels.md` §3.

---

### Q19. Which cloud service model provides complete software applications over the internet without requiring users to manage any underlying infrastructure?

- A) IaaS
- B) PaaS
- C) ✅ **SaaS**
- D) FaaS

**Why:** This is the textbook SaaS definition — ready-to-use software, nothing managed by the customer beyond account/usage/config. PaaS (B) still has you deploying your own application code; FaaS (D, Functions as a Service, e.g. Lambda) is about running your own functions, not using someone else's complete application.

---

### Q20. What type of SSL/TLS certificates can be used with CloudFront to enable secure connections?

- A) Self-signed certificates
- B) Certificates issued by any Certificate Authority (CA)
- C) ✅ **Only certificates issued by AWS Certificate Manager (ACM)** *(intended answer — with one nuance)*
- D) Wildcard certificates only

**Why:** For a **custom domain** on CloudFront, the certificate must be **in ACM**, specifically in **`us-east-1`** (see `30September_CloudFront.md` §16 / `29September_ACM.md` §19). Self-signed certs (A) aren't trusted by browsers and CloudFront doesn't support attaching one directly; "only wildcard" (D) is simply false — single-domain and multi-domain (SAN) certs work too. The one precision worth noting: the certificate doesn't strictly have to be *issued by* ACM — it can also be a certificate **imported into ACM** from elsewhere (§16's nuance again) — but either way, it must be sitting in ACM to be usable by CloudFront, which is the spirit of why C is the intended answer here.

---

### Q21. What is the purpose of an Elastic Load Balancer (ELB) in conjunction with EC2 instances?

- A) It provides additional storage for EC2 instances.
- B) ✅ **It distributes incoming traffic across multiple EC2 instances.**
- C) It manages security groups for EC2 instances.
- D) It stores and retrieves data for EC2 instances.

**Why:** That's literally the definition of a load balancer. A and D both describe storage services (EBS/S3), and C is simply not what an ELB does — Security Groups are managed independently, even though an ALB does have its own SG.

---

### Q22. What is the key benefit of using Auto Scaling Groups with EC2 instances?

- A) Ensures that EC2 instances run in isolation.
- B) Allows manual scaling of instances based on demand.
- C) ✅ **Automatically adjusts the number of running instances based on demand.**
- D) Provides additional security features for EC2 instances.

**Why:** The entire point of an ASG is **automatic** scaling — B describes the opposite (manual), which defeats the purpose. A and D aren't what ASGs are for at all. See `8September_SNS_ASG.md`.

---

### Q23. Can an Elastic Load Balancer (ELB) distribute traffic to instances in different Availability Zones?

- A) No, ELB can only distribute traffic to instances in different regions.
- B) No, ELB can only distribute traffic to instances in the same Availability Zone.
- C) ✅ **Yes, ELB automatically distributes traffic across instances in multiple Availability Zones.**
- D) none

**Why:** Multi-AZ distribution is one of ELB's core selling points — it's how you get high availability across a Region, not just within one AZ. A is wrong in the other direction (ELB operates *within* a single Region, across its AZs — not *across* regions), and B is simply the opposite of the truth.

---

### Q24. What is an IAM policy statement used for?

- A) Creating IAM users
- B) Defining password policies
- C) ✅ **Specifying the permissions for a resource or a set of resources**
- D) Configuring multi-factor authentication

**Why:** A policy statement is the actual `Effect`/`Action`/`Resource` block that defines what's allowed or denied. Creating users (A), setting password rules (B), and MFA (D) are all separate IAM account-settings features, not what a policy *statement* itself is for. See `18September_IAM.md`.

---

### Q25. In Elastic Load Balancer (ELB), what is the purpose of the health check mechanism?

- A) To encrypt traffic between the load balancer and the targets.
- B) ✅ **To determine whether the targets are responding to requests.**
- C) To set the expiration date for SSL/TLS certificates.
- D) To enforce access control policies for incoming traffic.

**Why:** Health checks exist purely to answer "is this target healthy enough to keep receiving traffic?" — nothing to do with encryption (A), certificate expiry (C), or access control (D), which are all separate concerns handled elsewhere (TLS listener config, ACM, and Security Groups respectively).

---

### Q26. Can you modify the size of an Amazon EBS volume after it is created and attached to an EC2 instance?

- A) Yes, but only for Provisioned IOPS (PIOPS) volumes.
- B) No, the size of an EBS volume is fixed at creation.
- C) ✅ **Yes, for all types of EBS volumes.**
- D) Yes, but only for Magnetic volumes.

**Why:** AWS's **Elastic Volumes** feature (live since 2017) lets you increase size, change volume type, and adjust IOPS **while the volume is in use**, across all current EBS volume types — not limited to PIOPS (A) or Magnetic (D) specifically, and definitely not fixed forever (B). See `2September_EBS.md`.

---

### Q27. Which AWS service can be integrated with Amazon EC2 Auto Scaling to automatically add or remove instances based on demand?

- A) AWS Lambda
- B) AWS Elastic Beanstalk
- C) ✅ **AWS CloudWatch**
- D) AWS S3

**Why:** Scaling policies are triggered by **CloudWatch alarms** (e.g. CPU utilization crossing a threshold) — that's the actual mechanism behind "automatically adjusts based on demand." Lambda, Elastic Beanstalk, and S3 (A, B, D) aren't what drives ASG's scaling decisions.

---

### Q28. What is the minimum and maximum number of instances that you can configure for an Auto Scaling Group (ASG)?

- A) Minimum: 1, Maximum: 10
- B) Minimum: 1, Maximum: unlimited
- C) ✅ **Min: equal to or less than desired capacity. Max: equal to or greater than desired capacity.**
- D) Min: greater than desired capacity. Max: less than desired capacity.

**Why:** There's no universal fixed number like "1 to 10" (A) or "1 to unlimited" (B) — **you** choose Min, Desired, and Max when configuring the ASG, for your own workload. The one hard rule AWS enforces is the **relationship** between them: `Min ≤ Desired ≤ Max` — exactly what C states. D has the relationship backwards, which would make the configuration invalid.

---

### Q29. What is the default limit for the number of VPCs per AWS region?

- A) ✅ **5**
- B) 10
- C) 20
- D) 50

**Why:** The default (soft, adjustable) quota is **5 VPCs per region** per account — confirmed current as of this course. You can request an increase (AWS commonly approves increases to the hundreds for valid use cases), but the out-of-the-box default is 5.

---

### Q30. What is the largest region in the Amazon Web Services (AWS) global infrastructure?

- A) US West (Oregon)
- B) Asia Pacific (Mumbai)
- C) EU (Ireland)
- D) ✅ **US East (N. Virginia)**

**Why:** **US East (N. Virginia)** was AWS's first-ever region, has **6 Availability Zones** (more than most regions), and is the one region where literally every AWS service launches first — making it the largest and most fully-featured region in the global infrastructure.

---

### Q31. What does Multi-AZ deployment in Amazon RDS provide?

- A) ✅ **Multiple Availability Zones for redundancy**
- B) Multiple Authentication Zones for security
- C) Multi-Architecture support
- D) Multi-Account deployment

**Why:** Multi-AZ RDS keeps a **synchronously-replicated standby** in a second Availability Zone, purely for **high availability/failover** — B, C, and D are all invented-sounding distractors that aren't real AWS RDS concepts. See `23September_Databases.md`.

---

### Q32. Which of the following database engines is not supported by Amazon RDS?

- A) MySQL
- B) PostgreSQL
- C) ✅ **MongoDB**
- D) Oracle

**Why:** RDS supports MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, and Aurora — **not MongoDB**. MongoDB-*compatible* workloads on AWS go through **Amazon DocumentDB** instead, a separate, purpose-built service. See `23September_Databases.md`'s AWS database summary.

---

### Q33. What are some of the benefits of using Amazon RDS?

- A) Automatic setup and configuration of databases.
- B) Scalability to meet changing workloads.
- C) High availability and disaster recovery.
- D) Reduced operational overhead.
- E) ✅ **All of the above.**

**Why:** All four are genuinely real, documented RDS benefits — this is exactly the "why RDS instead of managing MySQL yourself" case made in `25September_RDS.md` §2, nothing here is a distractor.

---

### Q34. What is Amazon RDS used for in AWS?

- A) Radient Database Service
- B) ✅ **Relational Database Service**
- C) Virtual Private Network (VPN)
- D) Internet of Things (IoT)

**Why:** "Radient" (A) isn't a real word/acronym at all — a pure typo-trap. RDS has nothing to do with VPN (C) or IoT (D). See `25September_RDS.md` §1.

---

### Q35. What pricing model is used for Amazon RDS?

- A) Data transfer based
- B) Annual subscription
- C) ✅ **Pay-as-you-go**
- D) Fixed monthly fee

**Why:** Like virtually every core AWS service, RDS bills on consumption (instance hours, storage, I/O, backup storage beyond the free allotment) — not a flat subscription (B) or fixed fee (D). Data transfer (A) is only one small slice of the total bill, not the overall pricing model.

---

### Q36. What is the purpose of an RDS database snapshot?

- A) To create a backup of an RDS database.
- B) To restore an RDS database to a previous point in time.
- C) To clone an RDS database to another region.
- D) ✅ **All of the above.**

**Why:** Snapshots genuinely serve all three real-world purposes: they **are** backups, they're what you **restore from** (to a new instance, at a point in time), and copying a snapshot cross-region before restoring is the standard way to **clone a database into another region**.

---

### Q37. Which MySQL command is used to view all the databases?

- A) ✅ **`SHOW DATABASES;`**
- B) `SELECT DATABASES;`
- C) `LIST DATABASES;`
- D) `VIEW DATABASES;`

**Why:** `SHOW DATABASES;` is the real MySQL syntax — this is literally the first command run in `25September_RDS.md` §24's hands-on SQL session. B, C, D are all plausible-sounding but don't exist in MySQL.

---

### Q38. What is the correct syntax to delete a record where employee_id = 10 from the employees table?

- A) ✅ **`DELETE FROM employees WHERE employee_id = 10;`**
- B) `REMOVE FROM employees WHERE employee_id = 10;`
- C) `DELETE employee_id FROM employees;`
- D) `DELETE RECORD FROM employees WHERE employee_id = 10;`

**Why:** Standard SQL `DELETE` syntax is `DELETE FROM <table> WHERE <condition>;` — exactly A. `REMOVE` (B) isn't a SQL keyword, C is missing the `WHERE` clause entirely (and would be invalid syntax as written), and D invents a `RECORD` keyword that doesn't exist in SQL.

---

### Q39. Which of the following statements will delete all records in a table?

- A) ✅ **`DELETE FROM table_name;`**
- B) `DROP TABLE table_name;`
- C) `CLEAR TABLE table_name;`
- D) `DELETE ALL FROM table_name;`

**Why:** `DELETE FROM table_name;` with **no `WHERE` clause** deletes every row — but critically, **keeps the table structure intact**, empty and ready for new data. ⚠️ This is exactly the "forgot the WHERE clause" danger flagged in `23September_Databases.md`. **B (`DROP TABLE`) is the common trap here** — it doesn't just delete the records, it deletes the **entire table** (columns, structure, everything) — a much more destructive, different operation. C and D aren't real SQL syntax.

---

### Q40. Which MySQL command is used to delete an entire table from a database?

- A) `REMOVE TABLE`
- B) `DELETE TABLE`
- C) ✅ **`DROP TABLE`**
- D) `CLEAR TABLE`

**Why:** This is the direct counterpart to Q39's trap — **`DROP TABLE`** is the real command for removing a table entirely, structure and all. None of `REMOVE TABLE`, `DELETE TABLE`, or `CLEAR TABLE` are valid SQL.

---

## Quick Recap Table

| # | Topic | Correct answer | One-line reasoning |
|---|---|---|---|
| 1 | MySQL default port | 3306 | Each DB engine has its own default port |
| 2 | Route 53 purpose | DNS web service | Not storage, not compute |
| 3 | ENI purpose | Connects instances to the VPC network | A virtual network card |
| 4 | Move an EIP between ENIs | Yes, anytime | That's the "Elastic" in Elastic IP |
| 5 | Move an ENI between instances | Yes, but restricted to the same AZ | Only secondary ENIs; primary can't move |
| 6 | CloudFront's primary purpose | Content delivery | AWS's CDN |
| 7 | CloudFront's main benefit | Low latency, high performance | Edge caching near users |
| 8 | CloudFront "behaviors" | Caching + origin settings per path | Not security groups or certs |
| 9 | CloudFront can't reach origin | HTTP 502 Bad Gateway | Matches `30September_CloudFront.md` |
| 10 | EC2 key pair | Authentication to the instance | SSH/RDP login, not config |
| 11 | Route 53 hosted zone | Collection of DNS records for a domain | Not a region or a security group |
| 12 | CNAME record purpose | Alias to another domain name | Not an IP mapping — that's an A record |
| 13 | Record mapping name→IPv4 | A record | CNAME maps to a name, not an IP |
| 14 | ACM certificate lifetime | 13 months (as the quiz intends) | Actually 198 days since Feb 2026 — verified |
| 15 | Max ACM certs per account | "Unlimited" (closest option) | Real quota is 2,500, adjustable — verified |
| 16 | ACM outside AWS | No — limited to AWS services/domains | Can import external certs in, not export out |
| 17 | Provider manages infra+runtime, customer manages app+data | PaaS | Matches the responsibility table exactly |
| 18 | IaaS example | Amazon EC2 | You manage the OS upward |
| 19 | Complete software, zero infra management | SaaS | Gmail/Salesforce-style |
| 20 | CloudFront certificate requirement | Must be in ACM (us-east-1) | Imported certs also count, but must be in ACM |
| 21 | ELB purpose | Distributes traffic across EC2 instances | Not storage, not SG management |
| 22 | ASG's key benefit | Automatically adjusts instance count | Manual scaling defeats the purpose |
| 23 | ELB across AZs | Yes, automatically, across multiple AZs | Core to ELB's HA design |
| 24 | IAM policy statement | Specifies permissions on resources | Not user creation or MFA |
| 25 | ELB health checks | Checks if targets are responding | Not encryption or access control |
| 26 | Resize an EBS volume in use | Yes, for all volume types | Elastic Volumes feature, since 2017 |
| 27 | Drives ASG scaling decisions | AWS CloudWatch (alarms) | Not Lambda, Beanstalk, or S3 |
| 28 | ASG min/max relationship | Min ≤ Desired ≤ Max | No fixed universal numbers |
| 29 | Default VPCs per region | 5 | Soft quota, adjustable — verified |
| 30 | Largest AWS region | US East (N. Virginia) | 6 AZs, first region, most services — verified |
| 31 | RDS Multi-AZ | Redundancy via a standby in a 2nd AZ | Not about auth, architecture, or accounts |
| 32 | RDS-unsupported engine | MongoDB | Use DocumentDB for Mongo-compatible workloads |
| 33 | RDS benefits | All of the above | Setup, scalability, HA/DR, less overhead |
| 34 | RDS stands for | Relational Database Service | "Radient" is a typo-trap |
| 35 | RDS pricing model | Pay-as-you-go | Standard AWS consumption billing |
| 36 | RDS snapshot purpose | All of the above | Backup, restore, and cross-region cloning |
| 37 | View all MySQL databases | `SHOW DATABASES;` | Real MySQL syntax |
| 38 | Delete one record | `DELETE FROM employees WHERE employee_id = 10;` | Needs the WHERE clause |
| 39 | Delete all records, keep table | `DELETE FROM table_name;` | `DROP TABLE` removes the table itself — different! |
| 40 | Delete an entire table | `DROP TABLE` | The real SQL keyword for this |
