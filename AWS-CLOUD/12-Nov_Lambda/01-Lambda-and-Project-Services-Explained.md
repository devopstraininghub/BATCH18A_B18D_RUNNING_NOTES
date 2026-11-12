# Part 1: AWS Lambda and the Services in Our Project

Read this first. Then follow **02-AWS-Daily-Cost-Email-Project.md** to build it.

---

## 1. What is AWS Lambda?

**AWS Lambda runs your code without you managing any server.** You write a small function, and AWS runs it when something triggers it. You pay only for the time it runs.

| Normal server (EC2) | Lambda |
|---|---|
| You create and maintain the server | No server to manage |
| Runs 24 hours, and you pay 24 hours | Runs only when needed |
| You handle scaling | Scales automatically |

**Analogy:** a server is like renting a car for the whole month. Lambda is like taking a taxi: you pay only for the ride.

"Serverless" doesn't mean there are no servers. AWS owns and looks after them.

## 2. How Lambda works

```
  TRIGGER                    LAMBDA                        RESULT
┌─────────────┐  event  ┌─────────────────┐  does work  ┌───────────────────┐
│ clock, upload│ ──────▶ │ your function   │ ──────────▶ │ email, file,      │
│ web request │         │ lambda_handler  │             │ database entry... │
└─────────────┘         └─────────────────┘             └───────────────────┘
                              │ print()
                              ▼
                        CloudWatch Logs
```

1. Something **triggers** the function (a clock, a file upload, a web request).
2. Lambda runs your **handler** and gives it the **event** (input data).
3. Your code does the job and **returns** a result.
4. Everything you `print()` is saved in **CloudWatch Logs**.

## 3. Key terms

| Term | Meaning |
|---|---|
| **Function** | Your code plus its settings |
| **Handler** | The function Lambda calls first (`lambda_handler`) |
| **Event** | The input data, in JSON |
| **Trigger** | What starts the function |
| **Runtime** | The language (we use Python 3.12) |
| **Environment variable** | A setting stored outside the code |
| **Timeout** | The maximum run time (the default is 3 seconds) |
| **Execution role (IAM)** | The permissions the function has |

---

## 4. What our project builds

**A Lambda function that emails you yesterday's AWS cost every morning.**

```
 ┌─────────────────┐  8 AM daily  ┌──────────────────┐  asks   ┌────────────────┐
 │ EventBridge     │ ───────────▶ │ Lambda           │ ──────▶ │ Cost Explorer  │
 │ Scheduler       │              │ daily-cost-report│ ◀────── │ (your bill)    │
 │ (alarm clock)   │              └────────┬─────────┘  costs  └────────────────┘
 └─────────────────┘                       │ sends report
                                           ▼
                                    ┌─────────────┐   email   ┌──────────┐
                                    │ SNS         │ ────────▶ │ You      │
                                    └─────────────┘           └──────────┘

   IAM role = what Lambda is allowed to do      CloudWatch = Lambda's diary (logs)
```

## 5. Services covered in this project

| Service | Simple meaning | Its job in our project |
|---|---|---|
| **AWS Lambda** | Runs code without servers | The brain: gets the cost, writes the report, sends it |
| **Amazon EventBridge Scheduler** | An alarm clock for AWS | Starts the Lambda every morning at 8 AM |
| **AWS Cost Explorer** | Your AWS bill, readable by code | Tells us how much each service cost yesterday |
| **Amazon SNS** (Simple Notification Service) | The post office | Sends the report to your email |
| **AWS IAM** | Permissions and security | Decides that Lambda may read the cost and send the email, and nothing else |
| **Amazon CloudWatch Logs** | Lambda's diary | Stores our `print` output, so we can see what happened or what failed |

### In one line each
- **Lambda** does the work.
- **EventBridge** decides *when*.
- **Cost Explorer** gives the *data*.
- **SNS** delivers the *message*.
- **IAM** controls *who may do what*.
- **CloudWatch** keeps the *record*.

## 6. The flow, step by step

1. **8:00 AM**: EventBridge Scheduler wakes up the Lambda function.
2. Lambda asks **Cost Explorer**: "what did each service cost yesterday?"
3. Lambda counts the services and adds up the total.
4. Lambda writes a short text report.
5. Lambda gives the report to **SNS**.
6. **SNS** emails you.
7. Lambda's logs are saved in **CloudWatch**.

**What the email looks like**
```
AWS report for 2026-10-07
Services used: 4
Total cost: $0.42

Amazon Elastic Compute Cloud - Compute: $0.30
Amazon DynamoDB: $0.12
AWS Lambda: $0.00
Amazon Simple Storage Service: $0.00
```

## 7. Why IAM matters here
By default, a Lambda function can do almost nothing, apart from writing its own logs. We grant exactly two permissions:

| Permission | Why |
|---|---|
| `ce:GetCostAndUsage` | Read the cost from Cost Explorer |
| `sns:Publish` | Send the message to our SNS topic |

This is the **least-privilege** rule: give only the permissions that are needed.

## 8. Cost of this project
| Item | Cost |
|---|---|
| Lambda (one run a day) | $0 (free tier) |
| EventBridge Scheduler, SNS email, CloudWatch | $0 at this size |
| Cost Explorer API | $0.01 per call, about **$0.30 a month** |

## 9. Quick questions

1. What does "serverless" mean?
2. What starts our Lambda every morning?
3. Which service reads the bill, and which sends the email?
4. Why does the Lambda role have only two permissions?
5. Where do we look to see what the function printed?

**Answers:** 1) You don't manage servers. 2) EventBridge Scheduler. 3) Cost Explorer reads it and SNS sends it. 4) Least privilege. 5) CloudWatch Logs.

---

**Next:** open `02-AWS-Daily-Cost-Email-Project.md` and build it in the console.
