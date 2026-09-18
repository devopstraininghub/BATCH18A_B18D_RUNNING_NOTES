# Batch 18 — AWS Cloud Mini Project: Production-Style VPC Architecture

**Date implemented: 17 September 2026**
**Reference followed:** [AWS VPC example — private subnets with NAT](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-example-private-subnets-nat.html)

Friends, this is the mini project that ties together nearly everything from the last two weeks — VPC, subnets, Internet Gateway, NAT Gateway, ALB, Target Group, Auto Scaling Group, Launch Template, User Data, and Security Groups — into one real, working deployment. Where a concept was already covered in depth in an earlier date file, this doc links back to it instead of re-explaining it, and focuses on how it was actually configured and used **in this project**.

---

## 1. Project overview

**Title:** Production-Style AWS VPC Architecture

**Objective:**
- Deploy a highly available web application inside AWS.
- Application servers run on Amazon Linux EC2, inside **private** subnets.
- Users reach the application through an **Application Load Balancer (ALB)**.
- Private EC2 instances need no public IP — outbound internet access comes via **NAT Gateway**.
- EC2 instances are managed by an **Auto Scaling Group (ASG)**, launched from a **Launch Template**.

**Services used:**
- Amazon VPC, public subnets, private subnets
- Internet Gateway, NAT Gateway
- Application Load Balancer, Target Group
- Auto Scaling Group, Launch Template
- Amazon Linux EC2, Apache HTTP Server (`httpd`)
- Security Groups, Route Tables

**My project details:**

| Setting | Value |
|---|---|
| VPC Name | `prod-vpc` |
| VPC CIDR | `10.81.0.0/16` |
| Availability Zones used | 2 |
| EC2 Operating System | Amazon Linux |
| Web Server | Apache HTTP Server (`httpd`) |
| Application | "Mind Circuit Facebook Page" |
| Web page file | `/var/www/html/index.html` |

*(Concept background: VPC — `9September_VPC.md`; ALB/Target Group — `4September_LB_UserData.md`; AMI/Launch Template — `7September_AMI_LT.md`; ASG — `8September_SNS_ASG.md`; NAT Gateway/IGW — `11September_NATGateway.md`, `17September_IGW.md`.)*

---

## 2. High-level architecture

```
                         INTERNET
                             │
                             ▼
                    Internet Gateway (IGW)
                             │
              ═══════════════════════════════
                     PUBLIC SUBNETS
              ═══════════════════════════════
                    │                 │
              ┌───────────┐     ┌───────────┐
              │    ALB    │     │    NAT    │
              │           │     │  Gateway  │
              └───────────┘     └───────────┘
                    │                 │
                    ▼                 │
              ═══════════════════════════════
                     PRIVATE SUBNETS
              ═══════════════════════════════
                    │                 │
                    ▼                 ▼
               ┌─────────┐       ┌─────────┐
               │  EC2    │       │  EC2    │
               │ Apache  │       │ Apache  │
               └─────────┘       └─────────┘
                    ▲                 ▲
                    │                 │
              Auto Scaling Group (ASG)
                    │
                    ▲
             Launch Template
```

---

## 3. Main traffic flow — a user's request

```
USER → HTTP/HTTPS request → INTERNET → INTERNET GATEWAY
     → APPLICATION LOAD BALANCER → TARGET GROUP
     → PRIVATE EC2 INSTANCE → APACHE HTTP SERVER → index.html
```

## 4. Private EC2 outbound internet flow

```
PRIVATE EC2 → PRIVATE ROUTE TABLE (0.0.0.0/0) → NAT GATEWAY
            → PUBLIC ROUTE TABLE (0.0.0.0/0) → INTERNET GATEWAY → INTERNET
```

---

## 5. Networking setup used in this project

**Public subnets** — host the ALB and the NAT Gateway. Route table:
```
10.81.0.0/16 → local
0.0.0.0/0    → Internet Gateway
```

**Private subnets** — host the application EC2 instances. Route table:
```
10.81.0.0/16 → local
0.0.0.0/0    → NAT Gateway
```

**Two Availability Zones**, each with its own public subnet, private subnet, and NAT Gateway — so one AZ having a problem doesn't take out the whole application, and neither AZ depends on the other AZ's NAT Gateway.

---

## 6. Application layer — ALB, Target Group, ASG, Launch Template

- **ALB** sits in the public subnets, receives all inbound application traffic, and forwards it to the **Target Group**.
- **Target Group** — health check config used: `HTTP`, port `80`, path `/`. An instance that fails this check is marked **Unhealthy** and stops receiving traffic.
- **Auto Scaling Group** capacity used: **Minimum 2 / Desired 2 / Maximum 4**.
- **Launch Template** defines: the Amazon Linux AMI, instance type, key pair, Security Group, storage, and the User Data script below.

---

## 7. The actual User Data script used

```bash
#!/bin/bash

yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd

cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Mind Circuit Facebook Page</title>
</head>
<body>
    <h1>Welcome to Mind Circuit Facebook page</h1>
</body>
</html>
EOF
```

**Line by line:**
- `#!/bin/bash` — run this as a Bash script.
- `yum update -y` — update installed packages; `-y` auto-confirms.
- `yum install -y httpd` — install Apache (`httpd` = the Apache package name).
- `systemctl enable httpd` — start Apache automatically on every future boot.
- `systemctl start httpd` — start Apache right now.
- `cat > /var/www/html/index.html <<'EOF' ... EOF` — writes the webpage directly to Apache's default document root (`/var/www/html/`), using a heredoc to insert multi-line HTML in one shot.

---

## 8. Why User Data + Launch Template together

**Without User Data:** a newly launched EC2 needs someone to log in manually, install Apache, start it, and create the webpage — every single time.

**With User Data:**
```
EC2 launched → Launch Template → User Data executes
             → Install Apache + Start Apache + Create webpage
             → Web Server Ready
```
This matters most when the ASG launches a **replacement** instance after a failure — it comes up fully configured with zero manual steps.

---

## 9. Security Group design

**ALB Security Group:**
```
Inbound: HTTP (80) — Source 0.0.0.0/0
```

**EC2 Security Group:**
```
Inbound: HTTP (80) — Source = ALB Security Group  (not 0.0.0.0/0)
```
The EC2 instances are private application servers — they should only ever hear from the ALB, never directly from the internet. (Same SG-to-SG reference pattern as `10September_SG.md`.)

**Complete security flow:**
```
Internet User → ALB Security Group → ALB → EC2 Security Group (allow from ALB SG) → Private EC2 → Apache
```

---

## 10. Complete application request flow

1. User enters the ALB's DNS name.
2. Request reaches the Internet Gateway.
3. Request reaches the Application Load Balancer.
4. ALB checks its Target Group.
5. ALB selects a **healthy** EC2 instance.
6. Request reaches Apache on port 80.
7. Apache reads `/var/www/html/index.html`.
8. The HTML response is returned to the user.

---

## 11. Self-healing — what happens when an instance fails

```
EC2-1 → unhealthy → Target Group detects it → ASG replaces it
                                              ↓
New EC2 → Launch Template → User Data → Apache installed
        → Website created → Health Check → Healthy → ALB starts sending traffic
```
This is the entire point of combining **Launch Template + ASG + ALB** — a failed instance is replaced and fully reconfigured automatically, with zero manual intervention.

---

## 12. Troubleshooting runbooks

**Website not loading via the ALB:**
1. Is the ALB running?
2. Is the listener configured (e.g. HTTP:80)?
3. Is the Target Group configured?
4. Are the targets healthy?
5. Is Apache running? — `systemctl status httpd`
6. Is port 80 listening? — `ss -lntp | grep :80`
7. Test locally on the EC2: `curl http://localhost`
8. Is `index.html` actually present? — `ls -l /var/www/html/index.html`
9. Does the EC2 Security Group allow HTTP from the ALB Security Group?
10. Is the correct health check path configured?

**Private EC2 can't reach the internet:**
1. Private subnet route table has `0.0.0.0/0 → NAT Gateway`.
2. NAT Gateway is in an **available** state.
3. NAT Gateway is actually in a public subnet.
4. Public subnet route table has `0.0.0.0/0 → Internet Gateway`.
5. NAT Gateway has the required public connectivity (EIP).
6. Security Group outbound rules allow it.
7. Network ACL rules allow it.
8. Subnet association is correct.

**Target marked unhealthy:**
- Is Apache installed? Running? Port 80 listening?
- Is the target group pointed at the correct port?
- Is the health check path correct?
- Does the EC2 Security Group allow the ALB Security Group?
- Is a NACL blocking the traffic?

**Useful commands:**
```bash
systemctl status httpd
ss -lntp | grep :80
curl http://localhost
cat /var/www/html/index.html
```
(AWS also recommends **VPC Reachability Analyzer** for diagnosing route table/Security Group reachability issues.)

---

## 13. Project creation order (the actual build sequence)

1. Create VPC — `prod-vpc`, CIDR `10.81.0.0/16`.
2. Select two Availability Zones.
3. Create two public subnets.
4. Create two private subnets.
5. Attach the Internet Gateway.
6. Create a NAT Gateway in each public subnet.
7. Configure the public route tables.
8. Configure the private route tables.
9. Create the ALB Security Group.
10. Create the EC2/application Security Group.
11. Create the Launch Template.
12. Select the Amazon Linux AMI.
13. Configure the instance type.
14. Attach the Security Group.
15. Add the User Data script.
16. Create the Auto Scaling Group.
17. Select the private subnets for it.
18. Configure min/desired/max capacity.
19. Create the Target Group.
20. Configure the ALB.
21. Configure the listener.
22. Attach the Target Group to the ALB/ASG.
23. Wait for the EC2 instances to become healthy.
24. Test the ALB's DNS name in a browser.

---

## 14. Resource relationship tree

```
VPC (prod-vpc)
├── Internet Gateway
├── Public Subnet AZ-1 → ALB, NAT Gateway
├── Public Subnet AZ-2 → ALB, NAT Gateway
├── Private Subnet AZ-1 → EC2
├── Private Subnet AZ-2 → EC2
├── Public / Private Route Tables
├── Security Groups
├── Target Group
└── Auto Scaling Group → Launch Template → Amazon Linux → Apache → index.html
```

---

## Quick Recap Table

| Component | Purpose in this project |
|---|---|
| `prod-vpc` (`10.81.0.0/16`) | The isolated network everything else lives inside |
| Public subnets (2 AZs) | Host the ALB and one NAT Gateway per AZ |
| Private subnets (2 AZs) | Host the Amazon Linux + Apache EC2 instances |
| Internet Gateway | VPC's connection to the internet |
| NAT Gateway (one per AZ) | Outbound-only internet for the private EC2 instances |
| ALB + Target Group | Distributes inbound traffic to healthy EC2 instances |
| Auto Scaling Group (2/2/4) | Keeps the right number of EC2 instances running, replaces failures |
| Launch Template | The blueprint ASG uses to launch each new instance |
| User Data | Auto-installs and starts Apache, creates `index.html`, on first boot |
| ALB-SG / EC2-SG (SG-to-SG) | EC2 only accepts traffic from the ALB, never directly from the internet |
