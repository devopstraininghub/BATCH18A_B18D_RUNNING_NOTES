# Batch 18 — AWS Cloud Running Notes: 30 September 2026

**Topic: Amazon CloudFront (CDN)**

Friends, we now have the full stack: Route 53 for DNS (`28September_Route53.md`) and ACM for HTTPS (`29September_ACM.md`), sitting in front of the ALB → private EC2 → RDS project (`17September_MiniProject.md`, `25September_RDS.md`). Today's topic — **CloudFront** — adds one more layer in front of all of it: a **global CDN** that serves content from locations physically close to each user, instead of every single request traveling all the way back to your ALB in one AWS region.

---

## 1. What is Amazon CloudFront?

- **CloudFront** = AWS's **CDN (Content Delivery Network)** service.
- It delivers HTML, CSS, JavaScript, images, videos, APIs, dynamic content, and other HTTP/HTTPS content.
- CloudFront sits **between the user and the origin**:
```
User → CloudFront → Origin
```
- The **origin** (where the real content actually comes from) can be: S3, an ALB, an NLB, EC2/any HTTP server, API Gateway, or another supported HTTP origin.

**Easy definition:** `CloudFront = AWS's CDN service.`

---

## 2. What is a CDN, and why do we need one?

- **CDN = Content Delivery Network** — a distributed network of servers in different geographic locations, whose job is serving content from whichever location is physically closest to the requesting user.

**Without a CDN** — every user, regardless of location, goes all the way back to one origin:
```
India User     → USA Origin
UK User        → USA Origin
Australia User → USA Origin
```

**With a CDN** — each user is served from a nearby edge instead:
```
India User     → Nearby CloudFront Edge
UK User        → Nearby CloudFront Edge
Australia User → Nearby CloudFront Edge
```

**Benefits:** lower latency, faster content delivery, reduced load on the origin, a better global user experience, edge caching, HTTPS termination at the edge, AWS WAF integration, and DDoS protection through AWS's own infrastructure.

---

## 3. Point of Presence (POP) and Edge Location

- **POP (Point of Presence)** = a physical location where CloudFront has infrastructure to receive and serve viewer requests. AWS's own documentation uses "POP" and "edge location" essentially interchangeably.
- **Edge Location** = a CloudFront location close to users where content is cached and served.

```
User → Nearest CloudFront Edge → Cached Content
```
If the content is already cached at that edge, the **origin may not need to be contacted at all.**

**Easy memory trick:** `POP = LOCATION`, `EDGE = CONTENT DELIVERY LOCATION`.

---

## 4. Regional Edge Cache

- An **additional caching layer** sitting between the edge locations and the origin.

```
User → Edge Location → Regional Edge Cache → Origin
```

- **Edge Location:** very close to viewers, handles the actual viewer request, caches content.
- **Regional Edge Cache:** a larger regional layer that keeps content closer to viewers even when it isn't "popular" enough to stay cached at a specific edge location.

---

## 5. Origin, and CloudFront Distribution

- **Origin** = the source CloudFront pulls the original content from (S3, ALB, EC2, API Gateway, etc.). **For our project, the origin is the Application Load Balancer.**
```
CloudFront → ALB → EC2 → Apache
```
- **Distribution** = the actual CloudFront *configuration* — where content comes from, how users access it, how requests are cached, which protocols/HTTP methods are allowed, which domain and SSL certificate are used, security and logging configuration, all of it.
- Every distribution gets a default CloudFront domain name, e.g. `d123456abcdef.cloudfront.net`.

**Basic architecture:**
```
                    USERS
                      │
                      ▼
                 CLOUDFRONT
                      │
          ┌───────────┴───────────┐
          ▼                       ▼
    EDGE LOCATION           EDGE LOCATION
          └───────────┬───────────┘
                       ▼
               REGIONAL EDGE CACHE
                       │
                       ▼
                     ORIGIN (ALB)
                       │
                       ▼
                      EC2
```

---

## 6. Adding CloudFront to our project's architecture

**Before CloudFront:**
```
Internet → ALB → Private EC2 → Apache
```

**After CloudFront:**
```
User → CloudFront → ALB → Private EC2 → Apache
```
- **CloudFront becomes the public entry point.**
- **The ALB becomes the origin**, no longer the first thing the Internet touches.

**Project specifics (our stack):**
```
VPC:  prod-vpc (10.81.0.0/16)
Public:  ALB, NAT Gateway
Private: Amazon Linux EC2 running Apache
App: Mind Circuit
```

**Benefits of adding CloudFront in front of the existing ALB:** global content delivery, edge caching, fewer repeated requests hitting the ALB, lower latency for cacheable content, HTTPS handled at CloudFront, AWS WAF integration, reduced load on the origin overall.

---

## 7. CloudFront request flow

**User requests:** `https://example.com/index.html`

1. DNS directs the request to CloudFront.
2. CloudFront receives the viewer request.
3. CloudFront determines the nearest appropriate edge location.
4. CloudFront checks its cache — **Cache Hit** if found, **Cache Miss** if not.
5. On a cache miss, CloudFront requests the content from the origin.
6. The origin returns the response.
7. CloudFront returns the response to the user.
8. CloudFront may cache that response, according to the configured cache behavior/policy, for next time.

---

## 8. Caching — Cache Hit, Cache Miss, and Cache Hit Ratio

- **Caching** = temporarily storing content so it can be served faster on the next request.

**First request (cache miss):**
```
User → CloudFront → ALB → EC2 → index.html   (CloudFront stores the response)
```
**Second request (cache hit):**
```
User → CloudFront → Cached index.html   (ALB/EC2 not contacted again)
```

| | Cache Hit | Cache Miss |
|---|---|---|
| Meaning | Content already in CloudFront's cache | Content not currently cached/valid |
| Flow | `User → CloudFront → Cached Object → User` | `User → CloudFront → Origin (ALB → EC2) → CloudFront caches + returns` |
| Result | Faster response, lower origin load, better scalability | Origin gets contacted, response is (usually) then cached for next time |

**Cache Hit Ratio** = `Cache Hits ÷ Total Requests`.

**Example:** 1000 total requests, 800 cache hits → **80% cache hit ratio.** A higher ratio generally means the origin is doing less work.

---

## 9. What's a good caching candidate, and what isn't

**Good candidates:** CSS, JavaScript, images, fonts, videos, static HTML, and public API responses where it's genuinely safe to do so.
```
/css/style.css
/js/app.js
/images/logo.png
/images/product.jpg
```

**Be careful with:** personalized pages, login pages, user-specific content, shopping carts, dynamic authenticated API responses, and any frequently-changing data. Caching these incorrectly is a real correctness/security risk — covered in §16.

---

## 10. Cache Key

- The **cache key** is what CloudFront uses to decide whether a requested object matches something already cached.
- Can include: URL path, query strings, headers, cookies, and other configured values.

**Example:** if the query string is part of the cache key, `/product?id=100` and `/product?id=200` are treated as two entirely different cached objects — not the same one.

---

## 11. Cache Policy vs Origin Request Policy — the most important distinction here

This is exactly the kind of thing that's easy to mix up, so it's worth being precise:

| | Cache Policy | Origin Request Policy |
|---|---|---|
| Controls | What identifies a cached object (the **cache key**) | What CloudFront actually **sends to the origin** |
| Includes | Cache key components, TTL (min/default/max), compression settings | Headers, cookies, query strings forwarded to origin |
| Question it answers | "Is this the same object I already have cached?" | "What information does the origin need to process this?" |

**Why AWS keeps these separate:** you can forward information to the origin (say, an `Authorization` header) *without* that information becoming part of the cache key — otherwise every unique header value would create a separate cached copy, destroying your cache-hit ratio.

**Easy memory trick:** `Cache Policy = CACHE DECISION`. `Origin Request Policy = ORIGIN REQUEST`.

**Simple cache-policy example:** for `/images/logo.png`, you don't need cookies, query strings, or Authorization headers in the cache key — keeping the cache key small means many different users all hit the *same* cached object, maximizing reuse.

---

## 12. TTL (Time To Live)

- **TTL** controls how long CloudFront treats a cached object as valid before it needs to check back with the origin.

| TTL setting | Meaning | Example |
|---|---|---|
| **Minimum TTL** | The *least* amount of time an object stays cached before revalidation | 60 seconds |
| **Default TTL** | Used when the origin sends no `Cache-Control`/`Expires` header | 86400 seconds (24 hours) |
| **Maximum TTL** | The *most* amount of time an object can stay cached under the policy | 31536000 seconds (~1 year) |

⚠️ **Important gotcha:** if **Minimum TTL is greater than 0**, CloudFront can still cache content for at least that duration **even if** the origin's response says `no-cache`/`no-store`/`private`. Setting Minimum TTL to `0` is the safer default if you're not fully sure what the origin is sending.

- The origin's own **`Cache-Control` header** (e.g. `Cache-Control: max-age=3600`) works together with the cache policy's TTL settings to decide actual freshness.

**How to configure this:**
```
CloudFront Console → Distributions → select distribution → Behaviors →
select behavior → Edit → Cache key and origin requests → Cache Policy
```
You can pick an AWS-managed cache policy (covers most common cases) or create a custom one.

---

## 13. Cache Behavior — different rules for different paths

- A **Cache Behavior** tells CloudFront: *"for requests matching this path, use these specific rules."*

**Example — a realistic multi-behavior design:**

| Path pattern | Origin | Cache level | Notes |
|---|---|---|---|
| `/images/*` | Static/ALB | HIGH | Long TTL, small cache key |
| `/static/*` | Static/ALB | HIGH | Same idea — rarely-changing assets |
| `/api/*` | Application ALB | LOW / CUSTOM | Needs careful Origin Request Policy design |
| `*` (default) | ALB | — | Catches everything not matched above |

- The **default cache behavior** uses path pattern `*` — it's what applies when nothing more specific matches.
- CloudFront supports **multiple origins**, with each behavior choosing which origin serves its matching requests (e.g. `/images/*` could even point at a different origin than `/api/*`).

---

## 14. Viewer Protocol Policy vs Origin Protocol Policy

| | Viewer Protocol Policy | Origin Protocol Policy |
|---|---|---|
| Controls | How the **user** connects to CloudFront | How **CloudFront** connects to the **origin** |
| Options | HTTP and HTTPS / Redirect HTTP to HTTPS / HTTPS Only | HTTP Only / HTTPS Only / Match Viewer |
| Production recommendation | **Redirect HTTP to HTTPS** | **HTTPS Only**, if the origin (ALB) has a working HTTPS listener + certificate |

```
http://example.com → CloudFront → Redirect to HTTPS → https://example.com
```

For a fully secure path end to end: `Viewer → HTTPS → CloudFront → HTTPS → ALB` (see the TLS termination discussion in `29September_ACM.md` §18 — CloudFront now becomes the first point of termination, and the CloudFront-to-ALB hop is a second, separate TLS connection).

---

## 15. Allowed HTTP Methods and Compression

**Allowed HTTP Methods** — which methods CloudFront accepts and forwards to the origin:
- **Static website:** `GET`, `HEAD` is usually enough.
- **API:** may need `GET`, `HEAD`, `OPTIONS`, `PUT`, `POST`, `PATCH`, `DELETE`, depending on what the application actually does.

**Compression** — CloudFront can compress eligible content using **Gzip** or **Brotli**, shrinking what's sent to the viewer.
```
Large CSS → Compress → Smaller response → User
```
Benefits: faster downloads, lower bandwidth usage, better perceived page performance.

---

## 16. HTTPS, custom domains, and ACM — tying back to 28–29 September

- CloudFront supports HTTPS for the viewer-facing connection out of the box on its default `*.cloudfront.net` domain.
- For your **own** domain (e.g. `www.mindcircuit.com`), you need a **trusted ACM certificate** covering that domain — same ACM concepts as `29September_ACM.md`, with one CloudFront-specific rule:

⚠️ **For CloudFront specifically, the ACM certificate must be requested/imported in `us-east-1` (US East, N. Virginia) — no exceptions, regardless of which region your ALB or the rest of your infrastructure lives in.** This is one of the most commonly-asked AWS interview questions for exactly this reason — it's easy to forget since CloudFront itself is a global service.

**Custom domain flow, with Route 53:**
```
User → www.mindcircuit.com → Route 53 → CloudFront → ALB
```
- For a **subdomain** (`www.mindcircuit.com`), Route 53 points it at the CloudFront distribution.
- For the **apex/root domain** (`mindcircuit.com`), a plain CNAME can't be used (same DNS-standard rule as `28September_Route53.md` §4) — Route 53's **Alias record** is what makes this work at the apex too.

---

## 17. Hands-on — creating a CloudFront distribution (console walkthrough)

**Step 1 — Open CloudFront**
```
AWS Console → search "CloudFront" → open Amazon CloudFront → Create distribution
```

**Step 2 — Choose the origin**
```
Origin Type: Application Load Balancer
Origin: my-alb-123456.ap-south-1.elb.amazonaws.com
```
CloudFront gives this origin a name/identifier, e.g. `prod-alb-origin`.

**Step 3 — Origin Path (optional)**
- Leave empty for a normal ALB setup, unless your application specifically needs a path prefix (e.g. `/app`) added to every request CloudFront forwards.

**Step 4 — Origin connection (how CloudFront talks to the ALB)**
```
Recommended: HTTPS Only
```
Requires the ALB to already have a working HTTPS listener and valid certificate (`29September_ACM.md`).

**Step 5 — Default cache behavior**
```
Path pattern: *
Viewer Protocol Policy: Redirect HTTP to HTTPS
Allowed HTTP Methods: GET, HEAD (or more, for an API)
```

**Step 6 — Cache Policy** — pick an AWS-managed policy for a static site, or a custom one designed around your app's actual caching requirements.

**Step 7 — Origin Request Policy** — configure only if the origin needs specific headers/cookies/query strings (e.g. `Host`, `Authorization`, selected query strings) that shouldn't necessarily be part of the cache key.

**Step 8 — Allowed HTTP Methods** — set based on what the application needs (§15).

**Step 9 — Compression** — enable Gzip/Brotli.

**Step 10 — AWS WAF** — attach if required (§19).

**Step 11 — Custom domain + certificate** — add your alternate domain name(s) and the `us-east-1` ACM certificate, if using a custom domain.

**Step 12 — Create distribution.**

**Step 13 — Wait for status: `Deployed`.**

**Step 14 — Test** using the CloudFront domain, e.g. `https://d123456abcdef.cloudfront.net`.

---

## 18. Distribution-level settings worth knowing

- **Default Root Object** — the file CloudFront serves when a viewer requests the distribution root (`https://example.com/`). Typically `index.html`, so the root request effectively becomes `/index.html`.
- **Price Class** — controls *which set of edge locations* are used to serve your content, which affects both cost and geographic coverage: broader coverage generally costs more, narrower coverage costs less. Choose based on where your actual users are, your performance needs, and your budget — check current AWS pricing before a production decision.
- Other settings: alternate domain names, SSL/TLS certificate, IPv6, AWS WAF, logging, HTTP versions, enabled/disabled status.

---

## 19. AWS WAF + CloudFront

```
User → CloudFront → AWS WAF → ALB → EC2
```
- **AWS WAF** can be attached to a CloudFront distribution to filter out unwanted or malicious HTTP requests before they ever reach your origin.
- Common WAF use cases: IP filtering, rate limiting, AWS-managed rule groups, SQL-injection protection, cross-site-scripting protection, bot-related controls.

---

## 20. Security — locking the ALB down to CloudFront only

**This is one of the most important practical points in this module.** Just because CloudFront is in front of your ALB doesn't mean the ALB's own Security Group should stay wide open — if it still allows `0.0.0.0/0`, anyone can bypass CloudFront entirely and hit the ALB directly.

- AWS maintains an **AWS-managed prefix list** specifically for this:
```
com.amazonaws.global.cloudfront.origin-facing        (IPv4)
com.amazonaws.global.ipv6.cloudfront.origin-facing    (IPv6)
```
- AWS keeps this prefix list automatically updated as CloudFront's own IP ranges change — you reference the prefix list in your Security Group rule instead of hardcoding IPs yourself.

**Recommended ALB Security Group rule:**
```
ALB-SG
  Inbound: HTTPS, port 443, Source = CloudFront managed prefix list
```

**Full security-group chain for the complete stack** (this is the natural extension of the single-SG pattern discussed in `17September_MiniProject.md`, now properly layered):
```
CloudFront  →  ALB-SG   : Allow HTTPS (443) from the CloudFront origin-facing prefix list
ALB         →  EC2-SG   : Allow the application port from ALB-SG only
EC2         →  RDS-SG   : Allow TCP 3306 from EC2-SG only (see 25September_RDS.md §15)
```
Each hop only trusts the Security Group directly in front of it — never a broad CIDR — which is the same "source = another SG, not an IP range" principle from the RDS notes, now applied at every layer of the stack.

---

## 21. Logging and monitoring

- **CloudFront logging** records request-level detail: who accessed the application, which URL, when, what response was returned. Useful for troubleshooting, security analysis, traffic analysis, and auditing.
- **CloudFront monitoring** integrates with AWS's monitoring tools. Useful signals: request counts, bytes downloaded, error rates, cache hit/miss behavior, origin latency, and — especially when something's wrong — **4xx and 5xx error rates**.

---

## 22. Cache Invalidation — forcing CloudFront to drop stale content

- Suppose CloudFront has an old cached copy of `/index.html`, but you've just deployed an update — users would otherwise keep getting the stale version until it naturally expires.
- An **Invalidation** explicitly tells CloudFront: remove this object from every edge cache now, so the next request goes back to the origin for a fresh copy.

**Example:**
```
Old: "Welcome to Mind Circuit Facebook page"
New: "Welcome to Mind Circuit CloudFront page"

Invalidate: /index.html
```

**CLI:**
```bash
aws cloudfront create-invalidation \
    --distribution-id DISTRIBUTION_ID \
    --paths "/index.html"

# invalidate everything (use carefully — this hits every cached object):
aws cloudfront create-invalidation \
    --distribution-id DISTRIBUTION_ID \
    --paths "/*"
```

⚠️ **Invalidation ≠ TTL expiration** — these are two different mechanisms:
- **TTL** — the object naturally goes stale on its own schedule, per the cache policy.
- **Invalidation** — you're explicitly forcing early removal, right now, regardless of TTL.

---

## 23. Caching dynamic and personalized content — where it gets dangerous

- Static assets (`/index.html`, `/css/*`, `/js/*`, `/images/*`) are safe, high-value caching targets — this alone can dramatically cut repeat load on the ALB/EC2 origin.
- Dynamic endpoints, e.g. `/api/user/profile`, are a different story — the response can depend on the specific user, their cookies, their Authorization header, or query parameters. **Do not blindly cache these.**

**The real danger — incorrect caching of personalized content:**
```
/profile
  User A → Cookie: user=A
  User B → Cookie: user=B
```
If the cache key doesn't correctly distinguish these two requests, **User B could be served User A's cached response** — a serious data-leak / correctness bug, not just a performance quirk. Whenever content is personalized, the cache key and Origin Request Policy need to be deliberately designed around that, not left on defaults.

**For `/api/*` behaviors generally:** configure HTTP methods, query strings, headers, cookies, and authorization handling correctly, and explicitly decide — endpoint by endpoint — whether a response should be cached at all.

---

## 24. Complete production architecture

```
                         INTERNET
                             │
                             ▼
                        CLOUDFRONT
                             │
                        Cache Hit? ────Yes──→ Response from Edge Cache
                             │
                             No
                             ▼
                            ALB
                             │
                             ▼
                       TARGET GROUP
                             │
                             ▼
                    PRIVATE EC2 / ASG (Amazon Linux + Apache)
                             │
                             ▼
                          APPLICATION
                             │
                             ▼
                        PRIVATE RDS (MySQL)

Private EC2 outbound:  EC2 → NAT Gateway → Internet Gateway → Internet
```

**Who's responsible for what, end to end:**
```
CloudFront = Global content delivery
ALB        = Regional traffic distribution
EC2        = Application server
RDS        = Database
NAT        = Outbound Internet access for private resources
```

---

## 25. Testing the distribution

**Basic test:**
```
Open: https://d123456abcdef.cloudfront.net
Expect: Browser → CloudFront → ALB → EC2 → Apache → index.html
```

**Testing that caching actually works:**
- **First request:** Cache Miss → CloudFront → ALB → EC2.
- **Second request (same object):** Cache Hit → served straight from CloudFront, ALB/EC2 not contacted.

**Inspecting cache behavior from the command line:**
```bash
curl -I https://d123456abcdef.cloudfront.net/
```
Check the response headers — CloudFront responses can include headers like `Age` and `X-Cache` that reveal whether a request was served from cache. Exact headers present depend on your specific request and distribution configuration.

---

## 26. Troubleshooting — common CloudFront errors

| Error | Likely causes |
|---|---|
| **403 Forbidden** | Origin access/security configuration, ALB Security Group, a WAF rule, application-level authorization, an incorrect cache behavior, or the origin's own response |
| **502 Bad Gateway** | CloudFront can't successfully talk to the origin — ALB/origin connectivity, a TLS problem between CloudFront and the origin, or the origin being unavailable |
| **504 Gateway Timeout** | The origin is taking too long to respond — network issues or an application-level problem |

**General checklist — "CloudFront is deployed but the site doesn't load":**
1. CloudFront status — is it actually `Deployed`?
2. Origin — is it pointing at the correct ALB?
3. ALB listener — HTTP/HTTPS configured correctly?
4. Target Group — are the targets healthy?
5. EC2 — is Apache actually running?
6. EC2 Security Group — does it allow traffic from the ALB?
7. ALB Security Group — does it allow CloudFront's origin-facing traffic (§20)?
8. CloudFront's origin protocol — HTTP/HTTPS configured to match what the ALB expects?
9. SSL certificate — valid, and correctly attached?
10. WAF — is a rule silently blocking the traffic?

---

## 27. CloudFront compared to other services

| Compared to… | Key difference |
|---|---|
| **ALB** | CloudFront = global CDN / viewer-facing edge layer. ALB = regional load balancer distributing traffic to backend targets. CloudFront commonly uses an ALB *as* its origin. |
| **NAT Gateway** | CloudFront handles **inbound** content delivery to users. NAT Gateway provides **outbound** Internet access for private resources like EC2. Different directions, different jobs entirely. |
| **S3** | S3 = object storage (stores the files). CloudFront = CDN (delivers those files globally, fast). A very common pairing: `User → CloudFront → S3`. |
| **Elastic Load Balancing (ALB/NLB)** | CloudFront = global edge delivery. ELB = regional application load balancing. CloudFront sits in front of, and can use, an ALB as its origin — not a replacement for it. |

**Easy memory trick:** `CloudFront = GLOBAL`, `ALB = REGIONAL`, `NAT = OUTBOUND ONLY`, `S3 = STORAGE (not delivery)`.

---

## 28. Configuration checklist — what to think about before creating a distribution

```
[ ] Origin                  [ ] Allowed methods
[ ] Origin protocol         [ ] Compression
[ ] Origin path             [ ] HTTPS
[ ] Default behavior        [ ] Custom domain
[ ] Path patterns           [ ] ACM certificate (us-east-1!)
[ ] Cache policy            [ ] WAF
[ ] Origin request policy   [ ] Price class
[ ] TTL                     [ ] Logging
[ ] Viewer protocol policy  [ ] Monitoring
                             [ ] Default root object
                             [ ] Invalidation plan
                             [ ] Origin security (ALB-SG locked to CloudFront)
```

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| CloudFront | AWS's global CDN, sits between users and the origin | `User → CloudFront → ALB` |
| Edge Location / POP | Physical CloudFront location closest to the user | Caches and serves content near the viewer |
| Regional Edge Cache | Extra caching layer between edge locations and origin | Keeps less-popular content closer without hitting the origin |
| Origin | Where CloudFront actually gets content from | Our project's origin = the ALB |
| Distribution | The full CloudFront configuration | Domain like `d123456abcdef.cloudfront.net` |
| Cache Hit / Miss / Ratio | Served from cache vs fetched from origin vs % served from cache | 800/1000 requests from cache = 80% hit ratio |
| Cache Policy vs Origin Request Policy | What identifies a cached object vs what's sent to the origin | Keeps `Authorization` out of the cache key but still forwards it |
| TTL (Min/Default/Max) | How long an object stays cached before revalidating | Default TTL 86400s = 24 hours |
| Cache Behavior | Per-path-pattern caching rules | `/images/*` cached aggressively, `/api/*` cached carefully |
| Invalidation | Force-remove a cached object immediately, regardless of TTL | `aws cloudfront create-invalidation --paths "/index.html"` |
| ACM + CloudFront | Custom-domain certificate, must be in `us-east-1` | Common interview trap — different from the ALB's own region |
| CloudFront origin-facing prefix list | Locks the ALB SG to CloudFront's own IP ranges only | Prevents users from bypassing CloudFront and hitting the ALB directly |
| Personalized-content caching risk | Wrong cache key can leak one user's response to another | `/profile` cached without distinguishing `user=A` vs `user=B` |
