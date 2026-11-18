# Batch 18 — AWS Cloud Running Notes: 11 September 2026

**Topic: NAT Gateway**

Friends, last topic today — the **NAT Gateway**, which finally answers a question that's come up since our very first VPC session: how does a private subnet, with no public IP and no route to the Internet Gateway, still get outbound internet access for updates and downloads?

---

## 1. What is a NAT Gateway?

- **NAT** = **N**etwork **A**ddress **T**ranslation.
- A NAT Gateway lets resources in a **private subnet** initiate connections **out to the internet**.

```
Private EC2 → NAT Gateway → Internet
```

**Main purpose:** private subnet → outbound internet access.

---

## 2. Why do we need a NAT Gateway?

- A private EC2 instance (e.g. `10.0.2.10`) still needs to:
  - Download packages and OS updates.
  - Access external APIs.
  - Download software.
  - Reach other internet services.
- But we don't want to give it a **public IP** — that would expose it directly to the internet.

**Solution:**
```
Private EC2 (10.0.2.10) → NAT Gateway → Internet
```
Outbound access, with no inbound exposure.

---

## 3. Where is a NAT Gateway created?

⚠️ **Important:** a NAT Gateway is created in a **public** subnet, not the private one it's serving.

```
VPC
└── Public Subnet
     └── NAT Gateway → Internet Gateway → Internet
```
**Why:** the NAT Gateway itself needs a route to the internet, and only a public subnet has that.

---

## 4. NAT Gateway uses an Elastic IP

- A public NAT Gateway uses an **Elastic IP (EIP)** for its internet-facing side.

```
NAT Gateway → EIP → Internet
```

**Easy memory trick:** NAT Gateway + Elastic IP = public internet access for private resources.

---

## 5. Private subnet route table

- The **private** subnet's route table sends internet-bound traffic to the NAT Gateway:
```
Destination   Target
0.0.0.0/0     NAT Gateway
```

```
Private EC2 → Route Table (0.0.0.0/0) → NAT Gateway → Internet
```

---

## 6. Public subnet route table

- The **public** subnet's route table (the one the NAT Gateway itself lives in) sends internet-bound traffic to the Internet Gateway:
```
Destination   Target
0.0.0.0/0     Internet Gateway
```

**Complete path:**
```
Private EC2 → Private RT (0.0.0.0/0 → NAT GW) → NAT Gateway
            → Public RT (0.0.0.0/0 → IGW) → Internet Gateway → Internet
```

---

## 7. NAT Gateway does not provide inbound access

- NAT Gateway is for **outbound** connections initiated **from** private resources.
- An internet host **cannot** initiate a connection the other way — `Internet → NAT Gateway → Private EC2` doesn't work.

```
Allowed:     Private EC2 → Internet   (outbound)
Not allowed: Internet → Private EC2   (inbound)
```

---

## 8. NAT Gateway vs Internet Gateway

| | Internet Gateway | NAT Gateway |
|---|---|---|
| Provides | Internet connectivity for resources with public addressing | Outbound-only internet for **private** subnet resources |
| Direction | Both ways, for public resources | Outbound only, for private resources |

**Easy memory trick:** IGW = internet gateway for public resources. NAT = private → internet, one direction only.

---

## 9. NAT Gateway vs Security Group

- **NAT Gateway** — provides the network translation/connectivity itself.
- **Security Group** — controls whether the traffic is actually **allowed** to/from the resource in the first place.

```
Private EC2 —(SG must allow outbound)→ NAT Gateway → Internet
```
Both the networking (NAT Gateway) and the security rule (Security Group outbound) need to be correct.

---

## 10. NAT Gateway high availability

- A NAT Gateway is tied to **one** Availability Zone.
- For a multi-AZ production design, the common approach is **one NAT Gateway per AZ**, so one AZ's NAT Gateway isn't a single point of failure for another AZ.

```
Internet Gateway
    ├── AZ-1: NAT Gateway → Private Subnet → EC2-A
    └── AZ-2: NAT Gateway → Private Subnet → EC2-B
```

---

## 11. Complete architecture — everything together

```
Internet
   │
Internet Gateway
   │
   ├── Public Subnet (AZ-1) → NAT Gateway → Private Subnet (AZ-1) → EC2 → ENI → Security Group
   └── Public Subnet (AZ-2) → NAT Gateway → Private Subnet (AZ-2) → EC2 → ENI → Security Group
                                                                              NACL (subnet level)
```

**Each piece's job:**
- **ENI** — the network interface itself.
- **Security Group** — resource/ENI-level firewall.
- **NACL** — subnet-level firewall.
- **NAT Gateway** — private subnet → internet (outbound only).
- **Internet Gateway** — VPC → internet.

---

## 12. Troubleshooting — "private EC2 can't reach the internet"

1. Check the private subnet's route table: `0.0.0.0/0 → NAT Gateway`.
2. Check the NAT Gateway exists and is in an **available** state.
3. Check the NAT Gateway is actually in a **public** subnet.
4. Check the NAT Gateway has an Elastic IP attached.
5. Check the public subnet's route table: `0.0.0.0/0 → Internet Gateway`.
6. Check the Security Group's outbound rules.
7. Check the NACL's inbound/outbound rules.
8. Check DNS configuration, if the failure is specifically about resolving domain names.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| NAT Gateway | Outbound-only internet access for private subnets | Private app servers downloading OS patches |
| Created in a public subnet | NAT Gateway itself needs a route to the internet | Sits alongside the IGW-routed public subnet |
| Uses an Elastic IP | Gives the NAT Gateway a stable public-facing address | The NAT Gateway's own "public IP" |
| Private RT: `0.0.0.0/0 → NAT GW` | Routes private subnet's outbound traffic | Step one of the outbound path |
| Public RT: `0.0.0.0/0 → IGW` | Routes the NAT Gateway's traffic onward | Step two of the outbound path |
| No inbound access | Outbound only, never internet-initiated | A private DB server that's still fully patched, never exposed |
| One NAT Gateway per AZ | High availability, avoids cross-AZ dependency | Each AZ's private subnet has its own NAT Gateway |
