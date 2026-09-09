# Batch 18 — AWS Cloud Running Notes: 9 September 2026

**Topic: VPC (Virtual Private Cloud), Subnets, Route Tables, Internet Gateway, CIDR, Public vs Private Subnets**

Friends, today is AWS networking day. We build a **VPC** — your own private, isolated network inside AWS — and everything that goes with it: subnets, route tables, the Internet Gateway, and CIDR (how IP address ranges are sized), finishing with how to launch instances into public and private subnets correctly.

---

## 1. From physical servers to VPC — the big picture

Before jumping into VPC itself, it helps to see where it fits in the bigger evolution of "where does my server actually live":

**Physical Server**
- A real hardware machine sitting in an office or data center.
- CPU, RAM, storage installed directly on it.
- Runs only one operating system.
- Limited scalability, expensive to maintain.
- Leads to low resource utilization — a server bought for peak load sits mostly idle on normal days.

**VMware (Virtualization)**
- Virtualization software lets multiple Virtual Machines (VMs) run on one physical server.
- Each VM has its own OS and applications.
- Better resource usage than a plain physical server.
- Still managed by you — this is on-premise virtualization, not cloud.

**Cloud**
- Servers made available over the internet.
- The cloud provider manages the hardware, not you.
- You pay only for what you use.
- Scalable, reliable, available globally.

**Easy memory trick:** Physical server = one machine, one job. Virtualization = one machine, many jobs. Cloud = someone else's machine, on demand.

**Public Cloud**
- Cloud owned by a provider — AWS, Azure, GCP.
- You rent servers from them.
- Shared infrastructure, with isolation between customers.
- The most common, cost-effective option.

**Private Cloud**
- Cloud infrastructure dedicated to one organization only.
- Hosted in your own data center or a fully isolated environment.
- More control, more security, more cost.

**VPC (Virtual Private Cloud)**
- Your own private network, carved out **inside** the public cloud.
- Your own isolated section of AWS.
- You control IP ranges, subnets, routing, Security Groups, and NACLs (firewalls).

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

**Why only 251 usable, not 256, in a `/24`:** AWS reserves 5 IP addresses in every subnet:
- The network address (the very first IP).
- The VPC router.
- The DNS server.
- One reserved for future AWS use.
- The broadcast address (the very last IP).

| CIDR | Bits free | Total addresses | Usable (AWS reserves 5) | Typical use |
|---|---|---|---|---|
| `/16` (e.g. `10.81.0.0/16`) | 16 | 65,536 | 65,531 | The whole VPC |
| `/24` (e.g. `10.81.1.0/24`) | 8 | 256 | 251 | One subnet |

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

## 9. Hands-on lab — creating a VPC in the AWS Console

1. AWS Console → **Services → VPC**.
2. **Your VPCs → Create VPC.**
3. Choose **VPC only**.
4. IPv4 CIDR block: `10.81.0.0/16`. Name tag: `Batch18-VPC`.
5. Click **Create VPC.**
6. **Subnets → Create Subnet**, select the VPC.
7. Create `10.81.1.0/24` in AZ-a (this will be the **public** subnet).
8. Create `10.81.2.0/24` in AZ-b (this will be the **private** subnet).
9. **Internet Gateways → Create Internet Gateway** → name it → attach it to the VPC.
10. **Route Tables → Create Route Table**, for the public subnet.
11. Edit routes → add `0.0.0.0/0` → target = the Internet Gateway.
12. **Subnet Associations** → associate this route table with the public subnet.
13. Leave the private subnet on the default route table (no IGW route).
14. Launch an EC2 instance into the **public** subnet, with **Auto-assign Public IP** enabled.
15. Launch a second EC2 instance into the **private** subnet, with no public IP.

**Verifying the public instance is reachable:**
```
$ ping <public-ip-of-instance>
Reply from <public-ip>: bytes=32 time=45ms TTL=118
```

**Verifying the private instance has no public IP:**
```
Instance ID: i-0b2c3d4e5f6a
Public IPv4 address: -
Private IPv4 address: 10.81.2.15
```
No public IP at all — exactly what we expect from a private subnet, and exactly why it can't be reached directly.

---

## 10. Reaching the private instance — the jump server pattern

The private instance from the lab above has no public IP, so it can't be SSHed into directly from your laptop.

**Reaching a private instance — the "jump server" pattern:**
1. Copy your `.pem` key onto the **public** instance.
2. On the public instance: `chmod 400 yourkey.pem`.
3. From the public instance, SSH into the private instance using its **private** IP: `ssh -i "yourkey.pem" ec2-user@<private-instance-private-ip>`.

**Real-time example:** This is exactly how production databases stay locked away from the internet in real companies — nobody SSHes directly into the database server; they hop through a public "jump server" (bastion host) first, using the database's private IP.

**Easy memory trick:** Public instance → your front door. Private instance → reachable only by hopping through the front door first.

---

## 11. Real-world VPC architecture example

```
VPC: 10.81.0.0/16

Public Subnet (10.81.1.0/24) — AZ-a
  - ALB
  - Bastion/Jump Server
  - Route Table: 0.0.0.0/0 -> IGW

Private Subnet (10.81.2.0/24) — AZ-a
  - Application EC2 servers
  - Route Table: 0.0.0.0/0 -> NAT Gateway (outbound only)

Private Subnet (10.81.3.0/24) — AZ-b
  - Database (RDS)
  - Route Table: no internet route
```

- **Public subnet:** only the ALB and bastion host live here — the only things that must be reachable from the internet.
- **Private subnet (app tier):** takes traffic only from the ALB, reaches the internet only outbound via the NAT Gateway, for OS patching.
- **Private subnet (DB tier):** no internet route at all, reachable only from the app servers.

**Easy memory trick:** the closer to the internet, the less should live there — public subnet gets only a front door and a load balancer, everything valuable sits behind it.

---

## 12. Real DevOps use cases

- Designing a 3-tier architecture: public web tier, private app tier, private DB tier.
- Using a bastion host in the public subnet as the **only** SSH entry point into private servers.
- Using a NAT Gateway so private servers get outbound updates, without any inbound exposure.
- Planning CIDR ranges in advance so multiple VPCs (Dev, Test, Prod) never overlap — required later for VPC Peering or a VPN connection.
- Isolating a database completely from the internet, reachable only from app servers via Security Groups.
- Combining multiple AZs' subnets with an ALB and an Auto Scaling Group for high availability.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| VPC | Your own private, isolated network in AWS | Every real AWS setup starts by creating one |
| Public / Private subnet | Faces the internet / hidden behind it | ALB in public subnet, database in private subnet |
| Internet Gateway (IGW) | Lets a VPC reach the internet | Attached to the VPC, used only by public subnets |
| Route Table | Decides where a subnet's traffic goes | `0.0.0.0/0 → IGW` on the public route table |
| NAT Gateway | Outbound-only internet access for private subnets | App servers download OS patches without being exposed |
| CIDR (`/16`, `/24`) | Decides how many IPs a VPC/subnet gets | `/16` VPC (65,531 usable) split into `/24` subnets (251 usable each) |
| Jump server / bastion pattern | SSH into a private instance via a public one | Keeping a production database off the public internet |
| 3-tier VPC architecture | Public tier → private app tier → private DB tier | Real production layout for a real web application |
