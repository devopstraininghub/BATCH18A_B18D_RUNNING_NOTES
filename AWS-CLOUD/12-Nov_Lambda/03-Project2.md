# Project: Auto-Stop Idle EC2 Servers at Night

Every night at 8 PM, Lambda stops your tagged EC2 servers. Every weekday at 8 AM, it starts them again. After each run it emails you what it did. You stop paying for servers while nobody is using them.

**Code file:** `auto_stop_ec2_lambda.py` (same folder). Copy it into Lambda in Step 4.
**Time:** about 30 minutes. **Cost:** about $0 for the project. A stopped server costs nothing for compute, so you save money.

```
 EventBridge (8 PM)  {"action":"stop"}  ──┐
                                          ├──▶ Lambda ──▶ EC2 (find tag AutoStop=true, stop or start)
 EventBridge (8 AM)  {"action":"start"} ──┘       │
                                                  └──▶ SNS ──▶ your email
```

One function does both jobs. The schedule passes `{"action": "stop"}` or `{"action": "start"}`, and the function reads it.

## Fill in these values as you go

| Item | Your value |
|---|---|
| Region | ______________ |
| SNS topic ARN | ______________ |
| Account ID (12 digits) | ______________ |
| Test instance ID | ______________ |

---

## Step 1: Create a test EC2 server
Use a throwaway server so nothing important gets stopped.
1. Open **EC2, then Instances, then Launch instances**.
2. Name: `autostop-test`. AMI: **Amazon Linux**. Type: **t3.micro** (or whatever is free-tier eligible).
3. Key pair: **Proceed without a key pair**. Click **Launch instance**.
4. Copy the **Instance ID** into the table above.

- [ ] Instance is **Running**

## Step 2: Tag it
Lambda only touches servers with this tag. No tag means it is never touched.
1. Select the instance, then **Tags, then Manage tags, then Add tag**.
2. Key: `AutoStop`. Value: `true` (lowercase). Click **Save**.

- [ ] Tag saved

## Step 3: Create the SNS topic (the email sender)
1. Open **SNS, then Topics, then Create topic**.
2. Type: **Standard**. Name: `ec2-autostop-report`. Click **Create topic**.
3. Copy the **Topic ARN** into the table above.
4. Click **Create subscription**. Protocol: **Email**. Endpoint: your email address. Click **Create subscription**.
5. Open your inbox and click **Confirm subscription** (check spam).

If you already did this for project 02, you can reuse that topic and skip to Step 4.

- [ ] Status shows **Confirmed**

## Step 4: Create the Lambda function and add the code
1. Open **Lambda, then Create function, then Author from scratch**.
2. Name: `ec2-auto-stop`. Runtime: **Python 3.12**. Click **Create function**.
3. Open `auto_stop_ec2_lambda.py`, select all, and copy.
4. In the **Code** tab, delete the old code in `lambda_function.py`, and paste.
5. Click **Deploy**.

- [ ] Deployed

## Step 5: Add the settings
1. **Configuration, then Environment variables, then Edit, then Add environment variable**. Add two:
   - Key: `SNS_TOPIC_ARN`, Value: your topic ARN
   - Key: `DRY_RUN`, Value: `true`
2. **Configuration, then General configuration, then Edit.** Set Timeout to `30 sec` and click **Save**.

`DRY_RUN=true` means Lambda only reports what it would do and changes nothing. You turn it off in Step 8, after testing.

- [ ] Done

## Step 6: Give Lambda permission
1. **Configuration, then Permissions.** Click the **role name** (this opens IAM).
2. **Add permissions, then Create inline policy, then JSON tab**.
3. Paste this, replacing `REGION` and `ACCOUNT_ID` with your values:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": "ec2:DescribeInstances", "Resource": "*" },
    { "Effect": "Allow",
      "Action": ["ec2:StopInstances", "ec2:StartInstances"],
      "Resource": "arn:aws:ec2:REGION:ACCOUNT_ID:instance/*",
      "Condition": { "StringEquals": { "aws:ResourceTag/AutoStop": "true" } } },
    { "Effect": "Allow", "Action": "sns:Publish",
      "Resource": "arn:aws:sns:REGION:ACCOUNT_ID:ec2-autostop-report" }
  ]
}
```
4. Click **Next**. Name it `AutoStopAccess`. Click **Create policy**.

The `Condition` is a safety lock. Even if the code had a bug, AWS would refuse to stop any server that is not tagged `AutoStop=true`.

- [ ] Done

## Step 7: Test in dry-run mode
1. Go back to Lambda, then the **Test** tab, then **Create new event**.
2. Event name: `stop`. Body: `{"action": "stop"}`. Click **Save**, then **Test**.
3. Result should show `"count": 1` and `"dry_run": true`. The email says "Would have stopped: 1 instance(s)" with your instance ID.
4. Check in EC2 that the server is **still running**. Nothing changed.

- [ ] Email received, server untouched

## Step 8: Test for real
1. **Configuration, then Environment variables, then Edit.** Change `DRY_RUN` to `false`. Click **Save**.
2. Run the `stop` test again. In EC2, the instance moves to **Stopping**, then **Stopped**.
3. Create a second test event named `start` with body `{"action": "start"}` and run it. The instance goes back to **Running**.

- [ ] Stop works
- [ ] Start works

## Step 9: Schedule it
Create two schedules. Open **EventBridge, then Scheduler, then Schedules, then Create schedule**.

**Schedule 1: stop at night**
1. Name: `ec2-stop-8pm`.
2. Schedule pattern: **Recurring, then Cron-based schedule**.
   - Cron expression: `0 20 * * ? *`
   - Time zone: `Asia/Kolkata`
   - Flexible time window: **Off**
3. Click **Next**. Target: **AWS Lambda, then Invoke**, and choose `ec2-auto-stop`.
4. In **Input**, paste: `{"action": "stop"}`
5. Click **Next** through the rest, then **Create schedule**.

**Schedule 2: start in the morning (weekdays only)**
1. Name: `ec2-start-8am`.
2. Cron expression: `0 8 ? * MON-FRI *`. Same time zone and settings.
3. Target: the same Lambda. Input: `{"action": "start"}`
4. Click **Create schedule**.

- [ ] Both schedules created. Check your inbox tonight at 8 PM and tomorrow at 8 AM.

---

## If something goes wrong

| Problem | Fix |
|---|---|
| `count: 0` but the server exists | The tag is wrong. Key must be exactly `AutoStop` and value exactly `true`. Also check that the server is in the same region as Lambda. |
| `UnauthorizedOperation` on stop or start | The tag condition in Step 6 doesn't match, or `REGION` / `ACCOUNT_ID` in the policy is wrong. |
| `ValueError: Event must be...` | The test event or schedule input is missing `{"action": "stop"}` or `{"action": "start"}`. |
| Server didn't stop but you got an email | `DRY_RUN` is still `true`. Redo Step 8.1. |
| No email | Subscription not confirmed (Step 3.5), or check spam. |
| `Task timed out` | Timeout is still 3 seconds. Redo Step 5.2. |
| Code change has no effect | You forgot to click **Deploy**. |

## Good to know
- Stopping an instance keeps its disk (EBS). The disk costs a small amount per month, but compute charges stop.
- A server with a normal public IP gets a **new** public IP after each stop and start. Use an Elastic IP if you need a fixed one.
- Never tag a production server unless you want it stopped every night.

## Clean up when finished
Delete in this order, so nothing keeps running:
1. EventBridge schedules `ec2-stop-8pm` and `ec2-start-8am` (**first**)
2. Lambda function `ec2-auto-stop`
3. SNS topic `ec2-autostop-report`
4. IAM role `ec2-auto-stop-role-xxxx`
5. CloudWatch log group `/aws/lambda/ec2-auto-stop`
6. EC2 instance `autostop-test` (**Terminate**, otherwise its disk keeps costing money)
