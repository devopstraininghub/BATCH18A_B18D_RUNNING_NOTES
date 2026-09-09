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

## 7. Launch Configuration vs Launch Template

An ASG needs a blueprint to know **what** to launch — historically that was a **Launch Configuration**; today it should be a **Launch Template**.

- **Launch Configuration** — the older way. A template specifying the AMI, instance type, key pair, security groups, and block device mappings for the ASG to use.
- **Launch Template** — the modern, more flexible option (what we built yesterday) — supports versioning, more settings, and can also be used for a plain one-off EC2 launch, not just ASGs.

⚠️ **Important:** Launch Configurations are officially deprecated. AWS accounts created on or after 1 October 2024 cannot create a new Launch Configuration at all (console, CLI, API, or CloudFormation) — existing ones on older accounts still run, but AWS recommends migrating off them. **Always use a Launch Template for any new ASG.**

**Easy memory trick:** Launch Configuration → the retired option. Launch Template → the one you should actually use.

---

## 8. What you need to create an ASG

- A **Launch Template**.
- A **VPC** + **Subnets**.
- A **Target Group** (optional, but recommended).
- A **Load Balancer** (optional, usually an ALB).
- **Scaling Policies** (optional).

---

## 9. ASG configuration options

1. **Launch Template** — includes the AMI, instance type, key pair, User Data, and security groups.
2. **Network (VPC + Subnets)** — select 2 or more Availability Zones for high availability.
3. **Load Balancer attachment (optional)** — connect the ASG to an Application Load Balancer (ALB) or Network Load Balancer (NLB).
4. **Health check types:**
   - EC2 status checks.
   - ELB health checks (recommended when attached to an ALB/NLB).
5. **Scaling policies** — four types:
   - **Target Tracking** — e.g. keep CPU at 50%; AWS adjusts capacity automatically to hold that target.
   - **Simple Scaling** — one scaling adjustment fires per alarm, then waits out a cooldown before reacting again.
   - **Step Scaling** — add/remove EC2s in different-sized steps, depending on how far past the threshold the metric is.
   - **Scheduled Scaling** — scale based on time (office hours, weekends).
6. **Scaling adjustments** — set when creating a scaling policy: exactly **how many** instances to add or remove when the policy's condition is triggered (e.g. "add 2 instances" or "add 20% of current capacity").
7. **Cool down period** — a configurable waiting period **after** a scaling activity, during which the ASG won't launch or terminate any more instances. This gives the previous change time to actually take effect (e.g. a new instance finishing its boot and warming up) before the ASG reacts again and potentially over-corrects.
8. **Instance Protection** — blocks the ASG from terminating specific, selected EC2 instances.
9. **Notifications (optional)** — sends an **SNS** alert whenever a scaling event happens (tying today's two topics together — an ASG can publish to an SNS topic like `"ScalingEvents"` so the on-call team's email/SMS fires automatically).

**Real-time example (cooldown):** Without a cooldown period, a CPU spike could cause the ASG to launch 3 new instances, then — before those instances have even finished booting and started sharing the load — see CPU still high and launch 3 more. A cooldown period stops this "overshoot," giving each batch of new instances time to actually start absorbing traffic first.

**Easy memory trick:** Scaling policy → *when* to scale. Scaling adjustment → *by how much*. Cooldown → *how long to wait before reacting again*.

---

## 10. Other ASG capabilities

- **Dynamic Scaling** — the umbrella term for scaling automatically based on real-time metrics like CPU utilization, network traffic, or a custom CloudWatch alarm — this is what powers Target Tracking and Step Scaling under the hood.
- **Integration with other AWS services** — ASG works together with Elastic Load Balancing and CloudWatch to form a complete solution for managing an application's performance and availability.
- **Auto Scaling Plans** — a feature that looks at **historical data** to build a *predictive* scaling plan, optimizing cost and performance automatically, rather than only reacting after a metric crosses a threshold.

---

## 11. Creating an ASG — Console steps

1. Sign in to the AWS Management Console.
2. Navigate to the **EC2 Auto Scaling** console.
3. **"Auto Scaling Groups"** (left navigation) → **"Create Auto Scaling Group."**
4. Choose a **Launch Template** (or an old Launch Configuration, if you still have one) → select it from the list.
5. Configure ASG details — group name, network settings (VPC/subnets), initial capacity.
6. Configure scaling policies — based on CloudWatch alarms.
7. Configure Instance Protection (optional).
8. Configure Notifications (optional) — Amazon SNS.
9. Configure Tags (optional).
10. Review the configuration → **"Create Auto Scaling Group."**

The ASG will now launch and manage instances automatically, based on everything you just configured.

---

## 12. Testing scale-out live — spiking CPU on purpose

A practical way to actually *see* a Target Tracking policy react, instead of just reading about it:

```
yes > /dev/null &
```
Runs the `yes` command (which prints `y` forever) in the background, piped to nowhere — a simple, harmless way to peg one CPU core at 100% on demand.

```
kill -9 process-id
```
Stops that process once you're done testing — find its `process-id` with `ps -ef | grep yes` first.

**Real-time example:** Running `yes > /dev/null &` on an instance behind a Target-Tracking ASG (targeting, say, 50% CPU) is exactly how you'd demo or verify that scaling actually works — watch the ASG's console as it detects the CPU spike and launches new instances, then `kill -9` the process and watch it scale back in once CPU drops.

---

## 13. Example scenario

```
Min capacity      = 2
Desired capacity  = 4
Max capacity      = 10

Traffic increases → ASG scales to 7
Traffic drops     → ASG scales back to 4
An instance fails → ASG launches a new one automatically
```

---

## 14. Health check behavior

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
| Target Tracking / Simple / Step / Scheduled scaling | Four ways to trigger scaling | Keep CPU at 50%; scale at fixed thresholds; scale by time of day |
| Launch Configuration vs Launch Template | Old vs recommended ASG blueprint | New accounts can't create Launch Configurations anymore — use Templates |
| Scaling adjustment | How many instances to add/remove per trigger | "Add 2 instances" when CPU crosses 70% |
| Cool down period | Wait time after scaling before reacting again | Preventing an ASG from over-launching during one CPU spike |
| Auto Scaling Plans | Predictive scaling from historical data | Pre-scaling up before a known daily traffic pattern hits |
| `yes > /dev/null &` | Peg a CPU core at 100% on purpose | Testing/demoing that a Target Tracking policy actually scales out |
| ASG + SNS notification | ASG alerts a team when it scales | On-call gets an SMS the moment a new instance is added |
