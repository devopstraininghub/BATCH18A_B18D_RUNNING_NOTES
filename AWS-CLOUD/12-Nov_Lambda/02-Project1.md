# Project: Daily AWS Cost Email

Every morning, Lambda emails you yesterday's AWS cost, how many services were used, and the cost per service.

**Code file:** `cost_report_lambda.py` (same folder). Copy it into Lambda in Step 3.
**Time:** about 25 minutes. **Cost:** about $0.30 a month (Cost Explorer charges $0.01 per call).

```
 EventBridge (8 AM alarm) ──▶ Lambda ──▶ Cost Explorer (reads the bill)
                                │
                                └──▶ SNS ──▶ your email
```

## Fill in these values as you go

| Item | Your value |
|---|---|
| Region | ______________ |
| SNS topic ARN | ______________ |
| Account ID (12 digits) | ______________ |

---

## Step 0: Turn on Cost Explorer (do this 24 hours before)
Sign in as the account owner (root). Open **Billing and Cost Management, then Cost Explorer, then Launch Cost Explorer**. Data takes up to 24 hours to appear.

- [ ] Done

## Step 1: Create the SNS topic (the email sender)
1. Open **SNS, then Topics, then Create topic**.
2. Type: **Standard**. Name: `aws-daily-report`. Click **Create topic**.
3. Copy the **Topic ARN** into the table above.
4. Click **Create subscription**. Protocol: **Email**. Endpoint: your email address. Click **Create subscription**.
5. Open your inbox and click **Confirm subscription** (check spam).

- [ ] Status shows **Confirmed**

## Step 2: Create the Lambda function
1. Open **Lambda, then Create function, then Author from scratch**.
2. Name: `daily-cost-report`. Runtime: **Python 3.12**. Click **Create function**.

- [ ] Done

## Step 3: Add the code
1. Open `cost_report_lambda.py`, then select all and copy.
2. In Lambda, open the **Code** tab, delete the old code in `lambda_function.py`, and paste.
3. Click **Deploy**.

- [ ] Deployed

## Step 4: Add the settings
1. **Configuration, then Environment variables, then Edit, then Add environment variable**.
   - Key: `SNS_TOPIC_ARN`
   - Value: your topic ARN
2. **Configuration, then General configuration, then Edit.** Set Timeout to `30 sec` and click **Save**.

- [ ] Done

## Step 5: Give Lambda permission
1. **Configuration, then Permissions.** Click the **role name** (this opens IAM).
2. **Add permissions, then Create inline policy, then JSON tab**.
3. Paste this, replacing `REGION` and `ACCOUNT_ID` with your values:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": "ce:GetCostAndUsage", "Resource": "*" },
    { "Effect": "Allow", "Action": "sns:Publish",
      "Resource": "arn:aws:sns:REGION:ACCOUNT_ID:aws-daily-report" }
  ]
}
```
4. Click **Next**. Name it `ReportAccess`. Click **Create policy**.

- [ ] Done

## Step 6: Test it
1. Go back to Lambda, then the **Test** tab, then **Create new event**.
2. Event name: `now`. Body: `{}`. Click **Save**, then **Test**.
3. Result should be `{"sent": true}`. Check your inbox within a minute.

- [ ] Email received

## Step 7: Schedule it every morning
1. Open **EventBridge, then Scheduler, then Schedules, then Create schedule**.
2. Name: `report-8am`.
3. Schedule pattern: **Recurring, then Cron-based schedule**.
   - Cron expression: `0 8 * * ? *`
   - Time zone: `Asia/Kolkata`
   - Flexible time window: **Off**
4. Click **Next**. Target: **AWS Lambda, then Invoke**, and choose `daily-cost-report`.
5. Click **Next** through the rest, then **Create schedule**.

- [ ] Schedule created. Tomorrow at 8 AM, check your inbox.

---

## If something goes wrong

| Problem | Fix |
|---|---|
| `AccessDeniedException` on `GetCostAndUsage` | Cost Explorer isn't enabled yet (Step 0). Wait up to 24 hours. If it persists, the root user must go to **Account, then IAM user and role access to Billing information, then Activate**. |
| `list index out of range` | Yesterday has no data yet (new account, or Cost Explorer still starting). Try again tomorrow. |
| No email | Subscription not confirmed (Step 1.5), or check spam. |
| `Task timed out` | Timeout is still 3 seconds. Redo Step 4.2. |
| Code change has no effect | You forgot to click **Deploy**. |

## Clean up when finished
Delete in this order, so nothing keeps running:
1. EventBridge schedule `report-8am` (**first**)
2. Lambda function `daily-cost-report`
3. SNS topic `aws-daily-report`
4. IAM role `daily-cost-report-role-xxxx`
5. CloudWatch log group `/aws/lambda/daily-cost-report`
