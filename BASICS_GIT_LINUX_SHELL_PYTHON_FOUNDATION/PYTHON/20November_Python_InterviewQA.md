# Batch 18 — Running Notes: 20 November 2026

**Topic: Python Interview Questions**

Friends, today is a pure interview-prep session — Python's core data types, list/tuple/set/dict operations, the libraries worth naming in an interview, and real-world DevOps scripts using them.

---

### Q1. What are the different data types in Python?

**Answer:** Python's built-in data types:

| Type | Holds | Example |
|---|---|---|
| **Numbers** — `int`, `float`, `complex` | Whole, decimal, and complex numbers | `10`, `10.5`, `2 + 3j` |
| **String** | Text, in single/double/triple quotes | `'Hello'`, `"Python"`, `"""Welcome"""` |
| **List** | Ordered, changeable, allows duplicates | `["us-east-1a", "us-east-1b", "us-east-1c"]` |
| **Tuple** | Ordered, unchangeable, allows duplicates | `("us-east-1a", "us-east-1b", "us-east-1c")` |
| **Range** | A sequence of numbers | `range(10)` → `0` through `9`; `range(4, 10)` → `4` through `9` |
| **Set** | Unordered, changeable, no duplicates | `{"us-east-1a", "us-east-1b", "us-east-1c"}` |
| **Dictionary** | Key-value pairs | `{'person1': 'John', 'person2': 'Doe'}` |

- `bool` (`True`/`False`) and `NoneType` (`None`) are also core built-in types, worth naming if an interviewer pushes further than this list.
- `type(variable_name)` tells you a variable's current type; `dir(variable_name)` lists every method/attribute available on it.

```python
x = "30.0"
print(f"datatype of variable x is {type(x)}")
print(f"The methods/functions for x are {dir(x)}")
```

---

### Q2. What's the difference between a List and a Tuple?

**Answer:** Both are ordered, index-based, and iterable. The real differences:

| | List | Tuple |
|---|---|---|
| Mutability | Mutable — elements can be added, removed, or changed | Immutable — fixed once created |
| Operations | Supports `append()`, `extend()`, `remove()`, `pop()` | No modification methods at all |
| Performance/memory | Slightly slower | Faster, and uses less memory |

**Summary:** Use a `list` when the data needs to change; use a `tuple` when it should stay constant.

---

### Q3. What's the difference between a List and a Set?

**Answer:** A `list` is an **ordered** collection that **can** contain duplicates. A `set` is an **unordered** collection that **cannot** contain duplicates.

---

### Q4. How do you check the memory used by a variable, list, or tuple?

**Answer:** `sys.getsizeof()`, from the `sys` module.

```python
import sys

x = 10
my_list = [1, 2, 3]
my_tuple = (1, 2, 3)

print(sys.getsizeof(x))
print(sys.getsizeof(my_list))
print(sys.getsizeof(my_tuple))
```
- Returns the size in **bytes**.
- It's a **shallow** size — the size of the container object itself, not a sum including every nested element inside it.

---

### Q5. What tools do you use for Python practice?

**Answer:**
- **Visual Studio Code** — for day-to-day scripting.
- **Jupyter Notebook** — when doing data analysis.
- **IPython** — for interactive coding, running small snippets quickly.

---

### Q6. Can you convert a List to a Set?

**Answer:** Yes, with the built-in `set()` function.

```python
my_list = ["apple", "banana", "apple", "cherry"]
my_set = set(my_list)
print(my_set)
```
- Sets automatically remove duplicates, and the result is unordered.

---

### Q7. How do you add items to a list?

**Answer:** `append()` and `insert()`.

| Method | What it does |
|---|---|
| `my_list.append("item")` | Adds an item to the **end** of the list |
| `my_list.insert(index, "item")` | Adds an item at a **specific position** |

```python
my_list = ["apple", "banana"]

my_list.append("cherry")
my_list.insert(1, "orange")

print(my_list)
```
**Sample output:**
```
['apple', 'orange', 'banana', 'cherry']
```

---

### Q8. How do you remove items from a list?

**Answer:** `remove()` and `pop()`.

| Method | What it does |
|---|---|
| `my_list.remove("item")` | Removes the **first occurrence** of that value |
| `my_list.pop()` | Removes and returns the **last** item |
| `my_list.pop(index)` | Removes and returns the item at that **specific index** |

```python
my_list = ["apple", "banana", "cherry", "banana"]

my_list.remove("banana")
my_list.pop()
my_list.pop(0)

print(my_list)
```
**Sample output** (step by step: `remove("banana")` → `['apple', 'cherry', 'banana']`; `pop()` → removes `'banana'`, leaving `['apple', 'cherry']`; `pop(0)` → removes `'apple'`):
```
['cherry']
```

---

### Q9. How do you print the keys and values of a dictionary?

**Answer:**

| Goal | Code |
|---|---|
| All keys | `person.keys()` |
| All values | `person.values()` |
| Keys and values together | `for k, v in person.items(): print(k, "--->", v)` |
| One specific value | `person.get("name")` or `person["name"]` |

```python
person = {
    "name": "John",
    "age": 30,
    "city": "New York"
}

print(person.keys())
print(person.values())

for k, v in person.items():
    print(k, "--->", v)

print(person.get("name"))
print(person["name"])
```

---

### Q10. What Python libraries/modules are you familiar with?

**Answer:**

| Library | Category | Used for |
|---|---|---|
| `os`, `sys` | Standard library | OS interaction, env vars, `sys.argv`, `sys.getsizeof()` |
| `json` | Standard library | `json.dumps()` (Python → JSON string), `json.loads()` (JSON string → Python) |
| `shutil` | Standard library | High-level file ops — `shutil.copy()`, `shutil.copytree()`, `shutil.move()`, `shutil.rmtree()` |
| `boto3` | AWS SDK | Interacting with AWS services — S3, EC2, DynamoDB |
| `requests` | External | Making HTTP requests — GET, POST, PUT, DELETE |
| `flask` / `fastapi` | External | Building REST APIs — FastAPI adds async support and automatic docs |
| `faker` | External | Generating fake test data |
| `uuid` | Standard library | Generating unique identifiers |
| `python-dotenv` | External | Loading environment variables from a `.env` file |
| `psutil` | External | System/process info — CPU, memory, disk, running processes |
| `IPython` | External | Interactive Python development and testing |
| `matplotlib` / `pandas` / `numpy` | External (data analysis) | Visualization, data manipulation, numerical operations |

---

### Q11. Where have you actually used Python?

**Answer:** Mainly for automation, cloud operations, and DevOps scripting — for example, using Python and `boto3` to find unused AWS resources (stopped EC2 instances, unattached EBS volumes) to cut cloud costs.

**`cleanup_stopped_instances.py`:**
```python
import boto3

REGION = "us-east-1"

ec2 = boto3.client("ec2", region_name=REGION)

def get_stopped_instances():
    response = ec2.describe_instances(
        Filters=[
            {"Name": "instance-state-name", "Values": ["stopped"]}
        ]
    )

    instances = []
    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            instances.append(instance["InstanceId"])

    return instances


if __name__ == "__main__":
    stopped_instances = get_stopped_instances()

    if not stopped_instances:
        print("No stopped EC2 instances found.")
    else:
        print("Stopped EC2 Instances:")
        for instance_id in stopped_instances:
            print(instance_id)

        # Uncomment after confirmation
        # ec2.terminate_instances(InstanceIds=stopped_instances)
        # print("Stopped instances terminated successfully.")
```
- `describe_instances()`'s response is nested two levels deep: `Reservations` → each one's `Instances` → each one's `InstanceId`. That's why the loop is nested too.

**`cleanup_old_volumes.py`:**
```python
import boto3
from datetime import datetime, timezone, timedelta

REGION = "us-east-1"
DAYS_OLD = 7

ec2 = boto3.client("ec2", region_name=REGION)

cutoff_date = datetime.now(timezone.utc) - timedelta(days=DAYS_OLD)

def get_old_unattached_volumes():
    response = ec2.describe_volumes(            # response is a dictionary here
        Filters=[
            {"Name": "status", "Values": ["available"]}
        ]
    )

    volumes = []
    for volume in response["Volumes"]:
        if volume["CreateTime"] < cutoff_date:
            volumes.append(volume["VolumeId"])

    return volumes


if __name__ == "__main__":
    old_volumes = get_old_unattached_volumes()

    if not old_volumes:
        print("No old unattached EBS volumes found.")
    else:
        print("Old Unattached EBS Volumes (>7 days):")
        for vol_id in old_volumes:
            print(vol_id)

        # Uncomment after confirmation
        # for vol_id in old_volumes:
        #     ec2.delete_volume(VolumeId=vol_id)
        # print("Old volumes deleted successfully.")
```
- An EBS volume with status `"available"` means it's **not attached** to any instance — that's the filter doing the real work here.
- `cutoff_date` is computed once, outside the loop — comparing `volume["CreateTime"]` (a timezone-aware datetime straight from boto3) against it is what identifies volumes older than `DAYS_OLD` days.
- Both scripts follow the same safe pattern: **list first, destroy only after uncommenting** — never delete/terminate anything automatically without a human confirming the list first.

**The describe-call shapes worth remembering:**

| Call | Top-level response key |
|---|---|
| `describe_instances()` | `Reservations` → `Instances` |
| `describe_volumes()` | `Volumes` |
| `describe_snapshots()` | `Snapshots` |

---

### Q12. Have you worked on APIs using Python?

**Answer:** Yes — building REST APIs with **Flask**/**FastAPI**, and consuming external REST APIs with the **requests** library (GET/POST/PUT/DELETE calls, handling JSON responses, validating HTTP status codes).

---

### Q13. What's the difference between a List and a Dictionary?

**Answer:**

| | List | Dictionary |
|---|---|---|
| Order | Ordered | Unordered |
| Duplicates | Allowed | Keys cannot duplicate; values can |
| Access | By index (`0`, `1`, `2`, ...) | By key |
| Mutable? | Yes | Yes |

```python
my_list = [10, 20, 20, 30]
my_dict = {"name": "John", "age": 30, "city": "NY"}
```

---

### Q14. How many ways can you reverse a list?

**Answer:**

| Code | Behavior |
|---|---|
| `my_list.reverse()` | Reverses the list **in place** — modifies the original |
| `my_list[::-1]` | Returns a **new** reversed list, original untouched |
| `reversed(my_list)` | Returns a **reversed iterator**, original untouched |

---

### Q15. How do you create a multiline string?

**Answer:** Triple quotes — `'''...'''` or `"""..."""`.

```python
s = '''This is a
multiline string'''

print(s)
```
- Python preserves the line breaks exactly as written inside the triple quotes.

---

### Q16. How do you take input from the user?

**Answer:** `input()`.

```python
name = input('Enter your name: ')
```

---

### Q17. How do you convert a string to a list?

**Answer:** `split()` — breaks a string apart using a separator (space, comma, etc.).

```python
X = 'WELCOME TO DEVOPS/SRE TRAINING'
result = X.split(' ')
print(result)
```
**Sample output:**
```
['WELCOME', 'TO', 'DEVOPS/SRE', 'TRAINING']
```

---

### Q18. How do you convert a list back to a string?

**Answer:** `join()`.

```python
X = ['WELCOME', 'TO', 'DEVOPS/SRE', 'TRAINING']
print(' '.join(X))
```
**Sample output:**
```
WELCOME TO DEVOPS/SRE TRAINING
```

---

### Q19. How do you extract information using the `requests` module?

```python
import requests

response = requests.get('https://jsonplaceholder.typicode.com/posts')
print(response.status_code)
print(response.json())
```
- `.status_code` — the HTTP status code (e.g. `200` for success).
- `.json()` — parses the response body straight into a Python list/dict.

---

### Q20. How do you handle exceptions in Python?

**Answer:** `try` / `except` / `finally`.

| Block | Role |
|---|---|
| `try` | The code that might raise an exception |
| `except` | Catches the exception and handles it |
| `finally` | Always runs (optional) — used for cleanup |

```python
try:
    x = 10 / 0
except Exception as e:
    print("Error:", e)
finally:
    print("This block always runs.")
```
**Sample output:**
```
Error: division by zero
This block always runs.
```

---

### Q21. How do you install a package in Python?

**Answer:**
```bash
pip install package_name
# or
pip3 install package_name
```
- Search for a package's exact name first at **pypi.org**.

---

### Q22. How do you generate fake test data?

**Answer:** The **Faker** library.

```python
from faker import Faker

fake = Faker()

print(fake.name())
print(fake.email())
print(fake.address())
print(fake.profile())
```

**Generating 100 fake email addresses:**
```python
from faker import Faker

fake = Faker()

for i in range(100):
    print(fake.profile()['mail'])
```
- `fake.profile()` returns a whole dictionary of fake fields at once (name, address, job, mail, and more) — `['mail']` pulls just the email out of it.

---

### Q23. What are a DevOps engineer's day-to-day uses of Python?

**Answer:**

**1. Automation & scripting:**
- Automating repetitive tasks.
- Writing scripts for backups, cleanup, and deployments.
- Automating server provisioning and configuration.

**2. Cloud operations (AWS/Azure/GCP):**
- Managing cloud resources using SDKs like `boto3` or the Azure SDK.
- Creating, updating, and deleting resources (EC2, S3, VMs, storage).
- Automating scaling and cost optimization tasks.

**3. CI/CD pipeline support:**
- Writing Python scripts used in Jenkins, GitHub Actions, GitLab CI.
- Automating build, test, and deployment steps.
- Validating artifacts before deployment.

**4. Monitoring and logging:**
- Collecting system metrics (CPU, memory, disk) using `psutil`.
- Parsing and analyzing log files.
- Sending alerts and notifications.

**5. Infrastructure automation:**
- Integrating Python with tools like Terraform and Ansible.
- Writing custom Ansible modules or helpers.
- Validating infrastructure state.

**6. API integration:**
- Calling REST APIs using `requests`.
- Integrating with tools like Jira, Slack, ServiceNow.
- Automating ticket creation and status updates.

**7. Configuration and secrets management:**
- Managing environment variables using `python-dotenv`.
- Reading configuration files (JSON, YAML).
- Securing secrets and credentials.

**8. File and system operations:**
- Working with files and directories using `os` and `shutil`.
- Archiving, copying, and cleaning files.
- Managing permissions.

**9. Troubleshooting and debugging:**
- Writing quick scripts to debug production issues.
- Checking service health and process status.
- Analyzing failures and root cause.

**10. Reporting and notifications:**
- Generating reports from logs or metrics.
- Sending email or Slack notifications.
- Creating dashboards or summaries.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `sys.getsizeof(x)` | Shallow memory size, in bytes | Checking memory cost of a variable or data structure |
| List vs Tuple | Mutable + slower vs immutable + faster, less memory | Use a tuple for fixed config, a list for data that changes |
| List vs Set vs Dict | Ordered+duplicates vs unordered+unique vs key-value | A cluster's server list, a set of unique error codes, env vars |
| `my_list[::-1]` / `reversed()` | Non-destructive ways to reverse a list | Keep the original order intact elsewhere in the script |
| `split()` / `join()` | String ↔ list conversions | Parsing a CSV-style line, or rebuilding one |
| `try`/`except`/`finally` | Handle failures gracefully, always clean up | Catching `ZeroDivisionError`, `FileNotFoundError`, etc. |
| `boto3` cleanup scripts | List resources first, destroy only after a human confirms | Finding stopped EC2s / unattached EBS volumes before deleting |
| `requests` | `.status_code` + `.json()` for consuming REST APIs | Calling a third-party API and parsing its JSON response |
