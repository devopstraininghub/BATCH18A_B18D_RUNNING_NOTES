# Batch 18 — AWS Cloud Running Notes: 17 September 2026

**Topic: Jump Server / Bastion Host**

Friends, today we look at how administrators actually reach a **private** EC2 instance safely — through a **Bastion Host** (jump server) — and then, in a separate file, the **Internet Gateway** that sits behind all of this VPC's internet connectivity.

---

## 1. What is a Jump Server?

- A **Jump Server** is an intermediate server used to securely access servers inside a **private network**.
- Also called a **Bastion Host**.

```
Your Laptop → Jump Server / Bastion Host → Private EC2
```

- Instead of directly exposing a private EC2 server to the internet, you connect **through** the Bastion Host first.

---

## 2. Why do we need a Jump Server?

- Private servers (application EC2, database EC2) don't need a **public IP** just for admin SSH access.
- Instead, only the Bastion Host is exposed:

```
Admin Laptop --SSH--> Bastion Host --SSH--> Private EC2
```

- This reduces the number of servers directly exposed to internet SSH access down to **one** — the Bastion Host.

---

## 3. Real-time DevOps example

**Architecture:**
```
Internet → Public IP → Bastion Host (Public Subnet) → Private IP → Private EC2 (Private Subnet)
```

**Step 1 — connect to the Bastion:**
```bash
ssh -i bastion.pem ec2-user@<BASTION_PUBLIC_IP>
```

**Step 2 — from the Bastion, connect to the private instance:**
```bash
ssh -i private-key.pem ec2-user@<PRIVATE_EC2_PRIVATE_IP>
```

**Flow:** Laptop → SSH → Bastion → SSH (using the private IP) → Private EC2.

---

## 4. Where is a Bastion Host created?

- Normally in the **public subnet** — administrators need to reach it from outside the VPC.

```
VPC
├── Public Subnet  → Bastion Host (Public IP)
└── Private Subnet → Application EC2
```

---

## 5. Security Group for the Bastion Host

- The Bastion's Security Group should allow SSH **only** from trusted administrator IPs.

```
BASTION-SG
Inbound: SSH (22) — Source = Admin IP
```

⚠️ Avoid `SSH (22) — Source = 0.0.0.0/0` on the Bastion whenever possible.

**Easy memory trick:** Admin IP → SSH 22 → Bastion.

---

## 6. Security Group for the private EC2

- The private EC2's Security Group should allow SSH from the **Bastion's Security Group** — not from the entire internet.

```
PRIVATE-EC2-SG
Inbound: SSH (22) — Source = BASTION-SG
```

**Full chain:** Admin IP --SSH 22--> Bastion --SSH 22--> Private EC2.

This is the same "reference another Security Group as the source" pattern used for database access — see `10September_SG.md`.

---

## 7. Bastion Host is not for application traffic

- Bastion Host is for: **administration, maintenance, troubleshooting, SSH access.**
- It is **not** the path application traffic takes.

```
Admin path:       Laptop → Bastion → Private EC2
Application path: Users → Load Balancer → Application EC2
```
Don't confuse the two — they're completely separate paths into the same private subnet.

---

## 8. Jump Server vs normal application server

| | Normal application server | Bastion / Jump Server |
|---|---|---|
| Job | Runs the application | Controlled entry point for admin access |

**Easy memory trick:** Application server = runs the app. Bastion = the jump point for reaching it.

---

## 9. Bastion Host security best practices

- Allow SSH only from trusted IPs.
- Use Security Groups to restrict access.
- Keep the Bastion Host patched.
- Use SSH keys instead of passwords, where appropriate.
- Keep the Bastion Host minimal — don't run application workloads on it.
- Monitor login activity.
- Avoid storing application data on the Bastion.
- Restrict what the Bastion can reach — only the specific private resources/ports actually needed.

**Easy memory trick:** Bastion = the gateway for admin access — Laptop → Bastion → Private Servers, and nothing else runs there.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Bastion Host / Jump Server | An intermediate server for reaching private instances | Only one server exposed to internet SSH, not every private server |
| Deployed in the public subnet | Needs to be reachable from outside the VPC | Bastion has a public IP, the servers behind it don't |
| Bastion-SG: SSH from admin IP only | Restrict who can even reach the jump point | Avoiding `0.0.0.0/0` on the Bastion's SSH rule |
| Private-EC2-SG: SSH from Bastion-SG | The private server only trusts the Bastion, not the internet | SG-to-SG reference, same pattern as securing a database |
| Admin path vs application path | Two separate, unrelated paths into the same subnet | Bastion for SSH/maintenance; Load Balancer for real user traffic |
