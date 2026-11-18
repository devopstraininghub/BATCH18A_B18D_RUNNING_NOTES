# Batch 18 — AWS Cloud Running Notes: 30 September 2026

**Topic: Cloud Service Models — On-Premises, IaaS, PaaS, SaaS**

Friends, we've spent the last several weeks building out real AWS infrastructure — EC2, RDS, Route 53, ACM, CloudFront. Today we step back and answer a more fundamental question: **why does any of this look the way it does?** Cloud service models are the framework that explains who owns what, who manages what, and how much control vs. how much convenience you're trading away at each layer — the same question every architecture decision in this course has secretly been answering all along.

---

## 1. What are cloud models?

Cloud models answer four questions about any piece of infrastructure:
- Who **owns** it?
- Who **manages** it?
- How much **control** does the customer have?
- How much **responsibility** does the customer have?

**The four models to know:**
```
1. On-Premises
2. IaaS  — Infrastructure as a Service
3. PaaS  — Platform as a Service
4. SaaS  — Software as a Service
```

**Easy memory trick:** `On-Premises = Own everything`, `IaaS = Rent infrastructure`, `PaaS = Rent platform`, `SaaS = Use software`.

---

## 2. On-Premises

- The company owns and manages its **entire** IT infrastructure, in its own data center or facility — servers, storage, network switches, routers, firewalls, the building itself, the operating systems, and the applications.

```
COMPANY → Data Center → Server / Storage / Network → Application
```
The company is responsible for **almost everything**.

**Real-time example — a bank with its own data center:**
- The bank **owns**: physical servers, storage systems, network equipment, firewalls, load balancers, databases, operating systems.
- The bank's IT team **manages**: hardware, OS, network, security, patching, backups, monitoring, power, cooling, physical security, and the applications themselves.
```
Physical Server → Linux OS → Database → Application
```
Everything here is controlled by the organization, end to end.

**Advantages:** maximum control, full hardware/network control, fully custom infrastructure, can satisfy special regulatory requirements, works well for legacy applications, data stays entirely within company-controlled facilities.

**Disadvantages:** high initial cost, hardware must be purchased upfront, the data center itself must be maintained, hardware failures are your problem, power/cooling/physical security all required, scaling takes real time (hardware procurement alone can take weeks or months), the IT team must manage all of it, and disaster recovery can get expensive.

**Easy memory trick:** `On-Premises = BUY + BUILD + MANAGE`.

**DevOps example — standing up Jenkins on-premises:**
```
Buy physical server → Install OS → Install Java → Install Jenkins →
Configure Jenkins → Configure backup → Monitor server
```
The company owns the complete stack, top to bottom.

---

## 3. IaaS (Infrastructure as a Service)

- Instead of buying physical servers, you **rent virtual infrastructure** from a cloud provider.
- **Provider gives you:** compute, storage, networking, virtual machines, the physical infrastructure underneath all of it.
- **You still manage:** the operating system, runtime, middleware, the application, its configuration, and the data.

**Simple definition:** `IaaS = cloud infrastructure that you manage from the OS level upward.`

**Example — AWS EC2:**
```
AWS → EC2 → Linux → Java → Jenkins → Application
```
AWS manages the underlying physical infrastructure; **you** manage the OS and everything running on top of it.

**When to use IaaS:** you need high control, OS-level access, custom software, custom networking or security configuration, a custom runtime, or you're supporting a legacy application. The test question: *"I need a Linux server where I can install specific packages and configure the OS myself"* → IaaS fits.

**Advantages:** high control, flexible, OS-level access, custom configuration, fast provisioning, easier to scale than physical infrastructure, no upfront hardware purchase.

**Disadvantages:** you still manage the OS, patching, runtime, application, configuration, security, monitoring, and backups yourself.

**Easy concept:** IaaS gives you the infrastructure — but you still manage the operating system.

---

## 4. PaaS (Platform as a Service)

- A **managed platform** for deploying applications — the provider manages most of the infrastructure, OS, and runtime for you.
- **You mainly manage:** your application code, its configuration, and the data.

**Simple definition:** `PaaS = deploy your application without managing the underlying servers directly.`

**Example — AWS Elastic Beanstalk:**
```
Developer → provides Code → PaaS (manages infra/OS/runtime/deployment/scaling) → Application
```

**When to use PaaS:** developers should focus purely on application code, infrastructure management should be minimized, fast deployment matters, your app fits a supported runtime, and you don't need OS-level control. The test question: *"I have a Python application and don't want to manage Linux servers"* → PaaS fits.

**Advantages:** less infrastructure management, faster deployment, developers focus on code, platform handles most infra concerns, scaling is often simpler, less OS maintenance.

**Disadvantages:** less control than IaaS, platform restrictions, runtime limitations, possible vendor lock-in, not suitable for every application, limited OS-level customization.

---

## 5. SaaS (Software as a Service)

- **Ready-to-use software** delivered over the Internet — you don't manage servers, OS, runtime, or deployment at all.
- **You mainly manage:** your account, users, configuration, data, and access.

**Simple definition:** `SaaS = ready-to-use software.`

**Examples:** Gmail, Microsoft 365, Salesforce, Slack, Zoom, Dropbox.

**Example — Gmail:** you simply *use* Gmail. You don't manage mail servers, operating systems, storage infrastructure, or application servers — Google manages the entire underlying service.

**When to use SaaS:** the software you need already exists, and you'd rather not build or host it yourself.
```
Need email?          Gmail / Microsoft 365
Need CRM?             Salesforce
Need collaboration?   Slack
Need video meetings?  Zoom
```

**Advantages:** ready to use immediately, no server/OS/deployment management, fast adoption, the provider handles maintenance and upgrades for you.

**Disadvantages:** less customization, less infrastructure control, vendor dependency, ongoing subscription cost, integration limitations, and data/privacy considerations you don't fully control.

---

## 6. Who manages what — the responsibility ladder

Think of a full application stack as ten layers: **Application, Data, Runtime, Middleware, Operating System, Virtualization, Servers, Storage, Networking, Physical Facility.** Each model draws the line between "provider manages" and "you manage" at a different point in that stack.

| Layer | On-Premises | IaaS | PaaS | SaaS |
|---|---|---|---|---|
| Application | **You** | **You** | **You** | Provider |
| Data | **You** | **You** | **You** | You (config/data only) |
| Runtime / Middleware | **You** | **You** | Provider | Provider |
| Operating System | **You** | **You** | Provider | Provider |
| Virtualization / Servers | **You** | Provider | Provider | Provider |
| Storage / Networking | **You** | Provider | Provider | Provider |
| Physical Facility | **You** | Provider | Provider | Provider |

**In one line per model:**
- **On-Premises** — the customer manages almost everything.
- **IaaS** — the provider manages physical infrastructure; the customer manages OS and everything above it.
- **PaaS** — the provider manages infrastructure *and* the platform (OS/runtime); the customer mainly manages the application and its data.
- **SaaS** — the provider manages almost everything; the customer mainly configures and uses the application.

**Customer responsibility, visually:**
```
ON-PREMISES → IaaS → PaaS → SaaS
   (more customer responsibility)  →  (less customer responsibility)
   (more customer control)         →  (less customer control)
```

---

## 7. Simple comparison table

| Model | Customer manages | Example |
|---|---|---|
| On-Premises | Almost everything | Company data center |
| IaaS | OS + application | AWS EC2 |
| PaaS | Application only | AWS Elastic Beanstalk |
| SaaS | Usage/configuration only | Gmail / Salesforce |

---

## 8. An easy real-life analogy

Imagine you want a place to run a business:

- **On-Premises** — you build the entire building yourself. You manage the building, electricity, security, equipment — everything.
- **IaaS** — you rent an empty building. You manage what you install and run inside it.
- **PaaS** — you rent a ready workspace. The infrastructure around it is already managed for you.
- **SaaS** — you simply use a ready-made business service.

**Easy memory trick:** `On-Premises = Build everything`, `IaaS = Manage infrastructure`, `PaaS = Deploy application`, `SaaS = Use application`.

---

## 9. DevOps examples across all four models

**Getting Jenkins running:**

| Model | Path to Jenkins |
|---|---|
| On-Premises | Physical server → install Linux → install Java → install Jenkins |
| IaaS | EC2 → Linux → Java → Jenkins |
| PaaS | A managed application platform hosts it without you managing the underlying VM |
| SaaS | Use a hosted CI/CD service instead of running your own Jenkins at all |

**Running a web application:**

| Model | Path to the running app |
|---|---|
| On-Premises | Data center → physical servers → Linux → web server → application |
| IaaS | AWS EC2 → Linux → web server → application |
| PaaS | Application code → managed platform → application |
| SaaS | Use an existing application (e.g. Salesforce) instead of building your own |

---

## 10. Decision tree — which model fits?

```
Do we want to own and manage the infrastructure ourselves?
        │
    YES ─────────────► ON-PREMISES
        │
        NO
        ▼
Do we need OS-level control?
        │
    YES ─────────────► IaaS
        │
        NO
        ▼
Do we want to deploy our own application?
        │
    YES ─────────────► PaaS
        │
        NO
        ▼
       SaaS
```

**Easy version:** `Own it? → On-Premises.` `Control the OS? → IaaS.` `Deploy your own code? → PaaS.` `Just use it? → SaaS.`

**Worked examples using this tree:**
- "We need a custom Linux server" → **IaaS**
- "We have a Python app and want to deploy it without managing servers" → **PaaS**
- "We need employee email" → **SaaS**
- "We have specialized physical hardware that must stay in our own facility" → **On-Premises**

---

## 11. Cloud migration — and why it's not a fixed sequence

A company currently on-premises, moving to AWS, is **not** required to march through every model in order:
```
On-Premises → IaaS → PaaS → SaaS   (a possible path — NOT a mandatory one)
```
In practice, different applications in the **same company** often land on different models simultaneously:
```
Legacy application            → IaaS
Modern web application        → PaaS
Email                         → SaaS
Specialized hardware app      → stays On-Premises
```

---

## 12. Hybrid environments — mixing models

A company doesn't have to pick just one model — most real organizations run a mix:
```
On-Premises (legacy database)
        │
        ▼
       AWS
   ┌────┴────┐
  IaaS      PaaS
  (EC2)  (Application)
              │
              ▼
             SaaS
        (Collaboration tools)
```
This kind of blend — some legacy systems on-premises, some infrastructure on IaaS, an application on PaaS, and day-to-day tools on SaaS — is completely normal in enterprise environments, not an edge case.

---

## 13. Don't confuse this with deployment models

**Service Models** (what this whole file has been about): `IaaS`, `PaaS`, `SaaS` — these describe **how a service is delivered** and where the management line sits.

**Deployment Models** (a different axis entirely): `Public Cloud`, `Private Cloud`, `Hybrid Cloud` — these describe **who else's infrastructure you're sharing**, not who manages which layer.

- On-Premises is really an infrastructure-*ownership* concept, sitting outside both axes — it's the "you own the building" baseline that IaaS/PaaS/SaaS are all contrasted against.
- **Public Cloud vs On-Premises, concretely:** On-Premises = company owns the data center and physical servers. Public Cloud = the cloud provider owns the underlying infrastructure (e.g. `AWS → EC2`), and you rent capacity on it.

---

## 14. Pairwise comparisons — the quick mental shortcuts

**On-Premises vs IaaS:**
```
On-Premises: Buy a physical server (e.g. a Dell/HP/Lenovo box)
IaaS:        Rent a virtual server (e.g. AWS EC2)
```
Main difference: ownership and infrastructure management.

**IaaS vs PaaS:**
```
IaaS: "Give me infrastructure — I'll manage the OS and application myself."   (e.g. EC2)
PaaS: "Give me a platform — I mainly want to deploy my application."          (e.g. Elastic Beanstalk)
```

**PaaS vs SaaS:**
```
PaaS: You deploy your own code.
SaaS: You use someone else's already-built application.
```
**Easy memory trick:** `PaaS = MY CODE`, `SaaS = THEIR SOFTWARE`.

---

## 15. Real-time DevOps responsibility, per model

| Model | What a DevOps engineer actually spends time on |
|---|---|
| On-Premises | Hardware, OS, network, storage, applications, CI/CD, monitoring — the full stack |
| IaaS | EC2, OS, Docker, Jenkins, Kubernetes, applications, CI/CD |
| PaaS | Application deployment, CI/CD, configuration, monitoring, security |
| SaaS | Integration, APIs, automation, authentication, user access, configuration |

Notice the shift: as you move from On-Premises toward SaaS, the DevOps role moves away from "keeping infrastructure alive" and toward "integrating and automating around services someone else keeps alive."

---

## 16. Complete comparison — infrastructure, OS/platform, and application ownership

| Model | Infrastructure | OS / Platform | Application |
|---|---|---|---|
| On-Premises | Customer | Customer | Customer |
| IaaS | Provider | Customer | Customer |
| PaaS | Provider | Provider | Customer |
| SaaS | Provider | Provider | Provider |

Customer responsibility decreases steadily down this list: `On-Premises → IaaS → PaaS → SaaS`.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| On-Premises | You own and manage the entire stack | Company-owned data center, full IT team |
| IaaS | Rent infrastructure, manage OS + application yourself | AWS EC2 |
| PaaS | Rent a platform, deploy code, provider manages OS/runtime | AWS Elastic Beanstalk |
| SaaS | Use ready-made software, manage only config/usage | Gmail, Salesforce, Slack, Zoom |
| Responsibility ladder | Customer responsibility decreases On-Prem → IaaS → PaaS → SaaS | IaaS = OS+app; PaaS = app only; SaaS = usage only |
| Service Model vs Deployment Model | Two different axes — don't conflate them | IaaS/PaaS/SaaS (service) vs Public/Private/Hybrid Cloud (deployment) |
| Hybrid environment | Real companies mix models per-application, not company-wide | Legacy DB on-prem + EC2 (IaaS) + an app on PaaS + Slack (SaaS) |
| Decision test | "Own it / control OS / deploy code / just use it?" | Maps directly to On-Prem / IaaS / PaaS / SaaS |
