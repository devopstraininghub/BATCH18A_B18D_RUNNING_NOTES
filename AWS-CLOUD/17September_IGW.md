# Batch 18 — AWS Cloud Running Notes: 17 September 2026

**Topic: Internet Gateway (IGW) — a deeper look**

Friends, second file for today — a proper deep dive on the **Internet Gateway**, the component we've been using since our very first VPC session but hadn't fully unpacked. This also ties together everything from the last two weeks (Bastion, NAT Gateway, Security Group, NACL, ENI) into one complete picture.

---

## 1. What is an Internet Gateway?

- **IGW** = **I**nternet **G**ate**w**ay — an AWS networking component that provides a path between a **VPC** and the **internet**.

```
VPC → Internet Gateway → Internet
```

**Easy memory trick:** IGW = VPC to internet.

---

## 2. Why do we need an Internet Gateway?

- Without one, nothing in the VPC can reach the internet at all.

```
EC2 → Route Table → Internet Gateway → Internet
```

---

## 3. Internet Gateway is attached to the VPC, not an instance

- The IGW is attached to the **VPC as a whole**.
- It is **not** attached directly to any individual EC2 instance.

```
VPC
├── Internet Gateway
├── Public Subnet
└── Private Subnet
```

---

## 4. What actually makes a subnet "public"?

- A subnet is **public** when its route table has a route to the Internet Gateway, **and** its resources have appropriate public addressing (a public IP).

```
Public Subnet Route Table: 0.0.0.0/0 → Internet Gateway
```

**Easy memory trick:** Public subnet = route to IGW + appropriate public IP addressing. Missing either one, and it's not really "public."

---

## 5. Attaching an IGW does NOT automatically make an EC2 internet-accessible

⚠️ **Important interview point.**

Just attaching an Internet Gateway to a VPC does **not** automatically give every EC2 instance internet access. You also need:
1. The correct **route table** entry.
2. A **public IP** / appropriate public addressing on the instance.
3. **Security Group** rules allowing the traffic.
4. **Network ACL** rules allowing it, if applicable.

All four have to be correct together — missing any one of them, and the instance still can't be reached (or can't reach out).

---

## 6. Public subnet — full example

```
VPC:            10.0.0.0/16
Public Subnet:  10.0.1.0/24
EC2:            Private IP 10.0.1.10, Public IP 3.x.x.x

Route Table:
  10.0.0.0/16 → local
  0.0.0.0/0   → Internet Gateway

Flow: Internet → Internet Gateway → Public Subnet → EC2
```

---

## 7. Private subnet + Internet Gateway

- A private subnet (instances with no public IP) does **not** use the Internet Gateway directly for outbound access.
- Instead, the standard architecture is:

```
Private EC2 → NAT Gateway → Internet Gateway → Internet
```

| | Public EC2 | Private EC2 |
|---|---|---|
| Path to internet | `EC2 → IGW → Internet` | `EC2 → NAT Gateway → IGW → Internet` |

(Full NAT Gateway details are in `11September_NATGateway.md`.)

---

## 8. Internet Gateway vs NAT Gateway

| | Internet Gateway | NAT Gateway |
|---|---|---|
| Provides | The VPC's path to/from the internet, for public resources | Outbound-only internet for private subnet resources |

**Easy memory trick:** IGW = the internet connection itself. NAT = how a private subnet borrows that connection, outbound only.

---

## 9. Internet Gateway vs Bastion Host

| | Internet Gateway | Bastion Host |
|---|---|---|
| What it is | An AWS networking component | An EC2/server, used as an admin jump point |
| Provides | A path between VPC and internet | Controlled SSH access to private servers |

```
Internet → IGW → Bastion → Private EC2
```

**Easy memory trick:** IGW = the network path. Bastion = the admin jump server that uses that path.

---

## 10. Complete AWS architecture — everything together

```
                         INTERNET
                             │
                             ▼
                    INTERNET GATEWAY
                             │
              ┌──────────────┴──────────────┐
              ▼                             ▼
        PUBLIC SUBNET                 PUBLIC SUBNET
              │                             │
         BASTION HOST                  NAT GATEWAY
              │                             │
              ▼                             ▼
        PRIVATE SUBNET                PRIVATE SUBNET
              │                             │
         APPLICATION EC2                   EC2
              │
             ENI
              │
       SECURITY GROUP
              │
             NACL
```

**Admin access path:**
```
Admin Laptop → SSH → Internet Gateway → Bastion Host → (private IP) → Private EC2
```

**Private EC2 internet access path:**
```
Private EC2 → NAT Gateway → Internet Gateway → Internet
```

**What each component actually does:**

| Component | Purpose |
|---|---|
| Bastion Host | Admin access to private servers |
| Internet Gateway | VPC's connection to the internet |
| NAT Gateway | Private subnet's outbound internet access |
| Security Group | Resource/ENI-level traffic control |
| NACL | Subnet-level traffic control |
| ENI | The virtual network interface itself |

**Easy memory trick, all together:**
- Bastion → admin jump point.
- Internet Gateway → VPC ↔ internet.
- NAT Gateway → private subnet → internet.
- Security Group → resource/ENI firewall.
- NACL → subnet firewall.
- ENI → EC2's network card.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Internet Gateway (IGW) | VPC's path to/from the internet | Attached once per VPC, not per instance |
| Attached to VPC, not instance | One IGW serves the whole VPC | Every public subnet in the VPC can share the same IGW |
| Public subnet = route to IGW + public IP | Both conditions needed, not just one | A subnet with an IGW route but instances with no public IP still isn't reachable |
| IGW alone ≠ internet access | Route table + public IP + SG + NACL all required | The classic "I attached an IGW but still can't reach my EC2" bug |
| Private EC2 → NAT GW → IGW | Two hops, not a direct IGW route | How private subnets get outbound-only internet access |
| Full architecture (Bastion + IGW + NAT + SG + NACL + ENI) | Every layer works together | A real production VPC uses all of these at once, not just one |
