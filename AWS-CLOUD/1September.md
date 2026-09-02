# Batch 18 — AWS Cloud Running Notes: 1 September 2026

**Topic: On-Premises vs Cloud, AWS Free Tier, AWS Region vs Availability Zone, Multi-AZ High Availability, Your First EC2 Instance**

Friends, from today we move from pure Linux into **AWS Cloud** — this is the whole reason we've been learning Linux in the first place, since almost every AWS server you'll touch runs Linux underneath. Today: what "cloud" actually means compared to running your own datacenter, the AWS Free Tier you'll be practicing on, Regions vs Availability Zones, and finally — launching and connecting to your very first EC2 instance.

---

## 1. On-Premises vs Cloud

**On-premises** means you own and manage everything yourself, in your own datacenter. This includes:
- Servers (the big computers)
- Storage
- Networking equipment
- Power and cooling
- Security
- IT staff to maintain all of it

**Cloud** means using someone else's computers (servers) over the internet, instead of owning and managing your own.

### Example — running a website

| | On-premises | Cloud |
|---|---|---|
| Steps | Buy a server → install OS/software → set up networking → handle power & cooling → fix hardware issues → upgrade when traffic grows | Create an account → click "Create Server" → choose server size → pay per hour/usage → scale up or down as needed |
| Storage | Limited — an external hard drive or another server | Scales on demand |
| If something breaks | Real risk of data loss | Provider handles the physical infrastructure |
| Result | Takes time, high cost, requires real expertise | Fast, flexible, beginner-friendly |

### Key benefits of cloud (why it's popular)

- No hardware to buy — no big upfront capital investment.
- Pay only for what you use (on-demand) — like an electricity bill, not a fixed cost.
- Easy to scale resources — add more capacity in minutes, not weeks.
- High availability — providers run across multiple data centers.
- High scalability — handle sudden traffic spikes automatically.
- Faster to start — a server is ready in minutes, not days.
- Global access from anywhere — manage infrastructure from any internet connection.

### When on-premises is still used

- Strict data security laws exist (data must physically stay within a country/building).
- Internet isn't reliable (cloud needs connectivity to manage/access resources).
- Legacy systems are in use that can't easily be moved to the cloud.
- Full control over systems is required (compliance or custom hardware needs).

**Real-time example:** A bank with strict data-residency regulations might keep core transaction systems on-premises, while still using AWS for less sensitive workloads like its public website or analytics — most real companies run a mix, not one or the other.

**Easy memory trick:** On-premises → you own the building. Cloud → you rent someone else's.

---

## 2. AWS Free Tier

Lets new users try AWS services without paying immediately. Mainly used for:
- Learning AWS
- Practice
- Small experiments
- Beginners in Cloud

### Current usage model (new accounts)

- AWS offers a Free Plan with credits.
- Up to $200 in AWS credits: $100 at signup, and up to $100 more by completing learning activities.
- Valid for 6 months, or until the credits run out — whichever comes first.
- No charges unless you upgrade to a Paid Plan.

### 1 year or 6 months?

- Older AWS accounts (created earlier) had 12 months of Free Tier for many services.
- New AWS accounts mostly follow the 6-month Free Plan with credits instead.
- AWS's model can change over time — always check current usage limits in the AWS console rather than relying on what you read somewhere.

### Always-free services (no expiry, with limits)

Some services stay free every month within a limit, even after your credits run out:

| Service | Always-free limit |
|---|---|
| AWS Lambda | 1 million free requests per month |
| Amazon S3 | Limited free storage |
| Amazon DynamoDB | Free storage and read/write capacity |

Going over the limit means you start getting billed for the excess.

### Important points to remember

- A credit card is required to create an AWS account, even for free-tier usage (identity/fraud verification).
- AWS follows a pay-as-you-use model — billed for exactly what you consume beyond free limits.
- Exceeding free limits means automatic charges, with no warning by default.
- Always monitor the billing dashboard so usage doesn't silently creep past the free tier.

**Real-time example:** The classic beginner mistake — launching a bigger EC2 instance type "just to try it," forgetting it's running, and getting a surprise bill a week later because that instance type wasn't covered by the free tier. Always double-check what's actually free before launching anything.

**Easy memory trick:** Free Tier → a starter pack, not a permanent free pass.

---

## 3. AWS Region vs Availability Zone

### Region

- A geographic location in the world.
- Each region contains multiple data centers.
- Regions are completely isolated from each other.
- Used for disaster recovery, data residency requirements, and latency-based deployments (put your app close to your users).

Examples: `us-east-1` (N. Virginia), `ap-south-1` (Mumbai), `eu-west-1` (Ireland).

### Availability Zone (AZ)

- A physically separate data center inside a region.
- Each region has 2–6+ AZs.
- AZs are isolated from each other, but connected by low-latency networks.
- Used for high availability, fault tolerance, and redundant architecture.

Example inside `ap-south-1` (Mumbai): `ap-south-1a`, `ap-south-1b`, `ap-south-1c`.

### The simple difference

| | Region | Availability Zone |
|---|---|---|
| Size | A geographical area (big) | A data center inside a region (smaller) |
| One-line definition | A geographic location, containing multiple AZs | An isolated data center within a region, designed for high availability and fault tolerance |

**Easy memory trick:** Region → the city. Availability Zone → one specific data center building in that city.

---

## 4. Why Multi-AZ deployments give high availability

By default, Availability Zones are **not** replicas of each other — they're independent data centers within a region. High availability only happens when **you** deploy your application and data across multiple AZs yourself.

- If AZ-A goes down, AZ-B automatically keeps serving traffic — but only if you actually set things up that way.

**Real-time example — a real Multi-AZ setup:**
- 2 EC2 instances, deployed in two different AZs.
- An ALB (Application Load Balancer) balances traffic between them.
- RDS Multi-AZ keeps a standby database replica ready in the other AZ.
- Auto Scaling automatically replaces any instance that fails.

If one entire AZ has a power outage, this setup keeps the application running without anyone needing to manually intervene at 2 AM.

**Easy memory trick:** Multi-AZ isn't automatic — it's a design decision you make.

---

## 5. Hands-on: your first EC2 instance

Today's practical flow: log in to AWS → launch an EC2 instance → connect to it over SSH → run basic Linux commands on it.

**Steps:**
1. **Log in** to the AWS Console.
2. Open the **EC2** service.
3. **Launch an EC2 instance** (choose an AMI, instance type, and a key pair — the `.pem` file).
4. **Connect** to it from your PC using SSH — Git Bash is the easiest way to get an SSH client on Windows.

```
$ ssh -i "b18awskey.pem" ec2-user@ec2-100-61-148-210.compute-1.amazonaws.com
```
- `-i "b18awskey.pem"` — the private key file matching the key pair chosen at launch; this proves your identity to the instance instead of a password.
- `ec2-user@...` — the default login username for an Amazon Linux instance, `@` followed by the instance's public DNS name.

Once connected, you land as `ec2-user`. Switch to root for full access:
```
$ sudo su -
```

**Practicing basic Linux commands on the new instance:**
```
$ pwd
/root

$ touch file1 file2 file3
$ mkdir dir1 dir2 dir3
$ ll
$ ls -lrth
$ ls -la
$ rm -rf file1
$ clear
$ cd dir1
$ cd ..
$ echo "madhukiran"
$ echo "Welcome 2 aws devops world" > fname
$ cat fname
Welcome 2 aws devops world
```
Every one of these is a command we've already covered in the Linux sessions — the only thing new today is that you're now running them on a **real cloud server**, not just a local practice machine.

**Real-time example:** This exact sequence — log in, launch, connect via SSH, run a few sanity-check commands — is literally Day 1 for a new DevOps hire at any company using AWS. Getting comfortable with it now means it's second nature by the time it matters on a real project.

**Easy memory trick:** No drive letters, no double-click — on AWS, everything starts with SSH.

---

## Quick Recap Table

| Concept / Command | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| On-premises vs Cloud | Own your servers vs rent someone else's | Choosing AWS over building a datacenter for a new startup |
| AWS Free Tier | $200 credits, ~6 months, some services always free within limits | Practicing EC2/S3 without a surprise bill — if you watch the limits |
| Region | A geographic area with multiple data centers | `ap-south-1` (Mumbai) for low latency to Indian users |
| Availability Zone (AZ) | An isolated data center inside a region | `ap-south-1a`, `ap-south-1b` — spreading instances across both |
| Multi-AZ deployment | Redundancy you design, not something automatic | 2 EC2s + ALB + RDS Multi-AZ + Auto Scaling |
| `ssh -i key.pem user@host` | Connect to an EC2 instance | Logging into a freshly launched server for the first time |
| `sudo su -` | Switch to root on the instance | Getting full access right after connecting |
