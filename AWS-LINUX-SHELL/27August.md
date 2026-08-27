# Batch 18 — Linux Running Notes: 27 August 2026

**Topic: Shell Scripting Basics — Shebang, Variables, Your First Script (`read`), Real Jenkins/Tomcat Setup Scripts, Command-Line Arguments, Debugging (`set -x`/`set -e`)**

Friends, until now we've been running Linux commands one at a time by hand. Today we start **shell scripting** — putting a whole sequence of commands into one file, so it runs automatically instead of you typing it every single time. This is the real starting point of automation, and everything you'll later do in Jenkins/Ansible builds on this same idea.

---

## 1. What is a shell script, and why bother?

- A **shell script** is just a plain text file containing a list of Linux commands, in the same order you'd normally type them.
- Saved with a **`.sh`** extension (e.g. `setup.sh`) — this is a convention, not a hard rule; Linux will run it even without `.sh`.
- The whole point: **automation**. Anything you do repeatedly — installing software, creating folders, checking logs — is a candidate for a script. Write once, run forever.

**Real-time example:** Setting up a new server every week means typing the same 15 commands each time — install Java, download Tomcat, start it. A script turns that 10-minute manual routine into one command: `./setup.sh`. This is also the stepping stone toward Jenkins/Ansible, which automate the same idea at a much bigger scale.

**Easy memory trick:** shell script → type it once, run it forever.

---

## 2. What is a variable?

A **variable** is a name that holds a piece of data — a labeled box you fill once and refer back to by name.

```bash
Name="Madhu"
echo "Hello, $Name"
```

**Sample output:**
```
$ ./greet.sh
Hello, Madhu
```
`Name` is the variable, `"Madhu"` is the value inside it, and `$Name` is how you read that value back anywhere later in the script — `$` means "give me the value stored here."

---

## 3. The shebang (`#!`) line

The **shebang** is always the very first line of a script — it tells Linux which program should run the rest of the file.

```bash
#!/bin/bash
#!/bin/sh
#!/bin/dash
```

| Part | Meaning |
|---|---|
| `#!` | marks this as a shebang, not a regular comment |
| `/bin/bash` etc. | full path to the **interpreter** that will execute the script |

We use `#!/bin/bash` throughout, since `bash` is the most common shell.

**Real-time example:** Without a shebang, Linux has no idea whether a file's content is Bash, Python, or something else — the shebang removes all that guesswork, which is why it's always the first thing checked.

---

## 4. Your first script — taking input with `read`

**File: `devopsengineer.sh`**
```bash
#!/bin/bash

echo "Enter the DevOps engineer Name:"
read Name
mkdir $Name
cd $Name
touch linux jenkins ansible k8s
mkdir aws
cd aws
touch ec2 efs eks route53 s3
```

| Line | What it does |
|---|---|
| `echo "Enter..."` | prints a question to the screen |
| `read Name` | pauses, waits for keyboard input, stores it in variable `Name` |
| `mkdir $Name` / `cd $Name` | creates a folder using whatever the user typed, then moves into it |
| `touch ...` | creates empty placeholder files for DevOps tools |
| `mkdir aws` / `cd aws` / `touch ...` | same idea, one level deeper, for AWS services |

**Sample output:**
```
$ ./devopsengineer.sh
Enter the DevOps engineer Name:
kiran
```
Result:
```
kiran/
├── linux
├── jenkins
├── ansible
├── k8s
└── aws/
    ├── ec2
    ├── efs
    ├── eks
    ├── route53
    └── s3
```

**Real-time example:** This single script demonstrates the whole foundation of scripting in one go — taking input (`read`), storing it (`$Name`), and driving multiple commands off that one value.

---

## 5. Real script — Jenkins installation

**File: `jenkinssetup.sh`**
```bash
#!/bin/bash

##################
### Author : Madhukiran
#### Date: 27 AUG 2026
#### Version : V1
#### Purpose: To setup Jenkins

sudo yum update -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
sudo yum install java-21-amazon-corretto -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

- Any line starting with `#` (except the shebang) is a **comment** — ignored by Linux, but a real production habit: always note who wrote it, when, version, and why.
- `-y` on every `yum` command auto-confirms prompts so the script never stalls waiting for a human.
- `wget -O ...jenkins.repo` — downloads Jenkins's repo file to the exact path the system expects.
- `rpm --import ...key` — imports Jenkins's signing key, so the package can be verified as genuine.
- Java is installed first because Jenkins (like Tomcat) is a Java application and can't run without it.
- `systemctl enable` — auto-starts Jenkins on every reboot. `systemctl start` — starts it right now.

**Real-time example:** A multi-step, error-prone manual install (easy to forget a step or mistype something) becomes one reliable, repeatable command: `./jenkinssetup.sh`. That's the entire value of scripting in one example.

---

## 6. Real script — Tomcat installation + finding its PID

**File: `tomcatsetup.sh`**
```bash
#!/bin/bash

cd /opt
yum install java -y
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.121/bin/apache-tomcat-9.0.121.tar.gz
tar -xvf /opt/apache-tomcat-9.0.121.tar.gz
/opt/apache-tomcat-9.0.121/bin/startup.sh

echo "THE TOMCAT PROCESS ID IS :"
ps -ef | grep tomcat | awk -F" " '{print $2}' | head -1
```

**The PID line, broken down — chaining 4 commands with pipes:**

| Step | Command | Does |
|---|---|---|
| 1 | `ps -ef` | lists every running process |
| 2 | `\| grep tomcat` | filters down to lines mentioning "tomcat" |
| 3 | `\| awk -F" " '{print $2}'` | splits by space, prints column 2 — the PID in `ps -ef` output |
| 4 | `\| head -1` | keeps just the first line, in case more than one matched |

**Real-time example:** Pipe-chaining like this — feeding one command's output into the next — is a core shell habit; this exact one-liner is how a deployment script tells you "your app just started, here's its PID," with zero manual reading.

**Easy memory trick:** `|` (pipe) → "feed my output into the next command's input."

---

## 7. Debugging a script

| Command | Does |
|---|---|
| `set -x` | turn ON debug mode — Bash prints every command (prefixed `+`) right before running it |
| `set +x` | turn debug mode back OFF (note: `+` disables here, `-` enables — the one confusing exception) |
| `bash -x scriptname.sh` | run a script in debug mode without editing the file at all |
| `set -e` | exit the script immediately the moment any command fails, instead of ploughing on |

**Sample output:**
```bash
#!/bin/bash
set -x
mkdir testdir
```
```
+ mkdir testdir
```

**Real-time example:** `set -x` lets you *see* exactly what a misbehaving script is doing internally, including what values variables actually expanded to; `set -e` stops it *safely* the instant something breaks, instead of continuing on broken assumptions (e.g. installing into a folder that failed to get created).

---

## 8. Command-line arguments — `$0`, `$1`, `$2`

Instead of asking with `read`, you can supply values directly when you **run** the script — Bash stores them automatically in `$1`, `$2`, ... in the order typed.

**File: `test.sh`**
```bash
#!/bin/bash
echo "script Name: $0"
echo "FIRST Name: $1"
echo "second Argument: $2"
```

| Variable | Meaning |
|---|---|
| `$0` | the script's own name |
| `$1` | first argument typed after the script name |
| `$2` | second argument |

**Sample output:**
```
$ ./test.sh kiran devops
script Name: ./test.sh
FIRST Name: kiran
second Argument: devops
```

**Rewriting section 4's script to use arguments instead of `read`:**
```bash
#!/bin/bash

set -x
set -e

#echo "Enter the DevOps engineer Name:"
#read Name
mkdir $1
cd $1
touch linux jenkins ansible k8s
mkdir aws
cd aws
touch ec2 efs eks route53 s3
```
- The old `echo`/`read` lines are commented out, not deleted — a common habit: keep the old approach visible but switched off, don't lose it.
- `mkdir $1` / `cd $1` now use the first command-line argument instead of asking interactively.

**Real-time example:** The interactive version (`read Name`) needs a human sitting at the keyboard — it can never be automated. The argument version can be triggered unattended, by `cron`, or by a Jenkins/CI pipeline: `./devopsengineer_CLA.sh kiran`. This exact shift is what makes a script usable inside real automation pipelines instead of just at a human's terminal.

**Easy memory trick:** `read` → script asks a human. `$1`/`$2` → script gets told, no human needed.

---

## Quick Recap Table

| Command / Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `#!/bin/bash` | Shebang — picks the interpreter | First line of every script, no exceptions |
| `Name="value"` / `$Name` | Set / read a variable | Storing a folder name typed in by the user |
| `read Name` | Take input from the keyboard | A script asking "which environment?" |
| `mkdir` / `touch` inside a `.sh` | Automate repeated setup steps | Building a standard folder structure for every new project |
| `yum install ... -y` in a script | Unattended package installs | `jenkinssetup.sh`, `tomcatsetup.sh` |
| `ps -ef \| grep x \| awk ... \| head -1` | Chain commands with pipes | Extracting a running app's PID automatically |
| `set -x` / `set +x` | Turn script debug tracing on/off | Watching exactly what a broken script is doing |
| `set -e` | Stop the script on first failure | Avoiding a deploy script that limps on after a real error |
| `$0`, `$1`, `$2` | Script name / positional arguments | Running `./setup.sh kiran` unattended from a CI pipeline |
