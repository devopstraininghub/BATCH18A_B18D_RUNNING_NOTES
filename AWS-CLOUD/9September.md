# Batch 18 — AWS Cloud Running Notes: 9 September 2026

**Topic: VPC (Virtual Private Cloud), Subnets, Route Tables, Internet Gateway, CIDR, Public vs Private Subnets**

Friends, today is AWS networking day. We build a **VPC** — your own private, isolated network inside AWS — and everything that goes with it: subnets, route tables, the Internet Gateway, and CIDR (how IP address ranges are sized), finishing with how to launch instances into public and private subnets correctly.

---

## 1. From physical servers to VPC — the big picture

Before jumping into VPC itself, it helps to see where it fits in the bigger evolution of "where does my server actually live":

- **Physical server** — a real hardware machine. CPU, RAM, storage installed directly. Runs one operating system. Limited scalability, expensive to maintain, and often leads to poor resource utilization (a lot of unused capacity sitting idle).
- **VMware (virtualization)** — virtualization software lets **multiple virtual machines** run on **one** physical server, each with its own OS and apps. Much better resource usage than a physical server — but you (or your company) still manage all of it yourself, on-premises.
- **Cloud** — servers made available over the internet. You don't manage the hardware at all; the cloud provider does. You pay only for what you use, and it scales, is reliable, and is available globally.

**Public Cloud vs Private Cloud vs VPC:**
- **Public Cloud** — owned by a provider (AWS, Azure, GCP). You rent servers from them, on shared infrastructure with isolation between customers. The most common, cost-effective option.
- **Private Cloud** — cloud infrastructure dedicated to **one** organization only, usually hosted in their own data center. More control and security, but more cost.
- **VPC (Virtual Private Cloud)** — your **own private network carved out inside** a public cloud. You get the cost-effectiveness of public cloud, but with your own isolated section of it — like having your own private data center inside AWS.

**Simple summary:**
```
Physical Server         → One big hardware machine
VMware Virtualization   → Many VMs on one physical server
Cloud                   → Servers delivered over the internet
Public Cloud            → Shared platform for everyone
Private Cloud           → Cloud dedicated to one company
VPC                     → Your private network inside a public cloud
```

**Easy memory trick:** each step trades away a little control for a lot less hassle — until VPC hands some of that control back, without giving up the cloud's convenience.

---

## 2. What is a VPC?

- **VPC** = **V**irtual **P**rivate **C**loud.
- Your own private, isolated network inside AWS.
- You fully control:
  - IP address ranges.
  - Subnets.
  - Routing.
  - Firewalls (Security Groups + NACLs).

**Simple meaning:** think of a VPC as your own private data center, built inside AWS.

---

## 3. VPC components — quick overview

| Component | What it does |
|---|---|
| **Subnet** | A smaller network segment inside the VPC, tied to one Availability Zone |
| **Route Table** | Decides where each subnet's traffic is allowed to go |
| **Internet Gateway (IGW)** | Lets a VPC's public subnets reach the internet |
| **NAT Gateway** | Lets a **private** subnet reach the internet outbound, without allowing inbound |
| **Security Groups & NACLs** | Firewalls — Security Groups at the instance level, NACLs at the subnet level |
| **VPC Peering** | Connects two VPCs so they can talk over private IPs |
| **VPN / Direct Connect** | A secure link between your own data center and your VPC |
| **VPC Endpoints** | Reach an AWS service privately, without going through the internet at all |
| **Flow Logs** | Records of the IP traffic in/out of your VPC — used for troubleshooting and security |

We'll go deep on Subnets, Route Tables, IGW, and CIDR today — VPC Peering, NACLs, and the rest come in a later session.

---

## 4. Subnets — public vs private

- A **subnet** is a smaller network segment inside a VPC.
- **Public subnet** — has a route to the internet (via the IGW). Used for things like an ALB, or a "jump server" (bastion host).
- **Private subnet** — has **no** direct route to the internet. Used for things like application EC2 instances and databases.

**Easy memory trick:** Public subnet → faces the internet. Private subnet → hidden behind it.

---

## 5. Internet Gateway (IGW)

- An **IGW** lets instances in your VPC reach the internet — and be reached from it.
- Without an IGW, **nothing** inside the VPC can access the internet.
- Only **public** subnets actually use the IGW (via their route table).

---

## 6. Route Tables

- A **Route Table** decides where a subnet's network traffic is allowed to go.
- Every subnet must be associated with one route table.

**Example routes:**
```
10.0.0.0/16 → local     (traffic staying inside the VPC)
0.0.0.0/0   → igw-id    (all other traffic → out to the internet, via the IGW)
```

| | Public subnet's route table | Private subnet's route table |
|---|---|---|
| Has `0.0.0.0/0` → IGW? | Yes | No |
| Internet access? | Yes, directly | No (only via a NAT Gateway, if added) |

---

## 7. CIDR — how IP ranges are sized

- An IPv4 address like `10.81.0.0` is 4 numbers ("octets"), each 1 byte (8 bits) — 32 bits total.
- **CIDR notation** (e.g. `/16`, `/24`) tells you how many of those 32 bits are "fixed," and how many are free to vary — which decides how many addresses you get.

| CIDR | Bits free | Addresses | Typical use |
|---|---|---|---|
| `/16` (e.g. `10.81.0.0/16`) | 16 | 65,536 | The whole VPC |
| `/24` (e.g. `10.81.1.0/24`) | 8 | 256 (≈251 usable — AWS reserves a few) | One subnet |

**Simple meaning:** a `/16` VPC is one big pool of ~65k addresses; each `/24` subnet inside it carves out a smaller slice of 256 addresses from that pool.

**Real-time example:** `10.81.0.0/16` for the whole VPC, then `10.81.1.0/24` for a public subnet in AZ-a, `10.81.2.0/24` for a private subnet in the same AZ, `10.81.3.0/24` for a public subnet in AZ-b, and so on — each subnet gets its own non-overlapping `/24` slice out of the VPC's `/16` range.

---

## 8. How to set up a VPC

1. **Create the VPC** — e.g. CIDR `10.81.0.0/16`.
2. **Create subnets** — one public + one private per Availability Zone, e.g. `10.81.1.0/24` (public), `10.81.2.0/24` (private).
3. **Create an Internet Gateway** and attach it to the VPC.
4. **Create route tables** — a public one (`0.0.0.0/0` → IGW) and a private one (no internet route).
5. **Associate subnets with route tables** — public subnets → public route table, private subnets → private route table.
6. *(Optional)* Add a **NAT Gateway** so private subnets can still make outbound internet calls (updates, package installs) without being reachable from outside.
7. Add Security Groups/NACLs, then launch EC2 instances into the correct subnets.

---

## 9. Launching instances in public vs private subnets, and reaching a private one

- **Public instance:** launch normally, choose the VPC and the **public** subnet, and allow SSH (port 22) plus whatever app port you need in the Security Group. It's directly reachable from the internet.
- **Private instance:** same, but choose the **private** subnet. It has no route to the internet, so you can't SSH into it directly from your laptop.

**Reaching a private instance — the "jump server" pattern:**
1. Copy your `.pem` key onto the **public** instance.
2. On the public instance: `chmod 400 yourkey.pem`.
3. From the public instance, SSH into the private instance using its **private** IP: `ssh -i "yourkey.pem" ec2-user@<private-instance-private-ip>`.

**Real-time example:** This is exactly how production databases stay locked away from the internet in real companies — nobody SSHes directly into the database server; they hop through a public "jump server" (bastion host) first, using the database's private IP.

**Easy memory trick:** Public instance → your front door. Private instance → reachable only by hopping through the front door first.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| VPC | Your own private, isolated network in AWS | Every real AWS setup starts by creating one |
| Public / Private subnet | Faces the internet / hidden behind it | ALB in public subnet, database in private subnet |
| Internet Gateway (IGW) | Lets a VPC reach the internet | Attached to the VPC, used only by public subnets |
| Route Table | Decides where a subnet's traffic goes | `0.0.0.0/0 → IGW` on the public route table |
| CIDR (`/16`, `/24`) | Decides how many IPs a VPC/subnet gets | `/16` VPC (65k IPs) split into `/24` subnets (256 IPs each) |
| Jump server / bastion pattern | SSH into a private instance via a public one | Keeping a production database off the public internet |
