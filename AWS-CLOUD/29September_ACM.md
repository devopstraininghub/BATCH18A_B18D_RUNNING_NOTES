# Batch 18 — AWS Cloud Running Notes: 29 September 2026

**Topic: AWS Certificate Manager (ACM)**

Friends, on 28 September we got Route 53 pointing `login.b18facebook.store` at our ALB (`28September_Route53.md`) — but that only gets us `http://`. Today's topic, **ACM (AWS Certificate Manager)**, is the piece that upgrades that to `https://` — the padlock, the encryption, everything a real production site needs before it's safe to put in front of real users.

---

## 1. What is AWS Certificate Manager (ACM)?

- **ACM** = an AWS service that **provisions, manages, stores, and renews** SSL/TLS certificates.
- In one line: **ACM helps us enable HTTPS for our applications.**

**Example:**
```
HTTP:  http://www.example.com
HTTPS: https://www.example.com
```

**AWS services that can use an ACM certificate directly:**
- Application Load Balancer (ALB)
- Network Load Balancer (NLB)
- CloudFront
- API Gateway

**Easy definition:** `ACM = AWS's service for managing SSL/TLS certificates.`

---

## 2. Why do we need ACM?

- Its core job is securing the communication between users and your application.
- Without HTTPS, everything travels as **plain text** — readable by anyone who can see the traffic.

**What HTTPS actually protects in transit:**
- Usernames and passwords
- Session information
- Payment information
- Personal information
- API requests and application data

- ACM makes this easier because **AWS handles most of the certificate's lifecycle** for you — request, validate, issue, and (for eligible certificates) renew.

---

## 3. HTTP vs HTTPS

| | HTTP | HTTPS |
|---|---|---|
| Full form | HyperText Transfer Protocol | HyperText Transfer Protocol **Secure** |
| Port | 80 | 443 |
| Encrypted? | No | Yes — HTTP wrapped in TLS |

**Easy memory trick:** `HTTP = 80`, `HTTPS = 443`.

---

## 4. SSL vs TLS — a terminology note

- **SSL** (Secure Sockets Layer) was the original protocol — it's now outdated and no longer used for modern secure connections.
- **TLS** (Transport Layer Security) is its modern successor, and what every current HTTPS connection actually uses.
- People still say **"SSL certificate"** out of habit — technically the accurate term today is **TLS certificate**. When someone says "install an SSL certificate," what they mean in practice is "configure a TLS certificate for HTTPS."

---

## 5. What does HTTPS actually provide?

1. **Encryption** — data between client and server is encrypted in transit.
2. **Authentication** — the certificate lets the browser verify the server really is who it claims to be (the domain it says it is).
3. **Data integrity** — TLS protects data from being silently modified while it's in transit.

---

## 6. What is an SSL/TLS certificate?

- A **digital document** presented during a TLS connection, containing:
  - Domain name
  - Public key
  - Certificate Authority information
  - Validity period
  - Digital signature
- When a user visits `https://www.example.com`, the browser checks the certificate the server presents before trusting the connection.

---

## 7. What is a Certificate Authority (CA)?

- A **CA** is a trusted organization that issues digital certificates.

**Basic process:**
```
Domain Owner → requests certificate → CA
                                        │
                              validates domain ownership
                                        │
                                        ▼
                              Certificate issued
```
- Browsers trust certificates issued by CAs that are themselves trusted by the browser/OS.

---

## 8. Simple HTTPS connection flow

```
User enters https://www.example.com
        │
        ▼
DNS resolves the domain
        │
        ▼
Request reaches the HTTPS endpoint
        │
        ▼
Server presents its TLS certificate
        │
        ▼
Browser validates the certificate
        │
        ▼
TLS connection is established
        │
        ▼
Encrypted HTTPS communication begins
```

---

## 9. The ACM certificate lifecycle

```
Request → Validate → Issue → Use → Renew → Continue using
```

Instead of you manually tracking expiry dates and re-installing certificates, ACM manages this whole cycle through its integration with supported AWS services.

**Full flow, in order:**
1. Request a certificate.
2. Specify the domain.
3. Choose a validation method.
4. Prove domain ownership.
5. ACM issues the certificate.
6. Attach it to a supported AWS service (e.g. an ALB).
7. Use HTTPS.
8. ACM manages renewal (for eligible certificates).

---

## 10. Domain validation

- Before ACM issues a **public** certificate, AWS must confirm you actually control the domain — this step is called **domain validation**.

**Two validation methods:**
1. **DNS validation** — add a specific DNS record; commonly preferred in AWS environments, especially when Route 53 already manages the domain.
2. **Email validation** — approve via an email sent to the domain's registered contacts.

---

## 11. DNS validation — how it actually works

- ACM gives you a special **CNAME** record to add to your DNS.

**Example:**
```
Name:  _abc123.b18facebook.store
Type:  CNAME
Value: _xyz456.acm-validations.aws
```

- You add this record wherever the domain's DNS is hosted.
- ACM checks for it — once found, domain ownership is confirmed and the certificate status moves to **ISSUED**.
- **Why DNS validation proves control:** only someone who can actually create records in the domain's DNS zone could ever add that specific CNAME — that ability *is* the proof.

---

## 12. ACM + Route 53 — two services with two separate jobs

| Service | Responsibility |
|---|---|
| **ACM** | SSL/TLS certificate management |
| **Route 53** | DNS |

- If Route 53 already manages your domain, the ACM validation CNAME can be created directly inside that Route 53 hosted zone — that's exactly what we did for `b18facebook.store`.

**Easy memory trick:** `ACM = Certificate`, `Route 53 = DNS`.

---

## 13. Very important — two *different* DNS records, easy to confuse

This trips people up constantly, so worth being explicit:

| | ACM validation record | Application DNS record |
|---|---|---|
| Example | `_abc123.b18facebook.store` (CNAME) | `login.b18facebook.store` (Alias) |
| Purpose | **Proves domain ownership** to ACM | **Sends users** to the application (the ALB) |
| Points to | `_xyz456.acm-validations.aws` | The ALB |

**Easy memory trick:** `ACM CNAME = certificate validation`. `www Alias = application traffic`. Same hosted zone, two completely different jobs.

---

## 14. Certificate types — single-domain, multi-domain, wildcard

**Single-domain certificate** — covers exactly one name.
```
Certificate: login.b18facebook.store
```

**Multi-domain certificate** — one certificate, several domain names, listed as **SANs (Subject Alternative Names)**.
```
b18facebook.store
login.b18facebook.store
api.b18facebook.store
admin.b18facebook.store
```

**Wildcard certificate** — covers every name at *one* subdomain level.
```
*.b18facebook.store
```
covers: `login.b18facebook.store`, `api.b18facebook.store`, `dev.b18facebook.store`, `test.b18facebook.store`

⚠️ **Two easy-to-miss gotchas:**
- `*.b18facebook.store` does **NOT** cover the bare apex domain `b18facebook.store` — if you need both, request both explicitly: `b18facebook.store` **and** `*.b18facebook.store`.
- `*.b18facebook.store` does **NOT** cover `api.dev.b18facebook.store` — that's a second subdomain level, one level deeper than the wildcard reaches.

---

## 15. Hands-on — requesting an ACM certificate (console walkthrough)

**Step 1 — Open Certificate Manager**
```
AWS Console → Certificate Manager → Request → Request a public certificate
```

**Step 2 — Enter the domain name(s)**
```
login.b18facebook.store
```
or, to cover the apex too:
```
b18facebook.store
*.b18facebook.store
```

**Step 3 — Choose validation method**
```
DNS validation   (recommended, especially with Route 53)
```

**Step 4 — Request**
- Certificate status immediately after requesting: **Pending validation**.

**Step 5 — Create the DNS validation record**
- ACM shows you the exact CNAME (name + value) from §11.
- If Route 53 manages the domain, ACM's console can create this record directly in the Route 53 hosted zone for you in one click.

**Step 6 — Wait for validation**
- Once ACM finds the correct CNAME, status changes: **Pending validation → Issued**.
- **Issued** means the certificate is ready to attach to a supported AWS service.

---

## 16. Why you should never delete the ACM validation CNAME

- ACM continues to rely on that same DNS validation record for its **managed renewal** process — not just for the initial issuance.
- If the record is deleted or changed later, a future automatic renewal can fail.

**Easy memory trick:** `ACM Validation CNAME = KEEP IT`, indefinitely — not just until the certificate first shows "Issued."

---

## 17. Automatic certificate renewal

**Without ACM (the traditional, manual way):**
```
Certificate expires → find a new one → install it → reconfigure the app → restart/reload the service
```

**With ACM:**
```
ACM monitors the certificate lifecycle → manages renewal → HTTPS just keeps working
```

- Certificate renewal is a genuinely **critical production activity** — an expired certificate means users hit browser warnings, or the HTTPS service breaks outright. ACM's managed renewal (for eligible certificates) removes most of that manual operational burden.

---

## 18. Using an ACM certificate with an ALB

```
ALB HTTPS Listener (port 443)
        │
        ▼
  ACM Certificate
```
- You attach the certificate to the ALB's **HTTPS listener**, not to each backend server.
- You do **not** need to install the certificate on every EC2 instance behind the ALB — this is one of the biggest practical wins of doing TLS at the load-balancer layer instead of per-server.

**HTTP → HTTPS redirect (a common, recommended setup):**
```
HTTP :80 → (redirect) → HTTPS :443 → Application
```
So `http://login.b18facebook.store` automatically forwards the user to `https://login.b18facebook.store`.

**TLS termination — the term for what's actually happening here:** the ALB is where the encrypted TLS connection ends ("terminates") — the ALB does the decryption, and typically forwards the request to the backend over plain HTTP within the private network. This is exactly why you don't need a certificate on each EC2 instance: the ALB is the only point that ever needs to speak TLS to the outside world.

---

## 19. ACM certificate regions — a genuinely common gotcha

- **ACM certificates are regional resources** — they only work with services in the same region they were requested in.

| Using the certificate with… | Request the certificate in… |
|---|---|
| **ALB / NLB** | The **same region** as the load balancer (e.g. `ap-south-1`) |
| **CloudFront** | **Always `us-east-1`** (N. Virginia) — regardless of where your origin, S3 bucket, or ALB actually lives |

This CloudFront rule catches people out constantly (it's a frequent interview question precisely because it's counter-intuitive) — CloudFront is a global service, but its control plane lives in `us-east-1`, so that's the one region its certificates must come from. You can't reassign an existing certificate from one region to another; you have to request or import a fresh one in the target region.

---

## 20. Certificate ARN

- Once issued, ACM gives the certificate a unique **ARN (Amazon Resource Name)**, used to reference it when configuring other AWS resources (e.g. attaching it to an ALB listener).

**Example:**
```
arn:aws:acm:ap-south-1:123456789012:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

---

## 21. Public vs private ACM certificates

| | Public certificate | Private certificate |
|---|---|---|
| Used for | Publicly trusted domains | Private/internal PKI environments |
| Example | `www.example.com` | `internal.company.local` |
| Typical use | A public website | Internal applications, internal corporate infrastructure |

For our `b18facebook.store` example: a **public** ACM certificate.

---

## 22. Why custom domain + ACM together is worth the setup

**Without it**, users have to remember and trust something like:
```
http://my-alb-123456.ap-south-1.elb.amazonaws.com
```

**With Route 53 + ACM**, they get:
```
https://login.b18facebook.store
```

**Benefits:** a professional domain, HTTPS, a trusted certificate, better user experience, secure communication, easier certificate lifecycle management, and something that's actually production-ready.

---

## 23. ACM validation vs application access — two separate processes

**ACM validation** — proves domain ownership:
```
ACM → CNAME → Route 53
```

**Application access** — actually sends users to the app:
```
User → login.b18facebook.store → Route 53 Alias → ALB
```
Same hosted zone, same domain, but these are two unrelated flows happening for two unrelated reasons — one runs once (and occasionally again for renewal), the other runs on every single user request.

---

## 24. Putting it all together — complete real-time flow

**User enters:** `https://login.b18facebook.store`

1. Browser performs a DNS lookup.
2. Route 53 resolves `login.b18facebook.store` to the ALB.
3. Browser connects to `ALB :443`.
4. ALB presents its ACM certificate.
5. Browser validates the certificate.
6. TLS connection is established (TLS termination happens here — §18).
7. The HTTPS request is sent securely.
8. ALB forwards the request to the application server (via its Target Group).
9. The application processes the request.
10. The response is returned to the user.

**Complete architecture:**
```
                     USER
                       │
                  HTTPS :443
                       ▼
              login.b18facebook.store
                       │
                       ▼
                  ROUTE 53  (DNS)
                       │
                       ▼
                     ALB   ──── HTTPS Listener ──── ACM CERTIFICATE
                       │
                  Target Group
                       │
                       ▼
                     EC2 → APPLICATION
```

**Who's responsible for what:**
```
Route 53 = DNS
ACM      = Certificate
ALB      = HTTPS endpoint / traffic distribution (via its Target Group)
EC2      = Application
```

⚠️ **ACM is not DNS, and ACM is not a load balancer.** ACM only ever does one job — managing the certificate. Route 53 resolves names; the ALB (via its Target Group) distributes traffic to the actual backend EC2 instances.

---

## 25. Hands-on — full production setup, end to end

**Requirement:** serve `https://login.b18facebook.store` securely.

1. Create a Route 53 hosted zone (or use the one already set up — see `28September_Route53.md`).
2. Request a public ACM certificate for `b18facebook.store` and/or `login.b18facebook.store`.
3. Choose **DNS validation**.
4. Create the ACM validation CNAME in the Route 53 hosted zone.
5. Wait for the certificate status to become **ISSUED**.
6. Create/configure the ALB.
7. Configure an HTTPS listener on port 443.
8. Attach the ACM certificate to that listener.
9. Create a Route 53 **Alias** record: `login.b18facebook.store → ALB`.
10. Test: open `https://login.b18facebook.store` and confirm it works.

**Verifying it worked — what to actually check:**
- The website loads over HTTPS.
- The browser shows the padlock/HTTPS lock icon.
- The certificate is valid (not expired, correctly issued).
- The certificate's domain matches the domain you requested (inspect it from the browser's connection-security details).

---

## 26. Troubleshooting — common ACM problems

| Problem | What to check |
|---|---|
| Certificate stuck at **Pending validation** | The DNS validation CNAME — is it created, correct, and publicly resolvable? |
| Certificate doesn't match the domain (e.g. user hits `www.example.com`, certificate only covers `api.example.com`) | Request/attach a certificate that actually covers the domain being used |
| HTTPS just doesn't work | Certificate status, HTTPS listener, port 443, DNS, ALB configuration, application health |
| Renewal fails | Confirm the original ACM DNS validation CNAME still exists in DNS (§16) |

**General "Pending validation" checklist:** is the domain correct? Is the CNAME correct? Is it publicly resolvable? Was it created in the correct DNS zone? Was it accidentally deleted? Any conflicting DNS records? Correct AWS account/permissions being used?

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| ACM | AWS's service for provisioning/managing/renewing SSL/TLS certificates | Enables `https://login.b18facebook.store` |
| HTTP vs HTTPS | Plain-text vs encrypted, port 80 vs port 443 | `http://` silently upgraded via a redirect to `https://` |
| TLS vs SSL | TLS is the modern protocol; "SSL certificate" is just old habit | Every "SSL cert" issued today is actually a TLS certificate |
| DNS validation | Proves domain ownership by adding a specific CNAME | ACM's CNAME added to the Route 53 hosted zone |
| ACM validation CNAME vs app record | Two different DNS records, two different jobs — never delete the first one | `_abc123...` (validation) vs `www` Alias (traffic) |
| Wildcard certificate | Covers one subdomain level, not the apex, not deeper levels | `*.b18facebook.store` ≠ `b18facebook.store`, ≠ `api.dev.b18facebook.store` |
| ACM + ALB | Certificate attaches to the ALB's HTTPS listener, not to each EC2 | No per-server certificate installs needed |
| TLS termination | Where the encrypted connection actually ends | At the ALB — backend traffic can be plain HTTP internally |
| ACM certificate region | Regional resource — must match where it's used | ALB → same region; CloudFront → always `us-east-1` |
| Managed renewal | ACM renews eligible certificates automatically | Keeps HTTPS working with no manual re-installation |
