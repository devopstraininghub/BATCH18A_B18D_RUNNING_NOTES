# Batch 18 — Linux Running Notes: 27 August 2026

**Topic: Shell Scripting Basics — Shebang, Variables (Scope, Special Variables, Env Vars), Your First Script (`read`), Real Jenkins/Tomcat Setup Scripts, Command-Line Arguments, Debugging (`set -x`/`set -e`)**

Friends, until now we've been running Linux commands one at a time by hand. Today we start **shell scripting** — putting a whole sequence of commands into one file, so it runs automatically instead of you typing it every single time. This is the real starting point of automation, and everything you'll later do in Jenkins/Ansible builds on this same idea. It's a longer session, so we're covering variables in full depth (scope, special variables, environment variables) along with the scripting basics — conditionals, loops, and functions continue in tomorrow's notes.

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

When a script isn't behaving the way you expect, you need some way to see *what exactly it's doing*, step by step — that's exactly what these are for.

- **`set -x`** — turn ON debug mode. Once this line runs, Bash prints out **every single command** right before it executes it (prefixed with a `+`), so you can watch exactly what the script is doing internally, including what values the variables actually expanded to.
- **`set +x`** — turn debug mode back **OFF** (note it's `+` here, not `-` — this is the one exception in shell scripting where `+` disables something and `-` enables it, a bit confusing at first, but you get used to it).
- **`bash -x scriptname.sh`** — an alternate way to debug **without touching the script file at all**: just run the whole script in debug mode straight from the command line.
- **`set -e`** — "exit on error." Normally, if one command inside a script fails, Bash simply moves on to the next line anyway — which can be dangerous (imagine continuing to install software into a folder that actually failed to get created). `set -e` changes this: the moment **any** command in the script fails (returns a non-zero exit status — Linux's way of signalling "something went wrong"), the entire script stops immediately, instead of blindly continuing on broken assumptions.

**Sample output:**
```bash
#!/bin/bash
set -x
mkdir testdir
```
```
+ mkdir testdir
```

**Real-time example:** `jenkinssetup.sh` (section 5) failing halfway through on a new server — running `bash -x jenkinssetup.sh` shows you exactly which line failed and why, instead of guessing; adding `set -e` at the top would also have stopped it immediately at that failing line, instead of continuing to run the remaining `yum`/`systemctl` commands on a half-broken setup.

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

## 9. Types of variables — Local, Shell, Environment

A variable's **scope** decides *where* its value is visible.

| Type | In simple words | Created with |
|---|---|---|
| Local | Only exists inside one function; gone once that function finishes | `local var1="value"` (inside a function) |
| Shell | Exists only for your current terminal session — scripts run from it can't see it | `var3="value"` |
| Environment | **Exported** — visible to your session AND any child process/script it launches | `export VAR2="value"` |

**Sample output:**
```
$ export VAR2="visible everywhere"
$ var3="only here"
$ bash                      # start a new child shell
$ echo $VAR2
visible everywhere          # still visible — it was exported
$ echo $var3
                             # empty — var3 was never exported
```

**Real-time example:** `PATH`, `JAVA_HOME`, `AWS_ACCESS_KEY_ID` are environment variables for exactly this reason — many different tools/scripts need to read them, and a plain shell variable simply wouldn't be visible to those other programs.

**Easy memory trick:** the whole difference between a shell variable and an environment variable is one word — `export`.

---

## 10. Special variables — `$0`, `$#`, `$*`, `$@`, `$?`

**File: `cla.sh`**
```bash
#!/bin/bash

echo "The name of this script is: $0"
echo "The first argument is: $1"
echo "The second argument is: $2"
echo "Number of arguments passed: $#"
echo "All the arguments passed - as SINGLE word: $*"
echo "All the arguments passed - as individual words: $@"
echo "Exit status is: $?"
```

| Variable | Meaning |
|---|---|
| `$0` | the name of the script itself |
| `$1`, `$2`, ... | the 1st, 2nd, ... argument passed to the script |
| `$#` | the **count** — how many arguments were passed in total |
| `$*` | all arguments combined together as **one single string** |
| `$@` | all arguments kept as **separate, individual items** |
| `$?` | the **exit status** of the last command that ran — `0` means success, any non-zero number means it failed |

**Running it:**
```
$ ./cla.sh aws devops linux
The name of this script is: ./cla.sh
The first argument is: aws
The second argument is: devops
Number of arguments passed: 3
All the arguments passed - as SINGLE word: aws devops linux
All the arguments passed - as individual words: aws devops linux
```
At first glance, `$*` and `$@` look completely identical when just printed with `echo` — the real difference only shows up the moment you **loop over them**, as we'll see next. Don't get confused yet, keep reading.

### `$*` vs `$@` — the real difference

**File: `diff.sh`**
```bash
#!/bin/bash

for i in "$*";
#for i in "$@";
do
    echo $i
done
```
This is a `for` loop: "for each item `i` in the given list, print it." The key thing being tested here is **what counts as "one item"**, when the arguments are quoted.

**Running it with `"$*"` (as written above):**
```
$ ./diff.sh aws devops linux
aws devops linux
```
The loop runs **only once**, because `"$*"` glues all the arguments into **one single combined string** — so the loop sees just one big item: `"aws devops linux"`.

**Now switch the comment, so `"$@"` is used instead:**
```bash
#for i in "$*";
for i in "$@";
do
    echo $i
done
```
```
$ ./diff.sh aws devops linux
aws
devops
linux
```
Now the loop runs **three times**, once for each argument, because `"$@"` keeps every single argument as its **own separate item**.

**The takeaway, in plain words:**
- `"$*"` = "treat all the arguments as **one long sentence**."
- `"$@"` = "treat each argument as **its own separate word**."
- In real scripts, where you need to process arguments **one at a time** inside a loop (which is the case most of the time), `"$@"` is almost always the correct choice. Remember this for interviews too — commonly asked question.

**Easy memory trick:** `$?` → "did the last thing work?" `$@` → "give me each argument separately."

---

## 11. Reading and unsetting a variable

- **`read name`** — pause, wait for keyboard input, store it in `name` (already used in section 4).
- **`unset name`** — deletes a variable completely, as if it never existed.

**File: `unsetex.sh`**
```bash
#!/bin/bash

name="Madhu kiran"

echo $name

unset name

echo $name  # Output: (nothing, the variable is unset)
```
**What happens when you run it:**
```
$ ./unsetex.sh
Madhu kiran

```
- The first `echo $name` prints `Madhu kiran`, because the variable is still holding its value at that point.
- `unset name` wipes it out completely.
- The second `echo $name` prints **nothing at all** (just a blank line), because as far as Bash is concerned now, `name` doesn't exist anymore.

A second version of the same idea, with clearer labels attached:

**File: `unset.sh`**
```bash
#!/bin/bash

name="Madhu kiran"

echo "printing variable: $name"

unset name

echo "printing variable: $name"  # Output: (nothing, the variable is unset)
```
```
$ ./unset.sh
printing variable: Madhu kiran
printing variable:
```

---

## 12. Environment variables — checking and configuring

Environment variables are *dynamic* and *system-wide* — they let you customise how software and the OS itself behaves. Many are **user-specific** (different users on the same machine can have different values for the same variable name). Here's the everyday walkthrough, one command at a time:

- **`env`** — lists **every** environment variable currently set, along with its value.
- **`echo HOSTNAME`** — prints the literal text `HOSTNAME` — **not** its value. No `$` sign means "just print this word as-is," not "look up this variable."
- **`echo $HOSTNAME`** — prints the **actual value** of the `HOSTNAME` variable (the machine's name). The `$` is what tells Bash "please look this variable up."
- **`env | grep USER`** — lists all environment variables, then filters that list down to only the lines containing "USER".
- **`export TESTNAME=testmadhu`** — creates a **new** environment variable called `TESTNAME`, and exports it (makes it visible to child processes) in one single step.
- **`printenv USER`** — an alternative to `echo $USER` — prints the value of one specific environment variable, by name.
- **`unset COLOR`** — removes an environment variable completely.

**Sample output — walking through create, check, and remove:**
```
$ export TESTNAME=testmadhu
$ echo $TESTNAME
testmadhu

$ printenv USER
madhu

$ export COLOR=blue
$ printenv COLOR
blue

$ unset COLOR
$ printenv COLOR
                    (nothing prints — COLOR no longer exists)
```

⚠️ **Common beginner trap:** `echo VARNAME` (no `$`) just prints the word itself as plain text; `echo $VARNAME` (with `$`) looks up and prints the value stored inside it. This is one of the most common beginner mix-ups in shell scripting, so be careful with this.

**Real-time example:** `env | grep USER` or `printenv` is the first thing to check when a script behaves differently on your machine vs. a teammate's — often it's one missing/different environment variable.

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
| `export VAR=value` | Create an environment variable | `PATH`, `JAVA_HOME` — visible to child scripts too |
| `$*` vs `$@` | All args as one string / as separate items | Looping over arguments one at a time — use `"$@"` |
| `$#` / `$?` | Argument count / last command's exit status | Checking a deploy script actually succeeded |
| `unset name` | Delete a variable completely | Clearing a sensitive value once a script no longer needs it |
