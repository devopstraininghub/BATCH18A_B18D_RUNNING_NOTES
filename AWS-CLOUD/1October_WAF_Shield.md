# Batch 18 — AWS Cloud Running Notes: 1 October 2026

**Topic: AWS WAF + AWS Shield**

Friends, we now have CloudFront and ALB handling delivery and traffic distribution, and Security Groups controlling *who* can connect (`30September_CloudFront.md`, `17September_MiniProject.md`). Today's topic closes the remaining gap: Security Groups only look at IP/port — they can't tell a legitimate `GET /` from a SQL-injection attempt riding on the same port 443. **AWS WAF** and **AWS Shield** are the two services that inspect the *actual content and pattern* of the traffic itself, not just where it's coming from.

---

## 1. What is AWS WAF?

- **AWS WAF** = AWS **Web Application Firewall** — protects web applications and APIs from unwanted HTTP/HTTPS requests.
- Works mainly at the **application layer (Layer 7)** — it looks inside the request, not just at IP/port like a Security Group does.
- WAF can inspect: IP address, country, URI, HTTP method, query string, headers, cookies, request body, string patterns, regular expressions, SQL-injection patterns, cross-site-scripting patterns, and request rate.
- WAF can take one of these actions on a matched request: **ALLOW, BLOCK, COUNT, CAPTCHA, CHALLENGE.**

---

## 2. What is AWS Shield?

- **AWS Shield** = AWS's **DDoS (Distributed Denial of Service)** protection service — a DDoS attack tries to overwhelm a service with a flood of malicious or unwanted traffic.
- Two tiers:

| | Shield Standard | Shield Advanced |
|---|---|---|
| Availability | **Automatic**, for every AWS customer, at no extra cost | Must be **explicitly enabled** per resource (or via a Firewall Manager policy) |
| Protects against | Common network/transport-layer (L3/L4) DDoS attacks | Broader DDoS protection + visibility, monitoring, and response tooling |
| Supported resources | Baseline protection across AWS | CloudFront, Route 53 hosted zones, Global Accelerator, EC2 Elastic IPs (and EC2 via EIP), ALB, Classic LB, NLB (via EIP) |

⚠️ **Shield Advanced does NOT automatically protect every resource in your account** — you must explicitly add each resource, or have AWS Firewall Manager managing it through a Shield Advanced policy.

---

## 3. WAF vs Shield — two different jobs

| | AWS WAF | AWS Shield |
|---|---|---|
| Purpose | Web application / HTTP(S) request filtering | DDoS protection |
| Layer | Mainly Layer 7 | Mainly L3/L4, with some L7 capability (Shield Advanced) |
| Examples | IP blocking, SQLi/XSS protection, rate limiting, geo restriction | Network/transport-layer flood detection and mitigation |
| Has "rules" like WAF's? | Yes | Not in the traditional WAF-rule sense |

**Easy memory trick:** `WAF = inspects WHAT is being asked`. `Shield = defends against being FLOODED.`

**Used together, a common architecture:**
```
Internet → AWS Shield (DDoS protection) → AWS WAF (Protection Pack) → ALB → Application
```

---

## 4. The new AWS WAF console — "Protection Pack"

- AWS has an **updated console experience** alongside the original/standard one.
- The new console introduces the term **"Protection pack (web ACL)"** — but this is **not** a new underlying technology. At the API level it's still an ordinary **AWS WAFv2 Web ACL**; the new console just adds simplified configuration, guided workflows, protection templates, and unified dashboards on top of the same thing.

**Easy memory trick:** `Protection Pack = Web ACL` — new name, same underlying object.

---

## 5. What is a Web ACL?

- **Web ACL = Web Access Control List** — a collection of rules that determines what AWS WAF does with each incoming request.

**Example structure:**
```
Web ACL
  ├── Rule 1: Block Bad IPs
  ├── Rule 2: AWS Common Rules (managed rule group)
  ├── Rule 3: SQL Injection protection
  ├── Rule 4: Rate Limit
  ├── Rule 5: Country Restriction
  └── Default Action (what happens if nothing above matches)
```

**Basic WAF architecture:**
```
INTERNET → CLIENT → HTTP/HTTPS → AWS WAF (Protection Pack / Web ACL)
                                       │
                          ┌────────────┴────────────┐
                        BLOCK                      ALLOW
                          │                           │
                        HTTP 403                     ALB → APPLICATION
```
WAF examines the request **before** it ever reaches the protected resource.

---

## 6. What resources can WAF and its scope cover?

**WAF-supported resources include:** ALB, CloudFront, API Gateway, AWS AppSync, Amazon Cognito, App Runner, Amplify, Bedrock AgentCore Gateway, AWS Verified Access.

⚠️ **Important region/scope rule:**

| Resource type | WAF scope must be... |
|---|---|
| Regional resource (e.g. **ALB**) | The **same region** as the resource itself |
| **CloudFront** | **Global/CloudFront scope**, which AWS WAF implements using **US East (N. Virginia) / `us-east-1`** |

This mirrors the exact same `us-east-1` rule already seen for ACM-with-CloudFront in `29September_ACM.md` §19 — worth remembering as one consistent pattern: *anything tied to CloudFront's control plane lives in `us-east-1`, regardless of where the rest of your infrastructure actually runs.*

---

## 7. Hands-on — creating a Protection Pack (Web ACL) for an ALB

**Step 1 — Open AWS WAF**
```
AWS Console → search "WAF & Shield" → open AWS WAF → select the correct Region
→ Resources & protection packs (web ACLs)
```
For an ALB, select the **same region as the ALB.**

**Step 2 — Start the guided workflow**
```
Add protection pack (web ACL)
   → Tell us about your app
   → Resources to protect
   → Choose initial protections
   → Configure protection
   → Review
   → Add protection pack
```

**Step 3 — Tell AWS about your app**
- **App category** — pick whatever best describes the application.
- **Traffic source** — `API`, `Web`, or `Both API and Web` (e.g. a website with REST APIs behind it → **Both**).

**Step 4 — Add resources to protect**
```
Resources to protect → Add resources → Regional resources →
Application Load Balancer → select your ALB → Add
```

**Step 5 — Choose initial protections**

| Option | What it means | Best for |
|---|---|---|
| **Recommended** | AWS suggests a configuration based on the app info you gave it | Beginners, testing, initial deployment |
| **Essentials** | A more basic, minimal protection set | Lightweight starting point |
| **You build it** | You configure every rule yourself | Learning IP rules, rate rules, managed groups, geo rules, string matching, custom rules — hands-on understanding |

**Step 6 — Name it**
```
Name:        <your-protection-pack-name>
Description: AWS WAF protection pack for ALB testing
```
⚠️ Choose the name carefully — it has restrictions and should be treated as a near-permanent identifier for this configuration.

**Step 7 — Set the Default Action**
```
DEFAULT ACTION = ALLOW
```
Meaning: if no rule in the Web ACL explicitly blocks/challenges the request, it's allowed through.
```
Client → AWS WAF → Rule 1 → Rule 2 → Rule 3 → no blocking match → ALLOW → ALB
```

---

## 8. Anatomy of a WAF rule

Every rule has three parts: **statement/condition, action, priority.**

**Example:**
```
Rule Name:  Block-Bad-IP
Condition:  Source IP exists in an IP Set
Action:     BLOCK
```

**The five possible rule actions:**

| Action | Effect |
|---|---|
| **ALLOW** | Lets the request through |
| **BLOCK** | Rejects it — client typically receives **HTTP 403 Forbidden** |
| **COUNT** | Counts matching requests but doesn't block them — your main tool for safely testing a new rule |
| **CAPTCHA** | Makes the client solve a CAPTCHA before continuing |
| **CHALLENGE** | Verifies the request is coming from a legitimate client, without a visible CAPTCHA |

**Rule priority:** AWS WAF evaluates rules in priority order; a terminating action (ALLOW/BLOCK/CAPTCHA/CHALLENGE) can stop further evaluation — exact behavior depends on how each rule/statement is configured.

---

## 9. AWS Managed Rule Groups

- AWS provides **pre-built rule groups** so you don't have to hand-write detection logic for well-known attack patterns.

**Common ones:**
```
AWSManagedRulesCommonRuleSet            — general common web-attack patterns
AWSManagedRulesKnownBadInputsRuleSet    — known-bad request patterns
AWSManagedRulesSQLiRuleSet              — SQL injection
AWSManagedRulesAmazonIpReputationList   — IPs with a poor reputation
AWSManagedRulesAnonymousIpList          — VPNs/proxies/Tor-type anonymizing IPs
```

**Flow:**
```
Client → AWS WAF → Common Rule Set → Match → BLOCK
                                   → No Match → Continue
```

---

## 10. IP Sets and custom IP-block rules

- An **IP Set** = a named collection of IP addresses/CIDR ranges that a WAF rule can reference.

**Example:**
```
IP Set:     test-block-ip
Addresses:  203.0.113.25/32
            10.10.10.0/24
```

**Using it in a rule:**
```
Rule Name:  Block-Test-IP
Statement:  IP Set match
IP Set:     test-block-ip
Action:     BLOCK
```
```
Client IP → IP Set MATCH → Rule MATCH → BLOCK → HTTP 403
```

---

## 11. Geo Match rules

- WAF can inspect the **geographic origin** of a request (based on IP geolocation) and block/allow by country.

**Example:**
```
Rule:       Block-Country
Condition:  Country = XX
Action:     BLOCK
```
⚠️ Geo-location is derived from IP address geolocation — it's a reasonable signal, **not a guarantee** of the user's actual physical location (VPNs, proxies, and mobile carrier routing can all shift it).

---

## 12. Rate-based rules

- A **rate-based rule** blocks (or otherwise acts on) a client once it crosses a configured request-rate threshold over an evaluation window.

**Example:**
```
Limit:       1000 requests
Evaluation:  5 minutes
Action:      BLOCK
```
**Useful for:** HTTP flood mitigation, login-abuse prevention, API abuse, scraping, and general excessive-request protection.

---

## 13. SQL injection and XSS protection

- WAF detects these through its **managed rules** and/or dedicated rule statements — not something you typically write regex for by hand.
```
Request → SQL Injection / XSS Detection → Malicious pattern → BLOCK
                                        → Normal request    → Continue
```
⚠️ **Never run real attack payloads against systems you don't own or aren't explicitly authorized to test** — even for learning purposes.

---

## 14. WAF Logging — what you actually get

- WAF logs can include: client IP, country, HTTP method, URI, query arguments, headers, the **terminating rule**, the action taken, a request ID, and **JA3/JA4 TLS fingerprints.**

**Example log entry (redacted/placeholder values):**
```
terminatingRuleId:  test-block-ip
action:             BLOCK
clientIp:           203.0.113.25
uri:                /
httpMethod:         GET
```

**Reading it:** the client at `203.0.113.25` sent `GET /`, WAF matched it against the `test-block-ip` IP Set, executed **BLOCK**, and the client received **HTTP 403.**

**JA3/JA4 fingerprints** — identify patterns in a client's TLS handshake behavior. Useful signal, but **not a perfect identity mechanism** — a fingerprint can change, and different clients can share similar characteristics.

---

## 15. Understanding HTTP 403 — and why WAF isn't automatically the cause

- **HTTP 403 Forbidden** = the server understood the request but refused to authorize it.
- In WAF's case: `WAF BLOCK → HTTP 403`.

⚠️ **A 403 doesn't always mean WAF caused it.** It can equally come from: the application itself, the ALB, an authentication layer, a reverse proxy, API Gateway, CloudFront, or some other security control entirely. **Always check the logs** to identify the actual source before assuming it's WAF.

**403 troubleshooting checklist:**
1. Is AWS WAF even associated with this resource?
2. Check the WAF logs.
3. Find `terminatingRuleId`.
4. Check `action`.
5. Check `clientIp`.
6. Check the IP Set / Managed Rule Group / Rate-Based Rule that matched.
7. Check application/ALB logs too, to rule WAF *out* if needed.
8. Confirm the actual reason before changing anything.

**Worked example:**
```
clientIp:          203.0.113.25
terminatingRuleId: test-block-ip
action:            BLOCK
uri:               /
```
→ `test-block-ip` is the direct, confirmed reason this specific request was blocked.

---

## 16. WAF vs Security Group vs NACL — three different layers

| | Security Group | NACL | AWS WAF |
|---|---|---|---|
| Level | Connection/network | Subnet boundary | Web application / request |
| Example rule | Allow TCP 443 | Allow/deny traffic at the subnet | Block a SQL-injection pattern |
| Stateful? | Yes | No (stateless) | N/A — operates on request content |

**Full layered architecture, closing the loop from `30September_CloudFront.md` §20:**
```
Internet → Shield → WAF → ALB → Security Group → Targets
```
- **Security Group** controls *who can even open a connection.*
- **WAF** controls *what's allowed to be inside that connection's requests*, once it's open.
- They're complementary, not a replacement for one another — a real production setup uses both.

---

## 17. Shield Advanced — adding protection to a resource

**Steps:**
```
AWS WAF & Shield console → AWS Shield → Protected resources →
Add resources to protect → specify Region + Resource type →
Load resources → select the resource → add tags if needed →
Protect with Shield Advanced
```

**Example:**
```
Region:   us-east-1
Resource: Application Load Balancer (your ALB)
```

**Shield Advanced + WAF together** (for supported resources like CloudFront and ALB):
```
Internet → Shield Advanced → AWS WAF → ALB → Application
```

⚠️ Reiterating §2: Shield Advanced protects **only** what you explicitly add, or what's covered by a Firewall Manager Shield Advanced policy — never assume it's silently covering everything in the account.

---

## 18. AWS Firewall Manager — centralized policy management

- **Firewall Manager** lets you centrally manage WAF and Shield Advanced policies (and other supported security policies) across multiple AWS accounts, typically via AWS Organizations.
```
AWS Organizations → Firewall Manager → Account A (WAF) / Account B (WAF)
```
⚠️ If a WAF/Shield configuration is controlled by Firewall Manager, **don't assume you can independently modify or delete it** from inside the member account — it may be centrally enforced.

---

## 19. Testing WAF — the safe way

**Don't deploy an aggressive BLOCK rule straight into production.** The recommended path:
```
Test environment → WAF Rule → COUNT → Check logs → Tune rule → BLOCK
```
**For production specifically:**
```
Test → Count → Monitor → Tune → Block
```

**COUNT mode** is the key safety net here — it records matching requests without actually blocking them, so you can validate a rule against real traffic (metrics, logs, sample requests) *before* it can accidentally block legitimate users.

---

## 20. Hands-on — complete WAF test lab

**Objective:** protect an ALB with a test IP-block rule, safely.

1. Create or identify an ALB to protect.
2. Open **WAF & Shield**, select the correct **Region**.
3. Open **Resources & protection packs (web ACLs)**.
4. **Add protection pack (web ACL)** — set App Category + Traffic Source.
5. Add your **ALB** as the resource to protect.
6. Choose **"You build it."**
7. Set the **Default Action** to **ALLOW**.
8. Create an **IP Set** (e.g. `test-block-ip`) containing your own authorized test IP.
9. Create a rule, **Block-Test-IP**, referencing that IP Set.
10. Set its action to **COUNT** first (not BLOCK).
11. Send a test request from that IP.
12. Check the WAF logs — confirm the rule matched with `action = COUNT`.
13. Once confirmed safe, change the action to **BLOCK**.
14. Test again — expect **HTTP 403.**
15. Confirm in the logs: `terminatingRuleId = Block-Test-IP`, `action = BLOCK`.

This COUNT-then-BLOCK sequence is the same production best-practice pattern from §19 — just walked through end to end on a real ALB.

---

## 21. WAF metrics, WCU, and production best practice

- **WAF metrics** (via CloudWatch) give the aggregate picture: allowed/blocked/counted request counts, rule matches, rate-based rule activity. **Logs** give you the request-level detail. Use both together — metrics tell you *something* changed, logs tell you *why.*
- **WCU (Web ACL Capacity Unit)** — AWS WAF measures the "cost" of your rules and rule groups in WCUs; different rule types consume different amounts. ⚠️ Using more than **1,500 WCUs** in a Protection Pack can incur additional cost beyond the base Protection Pack price — worth monitoring capacity before stacking on many managed rule groups.

**Production best practice, in order:** create rules in staging/test → test them → start with COUNT where appropriate → review logs → monitor for false positives → tune → deploy carefully → keep monitoring after deployment. Never blindly enable aggressive blocking rules straight in production.

---

## 22. Deleting a Protection Pack / removing Shield Advanced

**If Delete is greyed out for a Protection Pack:**
```
Open Protection Pack → Resources to protect → check for an associated ALB/resource
→ remove/disassociate it → retry deletion
```
⚠️ If **Shield Advanced** is separately protecting the same resource, that protection must be removed **separately** — deleting a WAF Protection Pack does **not** also remove Shield Advanced protection. They're two independent things that happen to often sit on the same resource.

---

## 23. Useful AWS CLI commands

```bash
# List Web ACLs (regional scope, e.g. for an ALB)
aws wafv2 list-web-acls --scope REGIONAL --region us-east-1

# List Web ACLs (CloudFront scope — always us-east-1)
aws wafv2 list-web-acls --scope CLOUDFRONT --region us-east-1

# List IP Sets
aws wafv2 list-ip-sets --scope REGIONAL --region us-east-1

# Get details of a specific Web ACL
aws wafv2 get-web-acl --name <WEB-ACL-NAME> --scope REGIONAL --id <WEB-ACL-ID> --region us-east-1

# List resources protected by Shield Advanced
aws shield list-protections

# Check your Shield Advanced subscription
aws shield describe-subscription
```

---

## 24. Common mistakes worth avoiding

1. Creating the WAF Protection Pack in the **wrong region** (forgetting the ALB-region / CloudFront-`us-east-1` rule from §6).
2. **Blocking your own IP** by accident while testing.
3. Jumping straight to **BLOCK** without testing via COUNT first.
4. Forgetting an old IP Set rule is **still active** and quietly affecting traffic.
5. Ignoring **rule priority** and being surprised by evaluation order.
6. **Not checking WAF logs** before assuming the cause of an issue.
7. Assuming every 403 automatically comes from WAF (§15).
8. Forgetting **Shield Advanced protection is separate** from the WAF Protection Pack (§22).
9. Trying to delete a Protection Pack while **resources are still associated.**
10. Changing **production WAF rules without testing** first.

---

## 25. Full production security architecture

```
                         USERS
                           │
                      INTERNET TRAFFIC
                           │
                           ▼
                      AWS SHIELD
                    (DDoS protection)
                           │
                           ▼
                       AWS WAF
                  (Protection Pack / Web ACL)
                           │
                           ▼
                          ALB
                           │
                           ▼
                     Security Group
                           │
                           ▼
                    EC2 / Targets
                           │
                           ▼
                      APPLICATION
```

This is the natural extension of the layered security chain built up across the last few sessions: `30September_CloudFront.md` §20 (CloudFront's origin-facing prefix list locking the ALB-SG) and `25September_RDS.md` §15 (RDS-SG only trusting EC2-SG) — Shield and WAF simply slot in as two more layers, each solving a problem the layers around them can't.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| AWS WAF | Inspects and filters HTTP(S) requests at Layer 7 | Blocking SQL-injection attempts hitting an ALB |
| AWS Shield | DDoS protection — Standard (automatic) or Advanced (opt-in) | Shield Advanced explicitly added to a production ALB |
| Web ACL / Protection Pack | A collection of WAF rules; same object, two names (old vs new console) | `Protection Pack = Web ACL` under the hood |
| IP Set | Named collection of IPs/CIDRs a rule can reference | `test-block-ip` containing a test IP for a demo block rule |
| Rule actions | ALLOW / BLOCK / COUNT / CAPTCHA / CHALLENGE | Start new rules on COUNT, promote to BLOCK after validating |
| Managed Rule Group | AWS-maintained, pre-built protections | `AWSManagedRulesSQLiRuleSet` |
| Rate-based rule | Blocks a client once it exceeds a request-rate threshold | 1000 requests / 5 minutes → BLOCK |
| WAF region/scope rule | Regional resource → same region; CloudFront → `us-east-1` scope | Same pattern as ACM-for-CloudFront (`29September_ACM.md`) |
| `terminatingRuleId` | The log field that tells you exactly which rule caused a 403 | First thing to check in any WAF troubleshooting |
| WAF vs Security Group vs NACL | Three different layers — request content vs connection vs subnet | All three commonly used together, not as substitutes |
| Firewall Manager | Centrally manages WAF/Shield policies across accounts | A member account can't always independently edit its own WAF |
