# Batch 18 — AWS Cloud Running Notes: 4 September 2026

**Topic: Installing Packages & Managing Services (`yum`, `systemctl`), The `vim` Editor, Setting Up a Web Server by Hand, Load Balancers (ALB / NLB / GWLB), Target Groups, User Data Scripts**

Friends, yesterday we covered EFS and a few basic file/folder commands. Today we go further on the Linux side — installing packages, controlling services, and editing files with `vim` — by using all of it together to stand up a real web server by hand. Then the two big AWS topics: **Load Balancers** — how AWS spreads traffic across many servers instead of just one — and **User Data** — the auto-setup script that configures a brand-new EC2 instance the moment it launches, with zero manual work.

---

## 1. Setting up a web server by hand — `yum`, `systemctl`, `vim`, `cat`

- **`yum install pkg-name`** — installs a package using the `yum` package manager (RHEL/Amazon Linux). Example: `sudo yum install httpd -y` installs Apache.
- **`systemctl start service.name`** — starts a service right now. Example: `sudo systemctl start httpd`.
- **`systemctl stop service.name`** — stops a running service.
- **`systemctl status service.name`** — checks whether a service is currently running, and shows its recent activity.
- **`systemctl restart service.name`** — stops and starts a service again, typically after a config change.
- **`systemctl enable service.name`** — makes the service start automatically on every future reboot. This is separate from `start`, which only starts it *right now*.
- **`vim fname`** — opens (or creates) a file in the `vim` editor. Press `i` to enter **Insert mode** and start typing; press `Esc` then type `:wq!` to save and force-quit.
- **`cat fname`** — prints a file's contents to the screen, to quickly confirm what you just saved.

**Real-time example — installing and running a web server, end to end:**
```
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl status httpd
sudo systemctl enable httpd
vim /var/www/html/index.html
```
`yum install` gets Apache (`httpd`) onto the server, `systemctl start` runs it right now, `status` confirms it's actually up, and `enable` makes sure it comes back automatically if the server ever reboots. `vim /var/www/html/index.html` is where you'd write the actual page Apache serves — this exact sequence is the standard, by-hand way any Linux web server gets installed, configured, and kept running.

**Easy memory trick:** `systemctl start` → "run it now." `systemctl enable` → "and keep running it, forever, even after a reboot."

---

## 2. What is a Load Balancer?

- A **Load Balancer** distributes incoming traffic across **multiple servers** (EC2 instances), instead of sending everything to just one.
- It's there to ensure:
  - High availability.
  - Fault tolerance.
  - Better performance.
  - Zero downtime during failures.

**Simple meaning:** instead of one server taking all the traffic (and being a single point of failure), the load balancer spreads it across many.

**Real-time example:** With 3 EC2 instances running the same web app behind a load balancer, if one instance crashes, the load balancer simply stops sending it traffic and routes everyone to the remaining two — users never notice, and nobody has to manually intervene at 2 AM.

---

## 3. Types of load balancers in AWS

AWS offers 4 types — 3 modern ones you'll use almost always, plus one older type:

1. **ALB** — Application Load Balancer.
2. **NLB** — Network Load Balancer.
3. **GWLB** — Gateway Load Balancer.
4. **Classic Load Balancer** — the original, older type, mostly legacy at this point.

### ALB — Application Load Balancer

- Operates at **Layer 7** (HTTP/HTTPS) — it actually understands the **content** of HTTP requests.
- Used for web applications and microservices.
- Supports:
  - Path-based routing (e.g. `/login` → server1).
  - Host-based routing (e.g. `api.example.com`).
  - Query/header-based routing.
  - URL-based routing.
  - WebSockets.
  - TLS termination (HTTPS).
  - Redirects / fixed responses.
- **Best for:** web apps, APIs/microservices, and anything that needs routing based on URL or domain.

### NLB — Network Load Balancer

- Operates at **Layer 4** (TCP/UDP) — the fastest, highest-performance option.
- Handles millions of requests per second.
- Used for low-latency, real-time traffic.
- Supports:
  - TCP / UDP / TLS.
  - A static IP.
  - Cross-zone balancing.
  - High network throughput.
- **Best for:** gaming, real-time apps, high-performance workloads, and load balancing non-HTTP traffic.

### GWLB — Gateway Load Balancer

- Operates at **Layer 3** (the network layer).
- Used specifically for security appliances — firewalls, IDS/IPS systems, packet inspection tools.
- **Best for:** inserting a firewall between VPCs, or centralizing traffic inspection.

### When to use which?

- **ALB** → websites, APIs, HTTP/HTTPS.
- **NLB** → high-performance TCP/UDP.
- **GWLB** → firewalls, deep packet inspection.

**Easy memory trick:** Layer number roughly tells you the job — 7 (ALB) understands the actual web request, 4 (NLB) just moves raw TCP/UDP fast, 3 (GWLB) inspects packets for security.

---

## 4. ALB — configuration options

**1) Basic configuration:**
- Name.
- Scheme — Internet-facing or Internal.
- IP address type — IPv4, or Dualstack (IPv4 + IPv6).
- VPC selection.

**2) Network mapping:**
- Select subnets across multiple Availability Zones.
- Enable/disable cross-zone load balancing.

**3) Listeners:**
- Example listeners: HTTP (`80`), HTTPS (`443`).
- Each listener needs: one or more rules, and a default target group.

**4) SSL certificates (for HTTPS):**
- An ACM (AWS Certificate Manager) certificate.
- TLS version.
- Security policies.

**5) Routing rules — you can create:**
- Path-based rules — e.g. `/app1` → `TG-App1`, `/app2` → `TG-App2`.
- Host-based rules — e.g. `api.example.com` → `API-Target-Group`.
- Header-based routing.
- Query-string routing.
- HTTP method filters.
- Redirect actions.
- Fixed responses.

**6) Security settings:**
- Security groups — allow port `80`/`443`.
- Idle timeout.
- Access logs — stored in S3.

**Real-time example:** Path-based routing (`/api` → one target group, everything else → another) is exactly how a single ALB fronts both a web app and its backend API on the same domain, without needing two separate load balancers.

---

## 5. Target Group — configuration options

A **Target Group** is where the load balancer actually sends traffic.

**1) Target type:**
- Instances (EC2 directly).
- IP addresses (e.g. microservices on ECS/EKS).
- Lambda functions.

**2) Protocol & port:**
- HTTP / HTTPS — for ALB.
- TCP / UDP / TLS — for NLB.
- A separate health check port.
- The actual traffic port.

**3) Health checks:**
- Protocol — HTTP, HTTPS, or TCP.
- Health check path (for ALB) — e.g. `/health`, `/status`.
- Success codes — e.g. `200`, `302`.
- Interval — default 30 seconds.
- Healthy threshold / Unhealthy threshold.
- Timeout, in seconds.

**4) Advanced health check features:**
- Deregistration delay.
- Slow start.
- Stickiness (session persistence).
- Matcher codes.
- Per-target health check override.

**5) Registered targets:**
- Select EC2 instances, IPs, or register Lambda functions directly.

**Real-time example:** If `/health` on an instance stops returning `200`, the target group marks it **unhealthy** and the load balancer stops sending it traffic automatically — this is exactly how a crashed or overloaded server gets quietly taken out of rotation without anyone paging on-call at 3 AM.

**Easy memory trick:** Load Balancer decides *how* to route. Target Group is *who* actually receives the traffic, and whether they're currently healthy enough to receive it.

---

## 6. Load balancer — summary

- A load balancer distributes traffic across multiple servers to ensure availability, performance, and reliability.
- **ALB** works at Layer 7, for HTTP/HTTPS.
- **NLB** works at Layer 4, for fast TCP/UDP traffic.
- **GWLB** works at Layer 3, for firewalls and security appliances.
- A **target group** is where the load balancer sends traffic — it defines health checks, ports, targets, and routing rules.

---

## 7. What is User Data in AWS?

- **User Data** is a script that runs automatically when an EC2 instance **launches**.
- It's used to automate the server's **initial setup** — no manual login required just to get it ready.

**What User Data can do:**
- Install software (Apache, Nginx, Java, Python).
- Update packages.
- Create files or directories.
- Configure applications.
- Start services.
- Download code from GitHub/S3.
- Set environment variables.

**Common User Data script (Linux):**
```bash
#!/bin/bash

yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
echo "THIS IS SAMPLE FACEBOOK PAGE" > /var/www/html/index.html
```
Notice there's no `sudo` in front of any command here — User Data itself already runs **as root**, so it doesn't need it.

**Important points:**
- Runs only on the **first boot** (unless specifically reconfigured to run again).
- Runs as the **root** user.
- Stored in the EC2 instance's **metadata**.
- Helps fully automate server provisioning — no manual setup step needed after launch.

**Simple meaning:** User Data = an "auto-setup script" for your EC2. The moment the instance starts, AWS runs your script automatically, so you don't configure the server by hand.

**Real-time example — tying today's two topics together:** When you launch an EC2 instance, you can paste this exact script into the **User Data** field during setup. Combined with an ALB and Target Group in front of it, every new instance launches, installs and starts `httpd` on its own, and gets registered as healthy — completely hands-off, from "instance launched" to "serving requests," with nobody logging in to configure it by hand.

**Easy memory trick:** User Data → what the server does to itself, automatically, the very first time it wakes up.

---

## Quick Recap Table

| Command / Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `yum install pkg -y` | Install a package | Installing `httpd`, `java`, `git`, etc. |
| `systemctl start/status/enable service` | Run a service now / check it / keep it running after reboot | Standing up and persisting a web server like `httpd` |
| `vim fname` | Edit a file interactively | Writing `index.html` on a web server |
| Load Balancer | Spreads traffic across multiple EC2 instances | Removing a single point of failure from a web app |
| ALB (Layer 7) | HTTP/HTTPS-aware load balancing | Path/host-based routing for web apps and APIs |
| NLB (Layer 4) | Fast TCP/UDP load balancing | Gaming, real-time, high-throughput workloads |
| GWLB (Layer 3) | Routes traffic through security appliances | Inserting a firewall between VPCs |
| Target Group | Where the load balancer actually sends traffic | Health checks automatically pull an unhealthy server out of rotation |
| Health check (`/health`, interval, threshold) | Confirms a target is actually working | Detecting and removing a crashed instance from traffic |
| User Data | Auto-setup script run on an EC2's first boot | Installing and starting `httpd` with zero manual login |
