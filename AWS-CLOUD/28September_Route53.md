# Batch 18 — AWS Cloud Running Notes: 28 September 2026

**Topic: Amazon Route 53 (DNS)**

Friends, on 25 September we got our RDS database up and reachable via its own AWS-generated endpoint (`23September_Databases.md` / `25September_RDS.md`). Today's topic — **Route 53** — is what does the same job for your *application*: giving users a clean, memorable domain name (`myapp.com`) instead of an ALB's long auto-generated DNS name or a raw IP.

---

## 1. What is Route 53?

- **Amazon Route 53** = AWS's scalable, highly-available **DNS (Domain Name System)** service.
- **DNS** = the system that converts human-readable domain names into IP addresses.

**Example:**
```
You type:        www.myapp.com
DNS converts to: 54.23.10.8   (the actual server/resource IP)
```

Route 53 does four things: registers domain names, hosts DNS records, routes traffic to your applications, and health-checks endpoints so it can route around a failure.

---

## 2. Why the name "Route 53"?

- **53** = the standard port number DNS uses (both UDP and TCP) — the name is a direct reference to that.

**Easy memory trick:** DNS lives on port 53 — "Route 53" is literally "route [traffic over port] 53."

---

## 3. What can Route 53 do?

1. **Domain Registration** — buy a domain directly (e.g. `myapp.com`).
2. **DNS Hosting** — create DNS records: A, AAAA, CNAME, Alias, MX, TXT, and more.
3. **Route Traffic** — to EC2, Load Balancers, S3 static websites, CloudFront, or even external (non-AWS) servers.
4. **Health Checks** — detect an unhealthy endpoint and stop sending traffic to it.
5. **Traffic Routing Policies** — distribute traffic across endpoints based on business rules (§5 below).

---

## 4. Common DNS record types in Route 53

| Record | Maps | Example |
|---|---|---|
| **A** | Domain → IPv4 address | `myapp.com → 54.10.20.30` |
| **AAAA** | Domain → IPv6 address | — |
| **CNAME** | Alias → another domain name | `api.myapp.com → backend.myapp.com` |
| **Alias** | AWS-specific — domain → an AWS resource, no IP involved | `myapp.com → ALB / CloudFront / S3` |
| **MX** | Domain → mail servers | Routing email for the domain |
| **TXT** | Verification / metadata text | DKIM, SPF, Google site verification |

**Alias vs CNAME — why Route 53 has both:** a plain CNAME can't be used on a **zone apex** (the bare domain, e.g. `myapp.com` with no `www.` or subdomain) — that's a rule from the DNS standard itself, not an AWS limitation. AWS's **Alias record** is built specifically to get around this: it works at the zone apex, points directly at AWS resources like an ALB, CloudFront distribution, or S3 website endpoint, automatically follows that resource's IP if it ever changes, and — unlike a CNAME — Route 53 doesn't charge for Alias queries to AWS resources.

**Easy memory trick:** CNAME → for any subdomain, points to another *name*. Alias → Route 53's own upgrade, works even at the bare domain, points straight at an *AWS resource*.

---

## 5. Routing policies

1. **Simple Routing** — one domain → one endpoint. No logic, no weighting.
2. **Weighted Routing** — split traffic by percentage (e.g. 70% to v1, 30% to v2 — classic canary/blue-green pattern).
3. **Latency-Based Routing** — sends the user to whichever region gives them the lowest latency.
4. **Failover Routing** — primary endpoint stays active; Route 53 switches to the backup only when the primary fails its health check.
5. **Geolocation Routing** — routes based on the user's actual country/location.
6. **Geoproximity Routing** — region-based routing, with a "bias" you can tune to shift more or less traffic toward a given region.
7. **Multi-Value Answer** — returns several healthy IPs in response to one query, giving simple client-side load distribution.

**Easy memory trick:** think of these as answers to different questions — Simple ("only one option"), Weighted ("what % to each"), Latency ("which is fastest"), Failover ("what if the main one dies"), Geolocation/Geoproximity ("where is the user"), Multi-Value ("give me a few healthy choices").

---

## 6. Real-time example — routing a production website through Route 53

**Scenario:** a production website hosted in AWS.

**Architecture:**
```
ALB (Application Load Balancer)
   │
   ▼
EC2 instances behind the ALB

Domain purchased: myapp.com
```

**Steps:**

**1) Buy the domain in Route 53**
```
myapp.com
```

**2) Create a Hosted Zone**
- Auto-created for you the moment you register the domain through Route 53.
- A **Hosted Zone** is simply the container that holds all the DNS records for that domain.

**3) Create a DNS record**
```
Record type: A or Alias
myapp.com → ALB DNS name

Example:
myapp.com → myapp-alb-123.amazonaws.com
```

**4) A user accesses the website**
```
User types myapp.com
        │
        ▼
Route 53 resolves the domain
        │
        ▼
Points to the ALB
        │
        ▼
ALB forwards the request to the EC2 backend servers
```

**5) Health check (optional but recommended)**
- Route 53 monitors the EC2 instances/ALB.
- If an instance turns unhealthy, Route 53 stops routing traffic to it.

This ties directly into everything covered so far: Route 53 sits **in front of** the same ALB → EC2 (Auto Scaling Group) → RDS stack built in the mini project and in `25September_RDS.md` — it's the layer that gives that whole stack a human-friendly front door.

---

## 7. Why Route 53 matters for DevOps

- Used in nearly every real production application — domain-to-application mapping is a basic requirement, not optional.
- Pairs directly with: S3 static websites, CloudFront, ALB/NLB, multi-region deployments, and disaster-recovery setups.
- Health checks + Failover routing are a standard, low-effort way to build basic DR (disaster recovery) into an architecture — Route 53 automatically stops sending users to a dead primary.

---

## 8. Simple summary

```
Route 53 = DNS + Traffic Routing + Domain Registration
```
- Converts domain names into IP addresses (or, via Alias, straight into AWS resources).
- Routes users to the correct AWS resource, using whichever routing policy fits the business need.
- Essential for hosting any real website or API in AWS.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Route 53 | AWS's DNS + domain registration + traffic-routing service | `myapp.com → ALB DNS name` |
| Port 53 | The DNS port the service is named after | Every DNS query, over UDP/TCP |
| A Record | Domain → IPv4 address | `myapp.com → 54.10.20.30` |
| CNAME | Alias → another domain name (not usable at the zone apex) | `api.myapp.com → backend.myapp.com` |
| Alias Record | AWS-only record, works at the zone apex, free queries to AWS resources | `myapp.com → ALB / CloudFront / S3` |
| Hosted Zone | The container holding all DNS records for a domain | Auto-created when you register a domain in Route 53 |
| Weighted Routing | Split traffic by percentage across endpoints | 70% to v1, 30% to v2 — canary releases |
| Failover Routing | Automatic switch to backup when primary fails a health check | Basic disaster-recovery setup |
| Health Check | Route 53 monitors an endpoint's health | Stops routing to an EC2/ALB that's gone unhealthy |
| Route 53 in the stack | Sits in front of the whole ALB → EC2 → RDS architecture | Gives the mini-project stack a real domain name |
