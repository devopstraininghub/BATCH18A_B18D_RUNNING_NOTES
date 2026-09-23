# Batch 18 — AWS Cloud Running Notes: 23 September 2026

**Topic: IAM Role**

Friends, on 18 September we covered IAM Users, Policies, and Groups. Today's topic — the **IAM Role** — is the piece that makes AWS's real security best practice actually work: giving an application or service the permissions it needs, **without** ever handing it a permanent password or access key.

---

## 1. What is an IAM Role?

- An **IAM Role** is an AWS identity that has **permissions**, but **no permanent credentials** — no username, no password, no long-term access key.
- A role is **assumed temporarily** by a trusted user, application, or AWS service, whenever it's needed.

**Simple definition:**
```
IAM User → a permanent identity (a person or an app)
IAM Role → a temporary identity (assumed only when needed)
```

---

## 2. IAM User vs IAM Role

| | IAM User | IAM Role |
|---|---|---|
| Password | Yes | No |
| Access keys | Long-term | No permanent keys — temporary, auto-rotated credentials |
| Typical use | People, or an external app that needs a fixed identity | AWS services, or cross-account access |

---

## 3. Why IAM Role matters

- More secure — no hardcoded access keys sitting anywhere.
- Credentials are **temporary** and **automatically rotated**.
- The standard **production best practice**.
- Required whenever one AWS service needs to talk to another (**service-to-service access**).

**Easy memory trick:** an IAM User is like a permanent employee ID badge. An IAM Role is like a visitor badge — issued fresh each time, expires on its own, never something you'd want to leave lying around.

---

## 4. Real-time use cases

**1. EC2 accessing S3**
- Scenario: an EC2 instance needs to upload logs to S3.
- **Wrong way:** hardcode an access key inside the EC2 instance — unsafe, and the key never expires on its own.
- **Correct way:** attach an IAM Role to the EC2 instance — it automatically gets temporary credentials, and no secret key is ever stored on the server.

**2. Lambda accessing DynamoDB**
- A Lambda function needs database access — attach an IAM Role to the function with the required DynamoDB permissions.

**3. Cross-account access**
- A company has `Account A` (Dev) and `Account B` (Prod). A Dev engineer **assumes a role** in the Production account temporarily, instead of having a separate permanent login there.

**4. CI/CD pipeline access**
- Jenkins or GitHub Actions assumes an IAM Role to deploy EC2 instances, upload artifacts to S3, or modify infrastructure — no long-lived credentials stored in the pipeline's configuration.

**5. EKS/ECS service roles**
- Containers need access to S3, Secrets Manager, or RDS — an IAM Role provides temporary, secure access instead of baking credentials into the container image.

---

## 5. How an IAM Role works — the flow

```
User / Service → Assumes Role → Gets Temporary Credentials → Performs allowed actions
```

Under the hood, this is powered by **AWS STS (Security Token Service)** — when something "assumes a role," it's really calling STS's `AssumeRole` API, which hands back a short-lived Access Key, Secret Key, and Session Token.

- **Default session duration:** 1 hour.
- **Maximum session duration:** configurable up to 12 hours, depending on the role's own settings.
- Once the session expires, the credentials simply stop working — nothing to manually revoke or rotate.

---

## 6. Important terms

**Trust Policy** — defines **WHO** is allowed to assume the role.

**Example — allowing EC2 to assume this role:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["sts:AssumeRole"],
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      }
    }
  ]
}
```
- `Action: sts:AssumeRole` — the actual permission being granted is "allowed to assume this role."
- `Principal.Service: ec2.amazonaws.com` — specifically the EC2 service is trusted to assume it. For cross-account access (use case 3 above), the `Principal` would instead reference another AWS account or a specific role's ARN.

**Permission Policy** — defines **WHAT** actions are actually allowed once the role has been assumed (a normal IAM policy, same shape as the ones covered on 18 September — see `18September_IAM.md`).

**Easy memory trick:** Trust Policy → who's allowed **in**. Permission Policy → what they can **do** once they're in.

---

## 7. EC2 and IAM Roles — a detail worth knowing

When you "attach a role to an EC2 instance" in the console, AWS is actually creating something called an **Instance Profile** behind the scenes — a small container that wraps the role so it can be attached to an instance. The console hides this step, so most people never see it directly, but it explains why, if you're ever doing this via the CLI or Terraform instead of the console, you'll see an `instance-profile` resource alongside the role itself.

---

## 8. How the credentials actually get rotated — and what happens when you detach the role

**How auto-rotation works, mechanically:**
- The EC2 instance doesn't get handed credentials once — it **fetches** them from the **Instance Metadata Service (IMDS)**, a special local-only address every EC2 instance can reach: `http://169.254.169.254/latest/meta-data/iam/security-credentials/<role-name>`.
- Each set of credentials returned by IMDS is valid for about **6 hours**.
- AWS starts making a **new** set of credentials available through IMDS about **5 minutes before** the current set expires.
- The AWS SDK/CLI running on the instance reads the `Expiration` timestamp in the credentials it already has, and automatically re-fetches a fresh set from IMDS as that time approaches — no restart, no manual refresh, nothing the application's code has to handle itself.

**⚠️ What happens when you detach the role — a common misunderstanding:**
- **Detaching the role from the instance does NOT immediately revoke anything.** Any credentials already fetched — cached by your application, the SDK, or even an open shell session — stay valid and usable until their own natural expiration (up to ~6 hours later), **even if** you detach the role, and **even if** you reboot the instance.
- To actually cut off active sessions **immediately**, IAM has a dedicated **"Revoke active sessions"** action on the role itself — this attaches a special policy that denies every session that started before that moment, with roughly a **30-second propagation delay**.
- The more reliable lever in practice: **editing or removing the role's Permission Policy** (rather than detaching the role). AWS checks the role's **current, live** policy on **every single API call** — not a snapshot taken when the credentials were first issued. So tightening the policy takes effect on the *next* call the credentials try to make, even though the credentials themselves are technically still "valid" until they expire.

**Easy memory trick:** Detach the role → old credentials keep working until they expire on their own. Revoke sessions / edit the policy → cuts access off on the next API call, in seconds.

---

## 9. Worked scenario — "How long can my EC2 access S3?"

**Setup:**
```
Trust Entity : EC2
Permissions  : S3 Full Access
Attached to  : EC2 Instance
```

**Question:** How long can this EC2 instance access S3?
1. As long as the IAM role is attached
2. For a few minutes
3. Till the session is active
4. Some other duration

**Answer:** EC2 can access S3 for **as long as the IAM role remains attached/usable and its permissions still allow the S3 actions** — not for a fixed few minutes, and not tied to any single "session."

The key thing this question is testing: the **IAM Role** and the **temporary credentials** it hands out are **two different things**, on two different clocks.

**How it flows:**
```
EC2 Instance
     │  (IAM Role attached)
     ▼
IAM Role: EC2-S3-Role
     ├── Trust Policy       — "EC2 is allowed to assume/use this role"
     └── Permission Policy  — "This role can access S3"
     ▼
Temporary AWS Credentials
     ▼
S3
```

**Role attachment vs credential expiration:**

| | Role attachment | Temporary credentials |
|---|---|---|
| Lifespan | Can stay attached indefinitely | Short-lived — ~6 hours (§8) |
| What it is | A long-term authorization relationship | What the instance actually presents to S3 on each call |
| What happens at expiry | Nothing — it's not a "session" that ends | Auto-refreshed by AWS via IMDS, invisibly, while the role is still valid |

So a credential set expiring at, say, 11:00 AM does **not** mean the EC2 instance loses S3 access at 11:00 AM — AWS has already handed it a fresh set through IMDS before that happens, and the application never notices.

**So when does EC2 actually lose S3 access?** Tying this back to §8, there are really only a few real triggers:
- The role is **detached** from the instance — no *new* credentials can be issued after this, though any already-cached ones keep working until they expire.
- The role's **Permission Policy is edited** to remove S3 access — takes effect on the very next API call, live.
- An explicit **Deny** statement is added, blocking S3 actions.
- The role itself is **deleted**.
- Someone explicitly triggers **"Revoke active sessions"** on the role.

**Easy memory trick:** Role attachment = the relationship. Credentials = just the current ID card, reissued automatically while the relationship holds. Losing access needs one of those 5 specific triggers — expiration of a single credential set, by itself, is never one of them.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| IAM Role | A temporary identity with permissions, no permanent credentials | EC2 uploading to S3 without a hardcoded access key |
| Trust Policy | Defines who/what can assume the role | Allowing `ec2.amazonaws.com` to assume it |
| Permission Policy | Defines what the role can actually do | `s3:PutObject` on a specific bucket |
| STS `AssumeRole` | The API call that issues temporary credentials | Default 1 hour, up to 12 hours max session |
| Cross-account role | Assuming a role in a different AWS account | A Dev engineer temporarily accessing the Prod account |
| Instance Profile | The wrapper that lets a role attach to EC2 | Created automatically when you attach a role via the console |
| IMDS credential rotation | ~6-hour validity, refreshed automatically ~5 min before expiry | The SDK/CLI never has to be told to "refresh," it just works |
| Detaching a role | Does NOT instantly revoke already-issued credentials | Old credentials keep working until they naturally expire |
| Revoke active sessions | Immediately kills active sessions (~30s propagation) | The actual fix for "I need this access gone right now" |
| Role attachment vs credentials | Two separate clocks — one long-term, one short-lived | A credential expiring at 11 AM ≠ EC2 losing S3 access at 11 AM |
