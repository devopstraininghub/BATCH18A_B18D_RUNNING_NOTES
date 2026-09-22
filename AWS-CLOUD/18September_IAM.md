# Batch 18 — AWS Cloud Running Notes: 18 September 2026

**Topic: IAM (Identity and Access Management)**

Friends, today we step back from networking and look at **IAM** — the service that controls **who** can log into AWS and **what** they're allowed to do once they're in. Every other service we've touched (EC2, VPC, S3) sits behind IAM's permission checks.

---

## 1. Authentication vs Authorization

- **Authentication** — verifying **WHO** you are. Examples: username + password, access key + secret key, MFA.
- **Authorization** — deciding **WHAT** you're allowed to do. Examples: can you create an EC2 instance? Can you delete an S3 bucket? Can you access RDS?

**Simple meaning:** Authentication → identity check. Authorization → permission check.

**Easy memory trick:** Authentication = "prove who you are." Authorization = "what you're allowed to touch."

---

## 2. What is IAM?

- **IAM** = **I**dentity and **A**ccess **M**anagement.
- An AWS service that controls:
  - Who can access AWS (authentication).
  - What they can do (authorization).
- Manages **users**, **groups**, **roles**, and **policies**.

---

## 3. What is an IAM User?

- An **IAM User** represents a person or application that needs access to AWS.
- Can have:
  - A console password.
  - Access keys (for CLI/API use).
- Examples: a developer, a DevOps engineer, an automation script.

---

## 4. What is an IAM Policy?

- An **IAM Policy** is a **JSON document** that defines permissions.
- Controls:
  - Allowed actions.
  - Denied actions.
  - Specific resources.
  - Optional conditions.

**Example — allow starting/stopping EC2:**
```json
Allow:
  ec2:StartInstances
  ec2:StopInstances
```

---

## 5. What is a Custom Policy?

- A **Custom Policy** is a policy **you** write yourself.
- Used when AWS's own built-in ("managed") policies don't match your exact requirement.
- Gives fine-grained control over exactly which actions/resources are allowed.

---

## 6. Basic structure of a policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:StartInstances",
      "Resource": "*"
    }
  ]
}
```

**Important keywords, explained:**
- **`Version`** — the policy language version. Almost always `"2012-10-17"`.
- **`Statement`** — the main block containing the actual permission rules. A policy can have multiple statements.
- **`Effect`** — whether access is allowed or denied. Values: `"Allow"` or `"Deny"`.
- **`Action`** — what operation is permitted, in the format `service:operation`. Examples: `ec2:StartInstances`, `s3:PutObject`, `iam:CreateUser`.
- **`Resource`** — which specific AWS resource the action applies to. Examples: `"*"` (all resources), a specific EC2 ARN, a specific S3 bucket ARN.

**Simple meaning, put together:** "Allow this **action** on this **resource**."

---

## 7. Optional — Condition (advanced)

- You can add **conditions** to a policy statement, such as:
  - Allow only from a specific IP address.
  - Allow only during certain hours.
  - Allow only if MFA is enabled.

---

## 8. What is an IAM Group?

- An **IAM Group** is a collection of IAM users.
- You attach a policy to the **group**, and every user inside it inherits those permissions.

**Example:**
```
Group: Developers → S3 Read Only
Group: Admins     → Full Access
```

**Easy memory trick:** attach a policy to the group once, instead of to every user individually.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Authentication | Verifying identity | Logging in with username/password or an access key |
| Authorization | Granting permissions | Deciding whether that identity can launch an EC2 |
| IAM | AWS's access-control system | Every other AWS service checks with IAM first |
| IAM User | An individual identity (person or app) | A developer's own login, or an automation script's credentials |
| IAM Policy | A JSON document of permission rules | `Allow ec2:StartInstances` on a specific instance |
| IAM Group | A collection of users sharing one policy | "Developers" group with S3 read-only access |
| Custom Policy | A permission rule you write yourself | Access AWS's managed policies don't cover exactly |
