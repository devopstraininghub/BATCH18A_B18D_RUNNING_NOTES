# Batch 18 — AWS Cloud Running Notes: 9 September 2026

**Topic: VPC (Virtual Private Cloud), Subnets, Route Tables, Internet Gateway, CIDR, Public vs Private Subnets, VPC Peering, Elastic IP, Network ACLs**

Friends, today is AWS networking day. We build a **VPC** — your own private, isolated network inside AWS — and everything that goes with it: subnets, route tables, the Internet Gateway, and CIDR (how IP address ranges are sized). Then three practical extras: connecting two VPCs together (**VPC Peering**), giving a server a fixed public IP (**Elastic IP**), and an extra, subnet-level firewall (**NACLs**).

---

## 1. What is a VPC?

- **VPC** = **V**irtual **P**rivate **C**loud.
- Your own private, isolated network inside AWS.
- You fully control:
  - IP address ranges.
  - Subnets.
  - Routing.
  - Firewalls (Security Groups + NACLs).

**Simple meaning:** think of a VPC as your own private data center, built inside AWS.

---

## 2. VPC components — quick overview

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

We'll go deep on Subnets, Route Tables, IGW, CIDR, VPC Peering, Elastic IP, and NACLs today.

---

## 3. Subnets — public vs private

- A **subnet** is a smaller network segment inside a VPC.
- **Public subnet** — has a route to the internet (via the IGW). Used for things like an ALB, or a "jump server" (bastion host).
- **Private subnet** — has **no** direct route to the internet. Used for things like application EC2 instances and databases.

**Easy memory trick:** Public subnet → faces the internet. Private subnet → hidden behind it.

---

## 4. Internet Gateway (IGW)

- An **IGW** lets instances in your VPC reach the internet — and be reached from it.
- Without an IGW, **nothing** inside the VPC can access the internet.
- Only **public** subnets actually use the IGW (via their route table).

---

## 5. Route Tables

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

## 6. CIDR — how IP ranges are sized

- An IPv4 address like `10.81.0.0` is 4 numbers ("octets"), each 1 byte (8 bits) — 32 bits total.
- **CIDR notation** (e.g. `/16`, `/24`) tells you how many of those 32 bits are "fixed," and how many are free to vary — which decides how many addresses you get.

| CIDR | Bits free | Addresses | Typical use |
|---|---|---|---|
| `/16` (e.g. `10.81.0.0/16`) | 16 | 65,536 | The whole VPC |
| `/24` (e.g. `10.81.1.0/24`) | 8 | 256 (≈251 usable — AWS reserves a few) | One subnet |

**Simple meaning:** a `/16` VPC is one big pool of ~65k addresses; each `/24` subnet inside it carves out a smaller slice of 256 addresses from that pool.

**Real-time example:** `10.81.0.0/16` for the whole VPC, then `10.81.1.0/24` for a public subnet in AZ-a, `10.81.2.0/24` for a private subnet in the same AZ, `10.81.3.0/24` for a public subnet in AZ-b, and so on — each subnet gets its own non-overlapping `/24` slice out of the VPC's `/16` range.

---

## 7. How to set up a VPC

1. **Create the VPC** — e.g. CIDR `10.81.0.0/16`.
2. **Create subnets** — one public + one private per Availability Zone, e.g. `10.81.1.0/24` (public), `10.81.2.0/24` (private).
3. **Create an Internet Gateway** and attach it to the VPC.
4. **Create route tables** — a public one (`0.0.0.0/0` → IGW) and a private one (no internet route).
5. **Associate subnets with route tables** — public subnets → public route table, private subnets → private route table.
6. *(Optional)* Add a **NAT Gateway** so private subnets can still make outbound internet calls (updates, package installs) without being reachable from outside.
7. Add Security Groups/NACLs, then launch EC2 instances into the correct subnets.

---

## 8. Launching instances in public vs private subnets, and reaching a private one

- **Public instance:** launch normally, choose the VPC and the **public** subnet, and allow SSH (port 22) plus whatever app port you need in the Security Group. It's directly reachable from the internet.
- **Private instance:** same, but choose the **private** subnet. It has no route to the internet, so you can't SSH into it directly from your laptop.

**Reaching a private instance — the "jump server" pattern:**
1. Copy your `.pem` key onto the **public** instance.
2. On the public instance: `chmod 400 yourkey.pem`.
3. From the public instance, SSH into the private instance using its **private** IP: `ssh -i "yourkey.pem" ec2-user@<private-instance-private-ip>`.

**Real-time example:** This is exactly how production databases stay locked away from the internet in real companies — nobody SSHes directly into the database server; they hop through a public "jump server" (bastion host) first, using the database's private IP.

**Easy memory trick:** Public instance → your front door. Private instance → reachable only by hopping through the front door first.

---

## 9. VPC Peering

- **VPC Peering** connects two VPCs (same or different Regions, same or different AWS accounts) over a direct, private network route.
- Lets instances in both VPCs talk to each other using **private IP addresses**.

**Prerequisites:**
- The two VPCs' CIDR blocks must **not overlap**.

**Steps to create it:**
1. VPC dashboard → "Peering Connections" → "Create Peering Connection."
2. Name it, and select the VPC to peer with.
3. The **owner of the other VPC** must accept the peering request.
4. Update **both** VPCs' route tables so traffic actually knows to flow to the other VPC.
5. Adjust Security Groups/NACLs on both sides to allow the necessary traffic.

**Key things to remember:**
- **Not transitive** — if VPC A is peered with B, and B is peered with C, A and C are **not** automatically connected.
- No public IPs or NAT Gateway needed — traffic stays entirely on the AWS network, which is also cheaper.

**Real-time example:** A company's "Shared Services" VPC (holding logging/monitoring tools) gets peered with each application team's own VPC, so every team can send data to the shared tools over private IPs, without exposing anything to the public internet.

---

## 10. Elastic IP (EIP)

- An **Elastic IP** is a static (fixed) public IPv4 address, tied to your **AWS account**, not to any one instance.
- Once allocated, it stays yours until you explicitly release it.

**Why it matters:** normally, if you stop and start an EC2 instance, its public IP can **change**. Attaching an Elastic IP means the instance keeps the **same** public IP even after a stop/start.

**Steps:**
1. EC2 console → "Elastic IPs" → "Allocate Elastic IP address."
2. Select it → "Actions" → "Associate Elastic IP address" → choose the instance.

⚠️ **Billing caution:** AWS charges a small fee for an Elastic IP that is **allocated but not attached** to a running instance — always release ones you're not using.

**Easy memory trick:** Elastic IP → a phone number that stays yours, even if you switch phones.

---

## 11. Network ACLs (NACLs)

- A **NACL** is a firewall at the **subnet** level (Security Groups are at the **instance** level).
- **Stateless** — unlike a Security Group, a NACL doesn't automatically allow the return traffic of something it let in; you need a matching rule on the outbound side too.
- Rules are **numbered** (100 to 32766); AWS checks them in ascending order and applies the **first** rule that matches — lower numbers win.
- Every VPC has a **default NACL** that allows all traffic; every subnet must be associated with a NACL — if you don't pick one, it uses the default.

**Steps to create a custom NACL:**
1. VPC dashboard → "Network ACLs" → "Create network ACL" → name it, pick the VPC.
2. Add inbound/outbound rules — rule number, Allow/Deny, protocol, port range, source/destination.
3. "Subnet Associations" → associate it with the subnets you want it to protect.

**Real-time example:** Using a NACL to explicitly block a specific IP range at the subnet level, as an extra layer of defense on top of Security Groups — even if someone misconfigures a Security Group rule, the NACL still blocks that traffic before it reaches any instance.

**Easy memory trick:** Security Group → guards one instance, remembers the conversation. NACL → guards the whole subnet, checks every single packet fresh.

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
| VPC Peering | Connects two VPCs over private IPs | A shared-services VPC reachable by every app team's VPC |
| Elastic IP | A fixed public IP tied to your account | A server keeping the same IP even after a stop/start |
| NACL | Stateless, subnet-level firewall | An extra layer of defense on top of Security Groups |
