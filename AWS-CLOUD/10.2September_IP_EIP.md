# Batch 18 — AWS Cloud Running Notes: 10 September 2026

**Topic: Private IP vs Public IP vs Elastic IP (EIP)**

Friends, continuing today's networking theme — every EC2 instance can have up to three kinds of IP address, and knowing which is which (and which one *changes on you*) matters a lot in production.

---

## 1. What is an IP address?

- **IP** = Internet Protocol — identifies a device/resource on a network.
- An EC2 instance in AWS can have:
  - A **Private IP**.
  - A **Public IP**.
  - An **Elastic IP (EIP)**.

**Simple meaning:**
- Private IP = internal communication.
- Public IP = internet communication.
- EIP = a **fixed** public IP.

---

## 2. Private IP

- Used for communication **inside** a private network/VPC.
- Not reachable from the public internet at all.

**Example:**
```
VPC 10.0.0.0/16
EC2-A: 10.0.1.10
EC2-B: 10.0.1.20

EC2-A ----> EC2-B   (private IP)
```

**Typically used for:**
- EC2-to-EC2 communication.
- Application-to-database communication.
- Communication between AWS resources.
- Communication between subnets.
- VPC Peering communication (see the VPC Peering notes).

**Easy memory trick:** Private IP → stays inside AWS.

---

## 3. Public IP

- A public IP is used for communication between an AWS resource and the **internet**.

**Example:**
```
EC2 — Private IP: 10.0.1.10, Public IP: 3.100.50.20
```

```bash
ssh -i key.pem ec2-user@3.100.50.20
```
```
http://3.100.50.20
```

**Easy memory trick:** Public IP → reachable from the internet.

---

## 4. Important — a normal public IP is NOT permanent

- If an EC2 instance is **stopped and started**, its public IPv4 address can **change**.

**Example:**
```
Before stop:      Public IP = 3.100.50.20
After stop/start: Public IP = 3.200.60.30
```

- A normal public IP is **not** designed to be a stable, long-term address.
- If a server needs a fixed public IP, use an **Elastic IP** instead.

---

## 5. What is EIP (Elastic IP)?

- **EIP** = Elastic IP — a **static** public IPv4 address, allocated to your **AWS account** (not to any one instance).

**Example:**
```
EIP: 54.200.10.50
```

- You **associate** the EIP with an EC2 instance's private IP.
```
EIP 54.200.10.50 ----> EC2 (private IP 10.0.1.10)
```

**Easy memory trick:** EIP → fixed public IPv4 address.

---

## 6. Why use EIP?

- A production server's normal public IP can change on every stop/start — customers pointed at the old IP would lose access.
- Allocating an EIP and associating it with the instance means customers always use the **same** address.
- The EIP stays associated with your AWS account until you explicitly **release** it.

**Real-time example:**
```
Production EC2: Public IP = 3.100.20.30 (can change)

Fix: allocate EIP = 54.200.10.50, associate it with the EC2 instance.

Customers now always use: 54.200.10.50
```

---

## 7. Public IP vs EIP

| | Public IP | Elastic IP (EIP) |
|---|---|---|
| Assignment | Automatic, when configured | You allocate it manually |
| Changes on stop/start? | Yes, can change | No, stays fixed |
| Tied to | The instance (temporarily) | Your AWS account |
| Designed for | Casual/temporary reachability | A permanent, stable address |

**Easy memory trick:** Public IP = temporary. EIP = elastic/fixed.

---

## 8. Private IP vs Public IP vs EIP — summary table

| IP Type | Main use |
|---|---|
| Private IP | Internal communication (inside the VPC) |
| Public IP | Internet communication (can change) |
| EIP | Fixed public IP (tied to your account) |

**Example on one EC2:**
```
Private IP: 10.0.1.10
Public IP:  3.100.50.20
EIP:        54.200.10.50
```

---

## 9. Real-time DevOps example

```
Production EC2: Private IP = 10.0.1.10, Public IP = 3.100.50.20

Developers/admins access it: Internet → Public IP → EC2
```
If this server needs a fixed public IP: allocate `54.200.10.50` and associate it with the instance — from then on, users always connect through `54.200.10.50`, no matter how many times the instance is stopped and started.

---

## 10. A private IP doesn't mean "no internet access"

- A private IP is **not** directly reachable from the public internet.
- But an instance with only a private IP **can still** reach the internet outbound, if the network is designed for it.

**Example:**
```
Private EC2 → NAT Gateway → Internet
```
This is the standard setup for a private subnet — outbound access (for updates, package installs) without being reachable from outside.

**Easy memory trick:** Private = inside. Public = internet. EIP = fixed public.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Private IP | Internal-only communication inside a VPC | App server talking to a database server privately |
| Public IP | Internet-facing address, can change | Default reachability for a public-subnet EC2 |
| EIP | Static public IPv4 tied to your AWS account | Keeping a production server's IP stable across restarts |
| Public IP changing on stop/start | Normal AWS behavior, not a bug | Why production servers use an EIP instead |
| Private IP + NAT Gateway | Outbound-only internet for private instances | Private app servers downloading OS patches |
