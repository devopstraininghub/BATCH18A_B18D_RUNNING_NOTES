# Batch 18 — Linux Running Notes: 13 August 2026

**Topic: Cloud vs On-Premises, Why Linux, AWS Free Tier**

Friends, before touching a single Linux command, we first need to understand *why* we are even learning Linux in a DevOps course. Today's class was pure theory — no typing on the terminal — but this theory is the foundation for everything we do after this. Understand this properly once, and the rest of the course will make a lot more sense.

---

## 1. On-Premises vs Cloud — what is the actual difference?

**On-premises** simply means: you own and manage everything yourself, in your own datacenter. That includes the servers (big computers), storage, networking equipment, power supply, cooling systems, security, and IT staff to maintain all of it.

**Cloud** means: you are using someone else's computers (servers) over the internet, instead of owning and managing your own.

**Real-time example — running a website:**

On-premises way:
- Buy a server
- Install OS and software
- Set up networking
- Handle power & cooling
- Fix hardware issues yourself
- Upgrade hardware when traffic grows
- Limited storage — an external hard drive or one more server
- If it breaks → data loss risk

Result: takes time, high cost, requires expertise.

Cloud way:
- Create an account
- Click "Create Server"
- Choose server size
- Pay per hour or usage
- Scale up or down anytime, as per requirement

Result: fast, flexible, beginner-friendly.

**Real-time example:** Think of on-premises like buying your own car — you pay for it fully, you maintain it, you fix it when it breaks down, and if you need a bigger car for a family trip, you have to buy a new one. Cloud is like using Ola/Uber — you just book what you need, when you need it, pay only for that ride, and if you need a bigger car tomorrow, you simply book a different one. No maintenance headache for you.

---

## 2. Key benefits of Cloud (why it's so popular)

- No hardware to buy
- Pay only for what you use (on-demand)
- Easy to scale resources up or down
- High availability
- High scalability
- Faster to start
- Global access from anywhere

## 3. When is on-premises still used?

Some companies still prefer on-premises when:
- Strict data security laws exist (banking, government, defence)
- Internet is not reliable in their location
- Legacy systems are in use, which are hard to move
- Full control over systems is required

**Real-time example:** A bank handling sensitive customer data, or a defence organization, may still keep critical systems on-premises because of compliance/legal requirements — even though cloud is cheaper and faster, some rules simply don't allow it.

---

## 4. Why Linux? Why not Windows?

**Simple answer:** Cloud runs mostly on Linux, not Windows.

Why Linux?
- Free (open source)
- Stable — runs for years without needing a restart
- Lightweight
- Secure & reliable
- Highly customizable
- Perfect for servers

Why not Windows (for servers)?
- Windows is mainly designed for desktop users
- Heavier OS (uses more resources)
- Paid license
- Less suitable for large-scale servers

**Linux vs Windows:**

| Feature | Linux | Windows |
|---|---|---|
| Cost | Free (open-source) | Paid license |
| Performance | Fast & lightweight | Heavy |
| Stability | Runs for years | Needs restarts |
| Security | Very secure | More virus-prone |
| Automation | Excellent (CLI-based) | Limited |
| Server usage | Very high | Less |
| Cloud support | Default choice | Secondary |

**Real-time example:** Your personal laptop at home probably runs Windows, because you want a nice graphical interface for browsing, gaming, MS Office, etc. But the servers running Instagram, Amazon, Google — behind the scenes — are almost all running Linux, because nobody is sitting there clicking icons; everything is automated through commands and scripts, and Linux is built exactly for that.

---

## 5. UNIX vs Linux — where did Linux come from?

**UNIX (the original):**
- Old operating system, created in the 1970s
- Expensive, proprietary
- Mostly used in big enterprises
- Examples: AIX, Solaris, HP-UX

**Linux (inspired by UNIX):**
- Open-source and free
- Created in 1991 by Linus Torvalds
- Community-driven — thousands of developers contribute to it
- Runs everywhere: cloud, mobile, servers

| UNIX | Linux |
|---|---|
| Proprietary | Open-source |
| Paid | Free |
| Limited vendors | Huge community |
| Less flexible | Highly customizable |
| Legacy systems | Used everywhere today |

**Real-time example:** Think of UNIX like an old, expensive, single-brand phone with a locked-in ecosystem — only a few companies could use/modify it. Linux is like Android — free, open, and thousands of companies/developers built their own versions (distributions) on top of it, which is why it spread so widely.

### Few important facts to remember

- Android (your mobile phone OS) is based on Linux
- AWS runs mostly on Linux
- Google runs on Linux
- Facebook runs on Linux
- Around 90% of internet servers run Linux
- Linux is the backbone of Cloud

### Major Linux distribution families

- **RHEL** (Red Hat Enterprise Linux) — used heavily in enterprises
- **Ubuntu** — very popular, beginner-friendly
- **Amazon Linux** — AWS's own distribution, optimized for EC2
- **Debian** — stable, community-driven, Ubuntu is actually built on top of Debian

**Real-time example:** These "distributions" (distros) are like different brands of car built on the same basic engine concept — RHEL is like the enterprise-grade car with paid support, Ubuntu is like the popular everyday car most people learn to drive on, Amazon Linux is the car specifically tuned to run best on Amazon's own roads (AWS), and Debian is the reliable, no-frills base model that others are built from.

---

## 6. AWS Free Tier — how to practice AWS without worrying about billing

AWS Free Tier allows new users to try AWS services without paying immediately. It is mainly used for learning AWS, practicing, running small experiments, and getting started as a cloud beginner.

**Current usage model (for new accounts):**
- AWS offers a Free Plan with credits
- You can get up to $200 in AWS credits — $100 at signup, and up to $100 more by completing learning activities
- Valid for 6 months, OR until credits are used, whichever comes first
- No charges unless you upgrade to a Paid Plan

**Is it free for 1 year or 6 months?**
- Older AWS accounts (created earlier) had 12 months of Free Tier for many services
- New AWS accounts mostly follow the 6-month Free Plan with credits
- Note: AWS's model may change over time — always check the current usage limits in the AWS console

**Always-free services (no expiry, but with limits):**
Some services stay free every month within certain limits, even after your signup credits end:
- AWS Lambda — 1 million free requests per month
- Amazon S3 — limited free storage
- Amazon DynamoDB — free storage and read/write capacity (usage limits apply)

**Important points to remember:**
- A credit card is required to create an AWS account
- AWS follows a pay-as-you-use model
- If you exceed free limits → you will be charged
- Always monitor your billing dashboard

**Real-time example:** Think of AWS Free Tier like a free trial on a mobile app — you get a good chunk of features for free for a limited time, but the moment you cross that limit or that time period ends, real charges kick in. That is exactly why, even during practice, we keep checking the AWS Billing Dashboard — same as checking your mobile data usage so you don't get an unexpected bill.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time analogy |
|---|---|---|
| On-Premises | You own and manage your own servers | Buying and maintaining your own car |
| Cloud | Renting someone else's servers over the internet | Booking an Ola/Uber whenever needed |
| Why Linux | Free, stable, lightweight — built for servers | Android vs a locked proprietary phone |
| UNIX vs Linux | Paid/proprietary vs free/open-source | Old locked phone vs open Android |
| Linux distros | Different flavors built on the Linux core | Different car brands, same base engine |
| AWS Free Tier | Free credits/services to practice AWS safely | A mobile app's free trial period |

That's it for today, friends — no commands to practice yet, but this "why" is what makes tomorrow's "how" make sense. From tomorrow, we start typing on real Linux servers.
