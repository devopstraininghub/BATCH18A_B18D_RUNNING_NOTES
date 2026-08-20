# Batch 18 — Linux Running Notes: 17 August 2026

**Topic: Server Info Commands, User Management, File Exploration, vi/vim Editor**

Friends, today's class had two big parts — first, checking useful information *about* our server (like how much memory it has), and second, creating and managing **users** on Linux, which is a very important real-world admin skill for any DevOps engineer. We also explored a few handy commands for peeking inside files, and got our first proper hands-on with the `vi`/`vim` editor.

---

## 1. Server information commands

After logging in and switching to root (`sudo su -`), and renaming the server (`hostnamectl set-hostname <ser-name>`), we checked some basic server details:

```
hostname
hostname -I
```
`hostname` shows the server's name. `hostname -I` shows the server's **IP address** — the unique address that identifies this machine on the network.

**Real-time example:** You need the **private IP** to let servers talk to each other internally — for example, an application server connecting to a database server, or Jenkins connecting to a build agent, inside the same VPC. You need the **public IP** to SSH in from your own laptop, or to reference it in a Security Group rule. When a teammate says "I can't reach the server," `hostname -I` is one of the very first commands you'd ask them to run to confirm the server even has the IP they think it does.

**More examples:**
- Comparing the **private** IP (from `hostname -I`) against the **public** IP (checked separately in the AWS console, or via `curl ifconfig.me`) — mixing these two up is a very common beginner connection mistake.
- Using the IP output inside a script to auto-register a new server with a monitoring tool as soon as it comes up.
- Cross-checking `hostname -I` output against the AWS Security Group's allowed IP range when a connection is unexpectedly being blocked.

```
uptime
```
Shows **how long the server has been running** without a restart, along with current time, number of logged-in users, and system load. A server with high uptime is generally a sign of stability.

**More examples:**
- Checking `uptime` right after a patching or reboot window, to confirm the server actually restarted when it was supposed to.
- Comparing `uptime` across a cluster of servers to spot one that rebooted unexpectedly — which could point to a crash nobody noticed yet.
- Including `uptime` in a daily health-check script that DevOps teams run every morning on critical servers.

```
uname
uname -a
```
Already covered on 14 Aug — shows the OS kernel name and, with `-a`, full system details in one shot.

```
lscpu
```
Shows detailed information about the server's **CPU** — how many cores, architecture, speed, and more.

**More examples:**
- Checking core count before deciding how many parallel Jenkins build executors a server can safely run at once.
- Confirming CPU architecture before choosing the right Docker base image (ARM-based vs x86-based images are not interchangeable).
- Used when right-sizing an EC2 instance type for a CPU-heavy workload, like a build server or a data-processing job.

```
free
free -m
free -g
```
Shows how much **RAM (memory)** is being used and how much is free. `free -m` shows the numbers in megabytes, `free -g` shows them in gigabytes — much easier to read than the default raw bytes.

**Real-time example:** Before deploying a memory-heavy application — say a Java app running on Tomcat, or a Jenkins server with many parallel jobs — a DevOps engineer checks `free -m` to make sure there's enough RAM available. An "OutOfMemory" crash in production is one of the most common incident tickets you'll get paged for, and `free -m` (or `free -g` on bigger servers) is very often the first diagnostic command run when investigating why an application suddenly became slow or crashed.

**More examples:**
- Checking memory before and after deploying a new application version, to catch a memory leak early instead of finding out during a production outage.
- Adding `free -h` (human-readable) inside a health-check/monitoring script that raises an alert if free memory drops below a set threshold.
- Comparing memory usage on a Jenkins server before increasing the number of parallel jobs allowed, to avoid overloading it.

---

## 2. User management — creating and managing Linux users

On a real server, multiple people might need their own login — this is exactly how access is managed for a team working on the same shared server.

```
useradd madhu
```
Creates a **new user** called `madhu` on the system.

```
passwd madhu
```
Sets (or resets) the **password** for that user.

```
su - madhu
```
**Switches** from the current user (probably root) to the user `madhu` — as if madhu themselves logged in.

**More examples:**
- `su - jenkins -c "whoami"` — running just **one** command as another user, without doing a full interactive switch.
- Testing whether a deployment script behaves correctly under the actual service account it will run as in production, by switching to that account first.
- Switching to a teammate's account temporarily (with their permission) to reproduce a bug that only shows up on their login.

```
whoami
```
Confirms who you're currently logged in as — after `su - madhu`, this correctly shows `madhu`.

```
exit
```
Logs out of the current user session, taking you back to whoever you were before (e.g., back to root).

**Real-time example:** This is exactly what happens when a new developer joins the team and needs access to a shared dev/QA server: a DevOps engineer creates their Linux account (`useradd`), sets a temporary password (`passwd`), and shares it securely — so that person logs in with their **own** identity instead of everyone sharing one common `root` login. This is a basic security practice that gets checked in almost every compliance/security audit — shared logins mean you can never tell who actually ran a command.

**More examples:**
- `useradd -m devuser` — the `-m` flag explicitly makes sure the home directory is created along with the user (needed on some systems where it isn't automatic).
- Creating separate Linux users per team, like `useradd qa_user` and `useradd dev_user`, to keep permissions and audit trails cleanly separated between teams sharing one server.
- Creating a dedicated **service account** such as `useradd jenkins` — this account isn't for a real person to log in with; it only exists so the Jenkins process runs under its own identity instead of root.

### Where does a user's data live?

**User home directory:** `/home/<username>` — every user gets their own personal folder here.

### `/etc/passwd` — the master list of all users

```
cat /etc/passwd
```
This file contains the **list of all user accounts** on the system, one line per user, in this format:
```
ec2-user:x:1000:1000:EC2 Default User:/home/ec2-user:/bin/bash
madhu:x:1001:1001::/home/madhu:/bin/bash
```
Each line tells you: username, a placeholder for password (`x`, actual password is stored securely elsewhere in `/etc/shadow`), user ID, group ID, description, home directory, and default shell.

**Real-time example:** When investigating a security incident, or preparing a server for an access-review audit, `cat /etc/passwd` is exactly how you'd list every account that exists on that server — to check whether there are stale, unused, or suspicious accounts that should be removed. This is a routine step in server hardening before a production go-live.

**More examples:**
- `cat /etc/passwd | grep bash` — listing only accounts that have an actual login shell (real human or service accounts), filtering out system accounts that can't log in.
- `cat /etc/passwd | wc -l` — quickly counting the total number of accounts that exist on the server.
- Checking `/etc/passwd` again right after running `userdel`, to confirm the account was actually removed.

### Modifying and removing users

```
usermod -c "DevOps User" madhu
```
`usermod` **modifies** an existing user's settings — here, `-c` sets a **comment/description** ("DevOps User") next to madhu's entry in `/etc/passwd`. Useful for noting a person's role or team.

```
userdel -r kiran
```
**Deletes** the user `kiran` completely. The `-r` flag also removes their home directory and all their personal files — without `-r`, the account is removed but their files would still remain behind.

**Real-time example:** `usermod -c` is handy when several teams share the same server, to quickly tag which team/role a login belongs to. `userdel -r` is exactly the step taken during **employee/contractor offboarding** — when someone leaves the project or the company, removing their Linux access completely (account plus home directory) is a mandatory item on every offboarding checklist, so that no old access remains behind as a security gap.

**More examples:**
- `usermod -aG docker devuser` — adding a user to the `docker` group, so they can run Docker commands without needing `sudo` every time. A very common real request from developers.
- `usermod -L username` — **locking** an account temporarily (say, a suspected compromised login) without deleting it outright, so it can be investigated first.
- Running `userdel -r` as the final checklist item during offboarding, only after confirming the person's work/files have been backed up somewhere safe.

---

## 3. Peeking inside files — wc, tail, head, more

```
wc /etc/passwd
wc -l
wc -w
wc -c
```
`wc` stands for **word count**, and by default shows lines, words, and characters (bytes) in a file. `-l` shows only the **line count**, `-w` only the **word count**, `-c` only the **character/byte count**.

**Real-time example:** `wc -l` is a very common piece of a DevOps one-liner — for example, `grep ERROR app.log | wc -l` instantly tells you how many error lines are in a log file, instead of scrolling through the whole thing to count manually. Also used to quickly check "how many users exist on this server" via `wc -l /etc/passwd`.

**More examples:**
- `ls /opt | wc -l` — counting how many folders/files exist inside a directory, without listing and counting them yourself.
- `cat deploy.log | wc -l` — quickly checking how many deployment entries have been logged so far.
- `wc -l < file.txt` — gives just the number, without the filename printed alongside it, which is handy when you want to use that number directly inside a script.

```
tail -n 3 /etc/passwd
```
Shows only the **last 3 lines** of the file — very useful when a file is huge and you only care about the most recent entries.

```
head -n 2 /etc/passwd
```
Shows only the **first 2 lines** of the file — opposite of `tail`.

```
more /etc/passwd
```
Displays the file content **page by page**, letting you scroll through a long file bit by bit, instead of it all flooding your screen at once (like `cat` does).

**Real-time example:** In real production troubleshooting, `tail -f /var/log/app.log` (the **live-following** version of tail, using `-f`) is one of the single most-used commands by DevOps/SRE engineers — you run it right before reproducing a bug or triggering a deployment, and watch the log update in real time as it happens. `head` is used to quickly check the start of a huge log file (like confirming when the application actually started), and `more`/`less` are used when you need to scroll through a large config or log file manually, section by section.

**More examples:**
- `tail -f /var/log/messages` — watching general system logs live, very useful when debugging a service that keeps crashing unexpectedly.
- `tail -100 access.log` — pulling just the last 100 web requests, to quickly check recent traffic patterns.
- `tail -f app.log | grep ERROR` — live-following a log, but showing **only** the lines that contain "ERROR", filtering out all the noise.
- `head -20 bigfile.csv` — quickly peeking at a huge data file's structure/header row, without opening the whole thing.
- `less` (a more modern alternative to `more`) also lets you scroll **backward**, and search inside the file with `/keyword` — most engineers reach for `less` over `more` in real work for exactly this reason.

---

## 4. File creation, and the `vi`/`vim`/`nano` editor

```
touch fname
```
Creates a new empty file.

```
echo "get ready to workhard" > b18file
```
`echo` prints text — and the `>` symbol **redirects** that text into a file, **overwriting** whatever was there before (or creating the file fresh if it didn't exist).

```
echo "adding new content" >> b18file
```
The **double** `>>` also redirects text into a file, but it **appends** (adds to the end) instead of overwriting — the existing content stays safe.

**Real-time example:** This exact pattern is used inside shell scripts and CI/CD pipelines all the time — a Jenkins pipeline step might run `echo "Build #45 deployed at $(date)" >> deployment.log`, appending a new entry every time a build runs, without ever wiping out the history of previous deployments. Using a single `>` there by mistake is a classic scripting bug that silently deletes your entire deployment history on the very next run.

**More examples:**
- `echo "" > file.txt` — quickly empties out a file's content, without deleting the file itself. Handy for clearing a log file that's grown too big.
- `echo "export PATH=$PATH:/opt/tools" >> ~/.bashrc` — permanently adding a tool to your PATH, by appending the line to your shell's config file.
- `date >> deploy.log` — you can redirect the output of **any** command, not just `echo` — this logs the exact timestamp of a script step into a file.

### vi / vim / nano — text editors inside the terminal

These are all **text editors that run directly inside your terminal** — no separate app window needed, unlike Notepad or VS Code. `vim` is an improved version of the older `vi`; `nano` is a simpler, beginner-friendly alternative.

```
vim fname
```
Opens (or creates, if it doesn't exist) the file `fname` inside the vim editor.

```
Esc, then i          → enters Insert mode (now you can type)
   ----- data ----
   ----- data ----
Esc                  → leaves Insert mode, back to Normal/Command mode
:w                    → write/save the file
:q                    → quit the editor
:wq!                  → save and quit, forcefully (even overriding read-only warnings)
```

**Real-time example:** `vim` is unavoidable in DevOps work — you'll use it constantly to quickly edit a `Jenkinsfile`, a Kubernetes YAML manifest, a `docker-compose.yml`, or a config file directly on a remote server over SSH, where there's no GUI editor available at all. Vim always opens in "Command mode" by default — if you start typing immediately without pressing `i` first, nothing appears on screen, and your keystrokes get treated as commands instead (a very common first-day confusion). Even engineers who use VS Code for everything locally eventually get comfortable with at least `i`, `Esc`, `:wq`, because a production server over SSH gives you nothing else to edit files with.

**More examples:**
- `vim -R filename` — opens a file in **read-only** mode, useful when you just want to safely view a critical config without any risk of accidentally editing it.
- Typing `/searchword` inside vim to jump straight to a specific word or line in a huge Jenkinsfile or YAML file, instead of scrolling manually.
- `:set nu` inside vim shows line numbers — very helpful when a build error message says something like "error at line 42" and you need to find that exact line fast.

```
date
```
Simply prints the current date and time of the server.

---

## Quick Recap Table

| Command | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `hostname -I` | Shows server's IP address | First check when a teammate says "I can't reach this server" |
| `free -m` / `-g` | Shows RAM usage in MB/GB | First diagnostic command when an app crashes with OutOfMemory |
| `useradd` | Creates a new user | Onboarding a new developer onto a shared dev/QA server |
| `passwd` | Sets/resets a user's password | Giving that developer their own login credentials |
| `su - <user>` | Switch to that user's session | Testing an issue "as" a specific user account |
| `/etc/passwd` | Master list of all users | Auditing a server for stale/suspicious accounts |
| `usermod -c` | Add a description/comment to a user | Tagging which team a login belongs to on a shared server |
| `userdel -r` | Delete user AND their home folder | Standard step during employee/contractor offboarding |
| `wc -l` | Count lines in a file | `grep ERROR app.log \| wc -l` — quick error count in a log |
| `tail -n` / `tail -f` | Show last N lines / live-follow a file | Watching a log update in real time during a deployment |
| `head -n` | Show first N lines of a file | Checking when an application actually started, in a huge log |
| `more` | View a file page by page | Reading a large config/log file section by section |
| `echo "text" > file` | Overwrite file with text | Risk: accidentally wiping a deployment log in a script |
| `echo "text" >> file` | Append text to end of file | Correct way to keep appending deployment history in a script |
| `vim fname` | Open/create file in vim editor | Editing a Jenkinsfile or K8s YAML directly over SSH |

That's today's session, friends — user management and file exploration are things you'll use almost every single day as a DevOps engineer, so make sure to practice these hands-on, not just read them.
