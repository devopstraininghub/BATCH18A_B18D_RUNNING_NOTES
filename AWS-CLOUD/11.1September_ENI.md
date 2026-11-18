# Batch 18 — AWS Cloud Running Notes: 11 September 2026

**Topic: ENI (Elastic Network Interface)**

Friends, today we go one level deeper on networking — starting with the **ENI**, the actual virtual network card behind every EC2 instance's connectivity, then the **NACL** (subnet-level firewall) and **NAT Gateway** in their own files.

---

## 1. What is an ENI?

- **NIC** = Network Interface Card — the general networking term.
- In AWS, the term used is **ENI** = **E**lastic **N**etwork **I**nterface.
- An ENI is a **virtual network interface** that provides network connectivity to an EC2 instance.

**Simple picture:**
```
EC2 → ENI → Private IP + Security Group + MAC Address + Subnet
```

**Easy memory trick:** ENI = EC2's network card.

---

## 2. Why do we need an ENI?

- An EC2 instance needs a network interface to communicate with anything else on the network.
- Without connectivity through an ENI, an EC2 instance can't reach other EC2 instances, a database, the internet, or any other AWS resource.

```
EC2 → ENI → VPC Network → Other EC2 / Database / Internet / Other AWS resources
```

---

## 3. What does an ENI have?

- A primary private IPv4 address.
- Secondary private IPv4 addresses (optional).
- IPv6 addresses (optional).
- A MAC address.
- One or more Security Groups.
- A subnet association.
- Its own Network Interface ID.

**Example:**
```
ENI ID:         eni-123456789
Private IP:      10.0.1.10
Security Group:  web-sg
Subnet:          10.0.1.0/24
```

---

## 4. Primary private IP

- Every ENI has one **primary** private IPv4 address.
- This is the IP used for communication inside the VPC.

```
EC2 → ENI → Primary Private IP: 10.0.1.10
```

---

## 5. Secondary private IP

- An ENI can also have **secondary** private IP addresses, subject to AWS and instance-type limits.
- Useful for applications that need multiple IP addresses on the same instance.

**Example:**
```
ENI
├── Primary IP:   10.0.1.10
└── Secondary IPs: 10.0.1.20, 10.0.1.30
```

---

## 6. Security Group and ENI

- Security Groups are associated with the **network interface**, not the instance directly.
- The Security Group on the ENI controls both **inbound** and **outbound** traffic.

**Example:**
```
ENI → Security Group → Allow TCP 22, Allow TCP 80, Allow TCP 443
```

---

## 7. Multiple ENIs

- An EC2 instance can support **multiple** network interfaces, depending on the instance type's limits.
- Useful for special networking setups — e.g. one interface on a "management" subnet, another on the "application" subnet.

**Example:**
```
EC2
├── ENI-1 → 10.0.1.10
└── ENI-2 → 10.0.2.10
```

**Easy memory trick:** ENI → EC2's virtual network card, providing IP + connectivity + Security Group association. Multiple ENIs → multiple network cards on the same server.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| ENI | Virtual network interface for an EC2 instance | The actual thing that gives an instance its IP and connectivity |
| Primary private IP | The main IP an ENI uses inside the VPC | Standard EC2-to-EC2 or app-to-database traffic |
| Secondary private IP | Extra IPs on the same ENI | An application that needs to bind multiple IPs |
| Security Group on ENI | The firewall actually lives on the interface | Same instance, different ENIs, different SG rules per interface |
| Multiple ENIs | One EC2, several network interfaces | Separating management traffic from application traffic |
