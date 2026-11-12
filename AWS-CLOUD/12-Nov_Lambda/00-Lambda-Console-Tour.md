# AWS Lambda Console Tour: Every Part Explained

Open the Lambda console and follow along. Screens change slightly over time, but the parts below stay the same.

**Contents**
1. The Lambda home: Dashboard and Functions list
2. Inside a function: the layout
3. Function overview: Diagram and Template
4. Code tab
5. Test tab
6. Monitor tab
7. Configuration tab (every sub-tab)
8. Aliases and Versions
9. What happens when you run your code
10. Reading the logs
11. Cheat sheet

---

## 1. The Lambda home

Search **Lambda** in the console and open it. The left menu has:

| Menu item | What it shows |
|---|---|
| **Dashboard** | Account-wide summary: number of functions, total code storage, and graphs of invocations, errors and concurrent executions for the whole region |
| **Functions** | The list of your functions, where you click one to open it |
| **Layers** | Shared libraries you can attach to functions |
| **Applications** | Bundles of Lambda plus related resources deployed together |
| **Additional resources** | Lambda's help, tutorials and sample code |

**The Functions list** has these columns:

| Column | Meaning |
|---|---|
| Function name | The name you chose |
| Description | Optional note |
| Package type | `Zip` (code file) or `Image` (container) |
| Runtime | The language, for example Python 3.12 |
| Last modified | When you last changed it |

Click **Create function** to make a new one. The top-right corner shows the **Region**. Functions are per region, so if a function seems "missing", check the region first.

---

## 2. Inside a function: the layout

Click a function name. The page has two parts:

```
┌────────────────────────────────────────────────────────────────────┐
│  FUNCTION OVERVIEW      [ Diagram | Template ]                     │
│   (picture of triggers → function → destinations, plus info)       │
├────────────────────────────────────────────────────────────────────┤
│  Tabs:  Code | Test | Monitor | Configuration | Aliases | Versions │
│  (each tab has its own content below)                              │
└────────────────────────────────────────────────────────────────────┘
```

Top-right buttons: **Throttle**, **Copy ARN**, and **Actions** (publish a new version, create an alias, delete function, export).

> **ARN** (Amazon Resource Name) is the function's unique address, such as `arn:aws:lambda:ap-south-1:123456789012:function:daily-cost-report`.

---

## 3. Function overview: Diagram and Template

### Diagram tab
A picture of how your function is connected:

```
  TRIGGERS (left)        FUNCTION (middle)         DESTINATIONS (right)
┌───────────────┐      ┌──────────────────┐      ┌───────────────────┐
│ + Add trigger │ ───▶ │ daily-cost-report│ ───▶ │ + Add destination │
│ (S3, Event-   │      │                  │      │ (SQS, SNS, Lambda,│
│  Bridge, ...) │      │  ▪ Layers (0)    │      │  EventBridge)     │
└───────────────┘      └──────────────────┘      └───────────────────┘
```

| Part | Meaning |
|---|---|
| **+ Add trigger** | Choose what starts the function (S3 upload, schedule, queue message, and so on) |
| **Function box** | Your function, with the number of **layers** attached |
| **+ Add destination** | Where to send the result after an async run (success or failure) |
| **Description, Last modified, Function ARN, Function URL** | Details shown beside the diagram |

When you add a trigger, it appears as a box on the left of the diagram. This is the quickest way to check what is connected.

### Template tab
Shows the function **as code**: a CloudFormation / SAM template (YAML) describing the same function. It is read-only here. Use it to:
- Recreate the function in another account or region
- Learn how "infrastructure as code" describes a function

You can ignore it for beginner labs. Just know that anything you click in the console can also be written as a template.

---

## 4. Code tab

This is where you write and deploy your code.

```
┌─ Code source ───────────────────────────────────────────────────────┐
│ Explorer          │  lambda_function.py                              │
│  ▸ daily-cost-... │  import boto3                                    │
│     lambda_func.. │  def lambda_handler(event, context):             │
│                   │      ...                                         │
│ [Deploy] [Test]   │                                                  │
├───────────────────┴──────────────────────────────────────────────────┤
│ Output / Execution results                                           │
├─ Runtime settings ──────────────────────────────────────────────────┤
│  Runtime: Python 3.12      Handler: lambda_function.lambda_handler   │
├─ Layers ────────────────────────────────────────────────────────────┤
│  (shared libraries attached to this function)                        │
└──────────────────────────────────────────────────────────────────────┘
```

| Part | What it does |
|---|---|
| **File explorer** (left) | The files in your function (`lambda_function.py`) |
| **Editor** (middle) | Write your code here |
| **Deploy** | **Saves your code into Lambda.** Without this, your edit is not live. |
| **Test** | Runs the function with the selected test event |
| **Execution results tab** | Shows the response, the logs and the duration after a test |
| **Runtime settings → Edit** | Change the language version or the **Handler** |
| **Layers** | Attach shared libraries (for example, Pillow) |
| **Code properties** | Package size and SHA256 hash of the code |

### What is the Handler setting?
`lambda_function.lambda_handler` means:
- file: `lambda_function.py`
- function inside the file: `lambda_handler`

If you rename either one and don't update the Handler, you get *"Unable to import module"* or *"Handler not found"*.

> **Always click Deploy after editing.** The most common beginner mistake is testing old code.

---

## 5. Test tab

Run your function with sample input, without any real trigger.

| Part | Meaning |
|---|---|
| **Test event action** | Create new event, or Edit saved event |
| **Event name** | Any name, for example `now` |
| **Event sharing settings** | Private (only you) or Shareable (others in the account) |
| **Template** | Ready-made sample events (for example `hello-world`, S3 Put, SNS, API Gateway) |
| **Event JSON** | The input your function receives as `event` |
| **Save** | Keeps the event for reuse |
| **Test** | Runs the function now |

After you click **Test**, the **Execution results** show:

| Result field | Meaning |
|---|---|
| **Status: Succeeded / Failed** | Green or red |
| **Response** | What your function returned |
| **Function Logs** | Everything you printed, plus the system lines |
| **Request ID** | Unique ID for this run |
| **Duration / Billed duration** | How long it ran, and what you pay for |
| **Resources configured / Max memory used** | The memory you set, and the memory used |

> A test event is a **made-up trigger**. For our project the body is just `{}`, because the function doesn't need input.

---

## 6. Monitor tab

Shows how your function behaves over time. Data comes from **CloudWatch**.

### Metrics (graphs)
| Graph | Meaning | Good or bad |
|---|---|---|
| **Invocations** | How many times it ran | Shows usage |
| **Duration** | How long each run took (min / avg / max) | Rising = slower code |
| **Error count and success rate** | Failed runs vs successful runs | You want 100% success |
| **Throttles** | Runs rejected because the concurrency limit was hit | Should be 0 |
| **Concurrent executions** | How many ran at the same time | Shows load |
| **Async delivery failures, Iterator age, etc.** | For advanced triggers | Ignore for beginners |

Use the **time range** buttons (1h, 3h, 12h, 1d, 3d, 1w) at the top. Graphs may take 1 to 2 minutes to update.

### Buttons and links
| Button | Use |
|---|---|
| **View CloudWatch logs** | Opens the function's log group |
| **View X-Ray traces** | Request tracing (needs X-Ray turned on) |
| **View Lambda Insights** | Advanced monitoring (optional, extra cost) |

### Logs section
Recent invocations are listed with their request IDs. Click one to jump to its log.

---

## 7. Configuration tab

This is the control panel of the function. The left side has sub-menus:

### 7.1 General configuration
| Setting | Meaning | Default | Our project |
|---|---|---|---|
| **Description** | A note | none | optional |
| **Memory** | RAM given to the function (128 MB to 10,240 MB). More memory also gives more CPU. | 128 MB | default |
| **Ephemeral storage** | Temporary disk space in `/tmp` | 512 MB | default |
| **Timeout** | Maximum run time before Lambda stops it | **3 sec** | **30 sec** |
| **SnapStart** | Faster startup (Java only) | off | n/a |
| **Execution role** | The IAM role the function runs as | auto-created | default |

### 7.2 Triggers
Lists everything that starts the function. For each one you can **Edit**, **Disable** or **Delete**. (Our schedule appears here once it's connected, or in EventBridge.)

### 7.3 Permissions
Two parts:

| Part | Meaning |
|---|---|
| **Execution role** | *What the function can do.* Click the role name to open IAM. This is where we add the `ce:GetCostAndUsage` and `sns:Publish` policy. It also shows which AWS services the role can use. |
| **Resource-based policy** | *Who can invoke the function.* For example, EventBridge or S3 is allowed to call it. |

### 7.4 Destinations
Send the result of an **asynchronous** run to another service: on **success** and on **failure**, to SQS, SNS, Lambda or EventBridge. Optional.

### 7.5 Function URL
A free built-in web address for the function. Auth type is `NONE` (public) or `AWS_IAM`. We don't use it in this project.

### 7.6 Environment variables
Key/value settings kept **outside** the code. Our project uses `SNS_TOPIC_ARN`.

```python
os.environ["SNS_TOPIC_ARN"]     # reads the value in code
```
They can be encrypted with a KMS key. Never store passwords here in plain text. Use Secrets Manager.

### 7.7 Tags
Labels such as `Project=CostReport`, useful for organising and for tracking costs by tag.

### 7.8 VPC
Place the function inside a private network (to reach private databases). **Leave empty** for beginner labs.

### 7.9 Monitoring and operations tools
Turns on logging format (text or JSON), the log group, X-Ray tracing and Lambda Insights.

### 7.10 Concurrency (and recursion detection)
| Setting | Meaning |
|---|---|
| **Reserved concurrency** | The maximum number of copies that may run at once, which also protects other functions |
| **Provisioned concurrency** | Keeps copies warm to avoid cold starts (extra cost) |

### 7.11 Asynchronous invocation
Retry behaviour for async triggers: **maximum age of event** and **retry attempts** (default 2 retries).

### 7.12 Other items you may see
| Item | Meaning |
|---|---|
| **Code signing** | Allow only trusted, signed code |
| **File systems** | Attach an EFS drive |
| **State machines** | Step Functions workflows that use this function |
| **RDS databases** | Create a database proxy connection |

---

## 8. Aliases and Versions

| Tab | Meaning |
|---|---|
| **Versions** | A **frozen snapshot** of your code and settings. `$LATEST` is the one you edit. **Actions → Publish new version** makes numbered versions (1, 2, 3) that never change. |
| **Aliases** | A **friendly pointer** to a version, such as `prod → version 3`. Triggers can call the alias, so you can switch versions without changing the trigger. |

Beginners can skip both. Everything we do runs `$LATEST`.

---

## 9. What happens when you run your code

You click **Test**, or the schedule fires. Here is the whole journey:

```
 ① Request           ② Find a place          ③ Start up (cold only)       ④ Run            ⑤ Finish
┌────────────┐      ┌──────────────────┐     ┌───────────────────────┐    ┌───────────┐    ┌─────────────┐
│ Invoke     │ ───▶ │ Lambda looks for │ ──▶ │ • create environment  │ ─▶ │ handler   │ ─▶ │ return      │
│ (Test /    │      │ a free, ready    │     │ • download your code  │    │ (event,   │    │ value,      │
│  trigger)  │      │ environment      │     │ • start the runtime   │    │  context) │    │ logs sent,  │
└────────────┘      └──────────────────┘     │ • run code outside    │    └───────────┘    │ environment │
                       │ found one?          │   the handler         │         │           │ kept warm   │
                       │ yes = WARM, skip ③  └───────────────────────┘         │ print()   └─────────────┘
                       └─────────────────────────────────────────────▶         ▼
                                                                       CloudWatch Logs
```

**Step by step**
1. **Invoke:** the Test button (or EventBridge) tells Lambda to run the function with an `event`.
2. **Find an environment:** Lambda looks for a ready container for your function.
3. **Cold start (only if none is ready):** Lambda creates a new container, loads your code, starts Python and runs everything at the top of your file. This adds a short delay (the `Init Duration`).
4. **Run the handler:** `lambda_handler(event, context)` runs. Your code can call other services, using the permissions in the **execution role**.
5. **Finish:** the return value goes back to the caller, your `print()` output goes to CloudWatch, and the container waits (warm) for the next call. If it stays idle for a long time, Lambda removes it.

**If something goes wrong**
| What happens | Result |
|---|---|
| Code raises an error | Status **Failed**, with the error type and the line number |
| Runs longer than Timeout | `Task timed out after X seconds` |
| Uses more memory than set | `Runtime exited ... OutOfMemory` |
| Role lacks permission | `AccessDeniedException` in the logs |

**What happens in our project when it runs**
1. EventBridge Scheduler invokes `daily-cost-report` at 8 AM.
2. The handler asks Cost Explorer for yesterday's cost (needs `ce:GetCostAndUsage`).
3. It builds the text report.
4. It publishes to SNS (needs `sns:Publish`), and SNS emails you.
5. The function returns `{"sent": true}`, and the logs are saved in CloudWatch.

---

## 10. Reading the logs

Open **Monitor → View CloudWatch logs → latest log stream**. Each run produces these lines:

```
START RequestId: 8f1c...  Version: $LATEST
AWS report for 2026-10-07                      <- your print() output
Services used: 4
Total cost: $0.42
END RequestId: 8f1c...
REPORT RequestId: 8f1c...  Duration: 842.10 ms  Billed Duration: 843 ms
       Memory Size: 128 MB  Max Memory Used: 78 MB  Init Duration: 410.55 ms
```

| Line | Meaning |
|---|---|
| **START** | The run began |
| *Your lines* | Everything you `print()` |
| **END** | The run finished |
| **REPORT** | The summary of the run |
| **Duration** | Actual run time |
| **Billed Duration** | Time you pay for |
| **Memory Size / Max Memory Used** | Configured RAM vs RAM actually used |
| **Init Duration** | Cold-start time. It **appears only on cold starts**. |

A **log group** is named `/aws/lambda/<function-name>`. Each environment writes a **log stream** inside it.

---

## 11. Cheat sheet

| I want to... | Go to |
|---|---|
| Write or change code | **Code** tab, then **Deploy** |
| Run with sample input | **Test** tab |
| See errors and run counts | **Monitor** tab |
| See what my code printed | Monitor → **View CloudWatch logs** |
| Change timeout or memory | Configuration → **General configuration** |
| Add a secret setting or URL | Configuration → **Environment variables** |
| Give Lambda permission to use a service | Configuration → **Permissions** → role → add policy |
| Make something start the function | **Add trigger** (diagram), or EventBridge |
| Add a web link to the function | Configuration → **Function URL** |
| Add shared libraries | Code tab → **Layers** |
| Freeze a stable copy | Actions → **Publish new version** |
| Delete the function | **Actions → Delete function** |

### Five rules to remember
1. **Deploy** after every code change.
2. The default **timeout is only 3 seconds**. Raise it for real work.
3. **Permissions** come from the execution role, so fix `AccessDenied` there.
4. **Logs** live in CloudWatch. Read them when anything fails.
5. Check the **Region** (top right) when you can't find something.
