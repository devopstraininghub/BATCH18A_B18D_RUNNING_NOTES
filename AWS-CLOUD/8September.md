# Batch 18 — AWS Cloud Running Notes: 8 September 2026

**Topic: Amazon SNS (Simple Notification Service), Auto Scaling Groups (ASG)**

Friends, yesterday we built the blueprint for a server — a Custom AMI wrapped in a Launch Template. Today we look at **SNS**, AWS's alerting/notification system, and **Auto Scaling Groups** — which use everything we've built so far (Launch Template, Target Group, Load Balancer) to automatically add or remove servers based on real traffic, and can even use SNS to tell someone when it does.

---

## 1. What is SNS?

- **Amazon SNS** (**S**imple **N**otification **S**ervice) is a message delivery and notification service in AWS.
- It sends messages to people or systems **instantly**.

**What SNS can do:**
- Send alerts or notifications.
- Send messages to email or SMS.
- Trigger Lambda functions.
- Notify other AWS services.
- Push messages to mobile apps.

**Simple meaning:** SNS is a broadcast system — it delivers the same message to many subscribers at the same time.

---

## 2. What is an SNS Topic?

- A **Topic** is a channel where messages are published.
- Example: a topic named `"HighCPUAlerts"`.
- You publish **one** message → **all** subscribers receive it.

**Simple meaning:** a Topic is like a WhatsApp group — you send one message, and everyone in the group gets it.

---

## 3. What is a Subscription?

- A **Subscription** is where the topic actually sends its messages.
- You can subscribe:
  - Email.
  - SMS.
  - Lambda.
  - SQS.
  - HTTP endpoint.
  - Mobile push.

**Example:**
```
Topic: "Server-Alerts"
Subscriptions:
  - devops-team@gmail.com
  - +91-9000000000 (SMS)
  - A Lambda function
```
When the topic receives a message, **all** of these subscribers get notified.

**Easy memory trick:** SNS = the messaging/notification system. Topic = the message channel. Subscription = who actually receives it (email/SMS/Lambda/etc). Publish once → delivered to many.

---

## 4. What is an Auto Scaling Group (ASG)?

- An **Auto Scaling Group** automatically adds or removes EC2 instances, based on load, traffic, or health.
- Meaning:
  - Load increases → ASG **adds** servers (**scale out**).
  - Load decreases → ASG **removes** servers (**scale in**).
  - A server fails → ASG **replaces** it automatically.

**Why ASG is used:**
- Handles traffic spikes automatically.
- Maintains high availability.
- Keeps a minimum number of servers running at all times.
- Saves cost by scaling down during low traffic.
- Replaces unhealthy instances automatically.

**Real-time example:** An e-commerce site running with 2 servers normally scales up to 8 on a sale day as traffic climbs, then quietly scales back down to 2 overnight once traffic drops — nobody manually launches or terminates a single instance for any of it.

---

## 5. How ASG works — the simple flow

1. You create a **Launch Template** (the EC2 blueprint, from yesterday).
2. Create an **Auto Scaling Group** using that template.
3. Set:
   - Minimum capacity.
   - Desired capacity.
   - Maximum capacity.
4. ASG launches EC2 instances.
5. ASG performs health checks.
6. ASG scales out or scales in, based on traffic.

---

## 6. Important ASG terms

| Term | Meaning |
|---|---|
| **Min capacity** | The lowest number of EC2s the ASG will ever maintain |
| **Desired capacity** | The number of EC2s the ASG tries to keep running under normal conditions |
| **Max capacity** | The highest number of EC2s the ASG is allowed to launch |
| **Scaling out** | Adding more EC2s when load increases |
| **Scaling in** | Removing EC2s when load decreases |

---

## 7. What you need to create an ASG

- A **Launch Template**.
- A **VPC** + **Subnets**.
- A **Target Group** (optional, but recommended).
- A **Load Balancer** (optional, usually an ALB).
- **Scaling Policies** (optional).

---

## 8. ASG configuration options

1. **Launch Template** — includes the AMI, instance type, key pair, User Data, and security groups.
2. **Network (VPC + Subnets)** — select 2 or more Availability Zones for high availability.
3. **Load Balancer attachment (optional)** — connect the ASG to an Application Load Balancer (ALB) or Network Load Balancer (NLB).
4. **Health check types:**
   - EC2 status checks.
   - ELB health checks (recommended when attached to an ALB/NLB).
5. **Scaling policies:**
   - **Target Tracking** — e.g. keep CPU at 50%.
   - **Step Scaling** — add/remove EC2s as specific thresholds are crossed.
   - **Scheduled Scaling** — scale based on time (office hours, weekends).
6. **Instance Protection** — blocks the ASG from terminating specific, selected EC2 instances.
7. **Notifications (optional)** — sends an **SNS** alert whenever a scaling event happens (tying today's two topics together — an ASG can publish to an SNS topic like `"ScalingEvents"` so the on-call team's email/SMS fires automatically).

---

## 9. Example scenario

```
Min capacity      = 2
Desired capacity  = 4
Max capacity      = 10

Traffic increases → ASG scales to 7
Traffic drops     → ASG scales back to 4
An instance fails → ASG launches a new one automatically
```

---

## 10. Health check behavior

An instance is considered **unhealthy** if it:
- Fails EC2 status checks.
- Fails ALB/NLB health checks.
- Stops, crashes, or becomes unreachable.

The ASG will **terminate** the failed instance and **create a new one** automatically — no manual intervention needed.

**Summary:** an Auto Scaling Group launches EC2 instances automatically, replaces unhealthy instances, scales up during high traffic, scales down to save cost, and ensures high availability throughout.

**Easy memory trick:** ASG → the "self-healing, self-sizing" fleet manager. Min/Desired/Max → the floor, the target, and the ceiling.

---

## Quick Recap Table

| Command / Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| SNS | Broadcasts one message to many subscribers | Alerting the on-call team by email + SMS at once |
| SNS Topic | The channel a message is published to | `"HighCPUAlerts"`, `"Server-Alerts"` |
| SNS Subscription | Where the topic actually delivers messages | Email, SMS, Lambda, SQS, HTTP endpoint |
| Auto Scaling Group (ASG) | Auto adds/removes/replaces EC2 instances | Scaling a web tier up for a sale, down overnight |
| Min / Desired / Max capacity | The floor, target, and ceiling for instance count | `2 / 4 / 10` — never fewer than 2, never more than 10 |
| Scaling out / Scaling in | Adding servers / removing servers | Traffic spike → scale out; traffic drops → scale in |
| Target Tracking / Step / Scheduled scaling | Three ways to trigger scaling | Keep CPU at 50%; scale at fixed thresholds; scale by time of day |
| ASG + SNS notification | ASG alerts a team when it scales | On-call gets an SMS the moment a new instance is added |
