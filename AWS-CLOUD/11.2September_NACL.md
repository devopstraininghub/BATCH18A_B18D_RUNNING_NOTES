# Batch 18 — AWS Cloud Running Notes: 11 September 2026

**Topic: NACL (Network Access Control List)**

Friends, second topic today — the **NACL**, a firewall that works at the **subnet** level, unlike the Security Group (from 10 September) which works at the resource/ENI level.

---

## 1. What is NACL?

- **NACL** = **N**etwork **A**ccess **C**ontrol **L**ist.
- A **firewall at the subnet level** — it controls traffic entering and leaving an entire subnet, not just one resource.

```
VPC → Subnet → NACL controls what enters/leaves this subnet
```

**Easy memory trick:** NACL = subnet firewall.

---

## 2. What does NACL control?

- **Inbound** traffic — traffic coming **into** the subnet.
- **Outbound** traffic — traffic going **out of** the subnet.

```
Internet → NACL → Subnet → EC2
```

---

## 3. NACL is STATELESS

⚠️ **Very important, commonly tested.**

- Inbound and outbound traffic are evaluated **separately**.
- If inbound traffic is allowed, that does **not** automatically allow the matching return traffic — you need an explicit outbound rule for it too.

```
Client --request--> EC2 --response--> Client
```
Even if the inbound request was allowed, the response still needs its **own** outbound rule to pass through the NACL.

**Easy memory trick:** Security Group = stateful (remembers the connection). NACL = stateless (checks each direction separately, every time).

---

## 4. NACL supports ALLOW and DENY

- Security Group: **ALLOW** rules only.
- NACL: supports **both ALLOW and DENY** rules.

**Example:**
```
Rule 100: ALLOW TCP 80
Rule 110: DENY  TCP 22
```
Result: HTTP is allowed, SSH is explicitly denied.

---

## 5. NACL rule numbers

- NACL rules have **rule numbers**.
- Rules are evaluated from the **lowest number to the highest**.
- The **first matching rule** is applied — evaluation stops there.

**Example:**
```
Rule   Action   Port
100    ALLOW    80
110    ALLOW    443
120    DENY     22
```
Evaluation order: `100 → 110 → 120 → *` (the final implicit rule denies everything not already matched).

**Easy memory trick:** Lowest rule number → checked first.

---

## 6. Default NACL

- AWS provides a **default NACL** for every VPC.
- By default, the default NACL **allows all** inbound and outbound traffic, unless its rules are modified.

```
Default NACL — Inbound: ALLOW ALL. Outbound: ALLOW ALL.
```

---

## 7. Custom NACL

- You can create your **own** NACL for extra subnet-level control.

**Example:**
```
Inbound:  TCP 80 → ALLOW, TCP 443 → ALLOW, TCP 22 → DENY
Outbound: required traffic → ALLOW
```

---

## 8. NACL is associated with a subnet

- NACLs work at the **subnet** level.
- A subnet is associated with **one** NACL at a time.
- One NACL **can** be associated with multiple subnets.

```
VPC
├── Public Subnet  → NACL
└── Private Subnet → NACL
```

---

## 9. NACL vs Security Group

| Feature | Security Group | NACL |
|---|---|---|
| Level | Resource/ENI | Subnet |
| State | Stateful | Stateless |
| Rules | Allow only | Allow + Deny |
| Inbound | Yes | Yes |
| Outbound | Yes | Yes |
| Rule evaluation | All matching SG rules apply | Lowest rule number first, stop at first match |
| Association | ENI/resource | Subnet |

**Easy memory trick:** SG → close to the server. NACL → at the subnet, further out.

**⚠️ Common interview question:** "Which is more restrictive — Security Group or NACL?" Neither, really — they work at **different levels** and provide **different kinds** of control. Traffic in a real request path can be affected by **both** at once.

---

## 10. Real-time example — both layers together

```
Internet
   │
   ▼
Public Subnet
   ├── NACL (subnet-level protection)
   └── EC2
        └── ENI
             └── Security Group (resource-level protection)
```
A packet reaching this EC2 instance passes the NACL first (subnet gate), then the Security Group (instance gate) — both need to allow it.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| NACL | Stateless firewall at the subnet level | An extra layer of defense beyond Security Groups |
| Stateless | Inbound/outbound evaluated separately | Must add both an inbound AND an outbound rule for two-way traffic |
| Allow + Deny rules | NACL supports explicit deny | Explicitly blocking a known-bad IP range at the subnet |
| Rule numbers, lowest first | First matching rule wins | Ordering rules so specific denies come before broad allows |
| One NACL per subnet | A subnet always has exactly one NACL | Public and private subnets typically use different NACLs |
| SG vs NACL together | Two layers, not either/or | Traffic must pass the subnet's NACL *and* the instance's SG |
