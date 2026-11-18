# Batch 18 — AWS Cloud Running Notes: 10 September 2026

**Topic: Security Groups (SG)**

Friends, the last networking topic for today — the **Security Group**, the actual firewall that decides exactly who can reach an AWS resource, and on which port. VPC Peering and Elastic IPs get traffic to the right place; the Security Group decides whether that traffic is actually allowed in.

---

## 1. What is a Security Group?

- A **Security Group (SG)** is a **virtual firewall** for AWS resources like EC2 instances.
- It controls two directions of traffic:
  - **Inbound** — traffic coming **into** the resource.
  - **Outbound** — traffic going **out of** the resource.

**Easy memory trick:** Security Group = a security gate with two doors: inbound and outbound.

---

## 2. Why use a Security Group?

- Controls **who** can connect to your resource, and **which port** they can use.

**Example — a web server:**
```
Allow: HTTP (port 80), HTTPS (port 443), SSH (port 22)
Block: everything else
```

---

## 3. Inbound rules

- **Inbound** = traffic coming **to** the EC2 instance.

**Example:**
```
Type    Port    Source
SSH     22      My IP
HTTP    80      0.0.0.0/0
HTTPS   443     0.0.0.0/0
```
- Port 22: only the specified source can SSH in.
- Port 80/443: anyone on the internet can reach these.

---

## 4. Outbound rules

- **Outbound** = traffic going **from** the EC2 instance, e.g. out to the internet.
- By default, a newly created Security Group generally **allows all outbound** traffic, unless its rules are changed.

---

## 5. Security Group is STATEFUL

⚠️ **Very commonly tested point.**

- If an **inbound** request is allowed, the **response** to that request is automatically allowed too — you don't need a matching outbound rule for it.

**Example:**
```
Client --request--> EC2 --response--> Client
```
The response traffic doesn't need its own explicit outbound rule.

**Easy memory trick:** Security Group = stateful. (Compare this to a NACL, which is stateless — see section 12.)

---

## 6. Security Group is attached to the ENI (network interface)

- Security Groups are associated with an instance's **network interface (ENI)**, not with a subnet.
- One or more Security Groups can be attached to a single network interface.

```
EC2 → ENI → Security Group rules
```

---

## 7. Security Group has ALLOW rules only

- Security Groups only have **ALLOW** rules — there's no explicit **DENY** rule.
- Anything not explicitly allowed is simply not permitted.

**Easy memory trick:** SG = allow-only.

---

## 8. Example — a web server's Security Group

```
Web Server EC2 — Private IP: 10.0.1.10, Public IP: 3.100.50.20

Inbound:
  HTTP  (80)  — Source 0.0.0.0/0
  HTTPS (443) — Source 0.0.0.0/0
  SSH   (22)  — Source My IP
```
Result: anyone on the internet can reach the site over HTTP/HTTPS, but only you can SSH in.

---

## 9. Example — securing an app/database tier with SG-to-SG references

- A database should **not** accept connections from the whole internet.
- Instead of `0.0.0.0/0`, set the database's Security Group source to the **App Server's Security Group** itself.

**Example:**
```
Web Server: 10.0.1.10 → App Server: 10.0.2.10 → Database: 10.0.3.10

Database Security Group:
  MySQL (3306) — Source = App Server Security Group
```
Only instances that are members of the App Server's Security Group can reach the database — not any specific IP, and not the whole internet.

**Easy memory trick:** Reference a Security Group as the source, not `0.0.0.0/0`, whenever the traffic is coming from other AWS resources.

---

## 10. Common ports

| Service | Port |
|---|---|
| SSH | 22 |
| HTTP | 80 |
| HTTPS | 443 |
| MySQL | 3306 |
| PostgreSQL | 5432 |
| Jenkins | 8080 |
| Tomcat | 8080 |
| RDP | 3389 |

---

## 11. `0.0.0.0/0` and SSH best practice

- `0.0.0.0/0` means **any IPv4 address** — literally everyone.
- For HTTP/HTTPS on a public web server, `0.0.0.0/0` is normal and expected.
- For **SSH**, avoid `0.0.0.0/0` when possible.

**Better:**
```
SSH (22) — Source: My-IP/32
```
`/32` means exactly one specific IP address, not a range.

---

## 12. Security Group vs Network ACL

| | Security Group | Network ACL |
|---|---|---|
| Level | Resource / network interface | Subnet |
| State | Stateful | Stateless |
| Rules | Allow only | Allow **and** Deny |
| Evaluation | All matching rules apply | Inbound and outbound evaluated separately, in rule-number order |

**Easy memory trick:** SG = stateful, resource-level. NACL = stateless, subnet-level.

---

## 13. Real-time troubleshooting — "can't SSH into my EC2"

1. Does the EC2 have a reachable public path (public IP/EIP)?
2. Is the route correct (route table)?
3. Is the Security Group allowing TCP 22?
4. Is the source IP in the rule actually your current IP?
5. Is a NACL blocking the traffic?
6. Is the SSH service actually running on the instance?
7. Is the correct `.pem` key being used?

**Example SG rule to check:**
```
SSH, TCP, 22, Source = YOUR-IP/32
```

---

## 14. Security Group + Public IP — two separate things

- Having a public IP does **not** automatically mean everyone can reach the instance.
- The Security Group still decides what's actually allowed.

**Example:**
```
EC2 Public IP: 3.x.x.x
Security Group: SSH (22) → My IP only

My IP    → EC2  ALLOW
Other IP → EC2  BLOCK
```

**Easy memory trick:** Public IP = reachability/address. Security Group = permission.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Security Group (SG) | Virtual firewall for a resource | Web server allowing 80/443 from anyone, 22 from only you |
| Inbound / Outbound rules | Traffic coming in / going out | HTTP allowed inbound, most outbound allowed by default |
| SG is stateful | Response traffic auto-allowed | No separate outbound rule needed for a reply to an allowed request |
| SG = allow-only | No explicit deny rules | Anything not allowed is simply blocked by default |
| SG-to-SG reference | Restrict source to another Security Group, not `0.0.0.0/0` | Database only reachable from the App Server's Security Group |
| `My-IP/32` for SSH | Restrict SSH to one exact IP | Avoiding `0.0.0.0/0` on port 22 |
| SG vs NACL | Stateful/resource-level vs stateless/subnet-level | An extra layer of defense, NACL blocking what SG might miss |
