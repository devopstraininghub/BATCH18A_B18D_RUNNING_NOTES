# Batch 18 — AWS Cloud Running Notes: 22 September 2026

**Topic: AWS CLI (Command Line Interface)**

Friends, today's topic ties everything we've built so far into one tool — the **AWS CLI**, the terminal-based way to control every AWS service we've covered (EC2, S3, IAM, Auto Scaling) without clicking through the console.

---

## 1. What is AWS CLI?

- **AWS CLI** = a tool that lets you interact with AWS using commands from a terminal, instead of the web console (GUI).

**Example:**
```
aws s3 ls
aws ec2 describe-instances
```

---

## 2. Why do we need AWS CLI when the GUI exists?

| | GUI | AWS CLI |
|---|---|---|
| Good for | Beginners, manual one-off operations | Speed, scripting, automation |
| Automation-friendly? | No | Yes — used in CI/CD pipelines and production troubleshooting |
| Works without a browser? | No | Yes — works on any server, even headless ones |

**DevOps rule:** if you repeat a task, automate it — and the CLI is what makes that automation possible.

---

## 3. How AWS CLI works

1. Install AWS CLI.
2. Configure credentials:
   ```
   aws configure
   ```
   You're prompted for: **Access Key**, **Secret Key**, **Region**, and **Output format** (e.g. `json`, or none).
3. Credentials are stored **locally** (in your user home directory).

⚠️ Treat your Access Key/Secret Key exactly like a password — never paste them into a shared file, a chat, or a git repo.

---

## 4. Basic command structure

```
aws <service> <operation> --parameters
```

**Examples:**
```
aws ec2 describe-instances
aws s3 cp file.txt s3://mybucket/
```

---

## 5. Day-to-day DevOps operations using the CLI

**S3 operations:**
```bash
aws s3 ls                              # list buckets
aws s3 ls s3://mybucket/               # list files inside a bucket
aws s3 cp file.txt s3://mybucket/      # upload a file
aws s3 cp s3://mybucket/file.txt .     # download a file
aws s3 sync ./app s3://mybucket/       # sync a whole local folder
```

**EC2 operations:**
```bash
aws ec2 describe-instances                                    # list instances
aws ec2 start-instances --instance-ids i-0a54fdb26081aade5    # start
aws ec2 stop-instances --instance-ids i-123456                # stop
aws ec2 terminate-instances --instance-ids i-123456            # terminate

# create a new instance
aws ec2 run-instances \
  --image-id ami-0c1fe732b5494dc14 \
  --instance-type t3.micro \
  --key-name batch17a \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Dev-Server},{Key=Env,Value=Dev}]'
```

**Security Group operations:**
```bash
aws ec2 describe-security-groups

aws ec2 authorize-security-group-ingress \
  --group-id sg-12345 \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
```

**IAM operations:**
```bash
aws iam list-users
aws iam create-user --user-name devuser

aws iam attach-user-policy \
  --user-name devuser \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

**CloudWatch Logs:**
```bash
aws logs describe-log-groups
```

**Auto Scaling:**
```bash
aws autoscaling describe-auto-scaling-groups
```

---

## 6. Real DevOps use cases

- Automating deployments end to end.
- Uploading build artifacts to S3 (see `21September_S3.md` — Project 5).
- Triggering infrastructure changes.
- Backup automation scripts.
- Monitoring and log retrieval.
- Managing an entire EC2 fleet from a script.
- Managing IAM users programmatically (see `18September_IAM.md`).
- Used **inside** Jenkins, GitHub Actions, and Terraform's external scripts.

---

## 7. Why CLI is so important for DevOps

- Infrastructure as Code (Terraform, CloudFormation) relies on the same underlying APIs the CLI uses.
- Automation genuinely requires it — a GUI can't be scripted.
- Production servers usually don't even have a browser available.
- It's the fastest path to troubleshooting a live issue.

**Simple summary:** GUI = manual work. CLI = automation + speed — and every DevOps engineer is expected to know it.

---

## Quick Recap Table

| Command / Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `aws configure` | Set up local credentials for the CLI | One-time setup before any other `aws` command works |
| `aws <service> <operation>` | The general shape of every CLI command | `aws s3 ls`, `aws ec2 describe-instances` |
| `aws s3 sync` | Push a whole local folder to a bucket | Deploying a static site's build output in one command |
| `aws ec2 run-instances` | Launch an EC2 instance from the terminal | Spinning up a dev server from a script instead of the console |
| `aws iam attach-user-policy` | Grant a permission to a user via CLI | Automating onboarding for a new team member |
| CLI inside Jenkins/GitHub Actions/Terraform | The CLI powers real automation pipelines | A deploy job running `aws s3 sync` as one of its steps |
