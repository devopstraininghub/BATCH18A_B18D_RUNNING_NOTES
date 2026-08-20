# Batch 18 — Linux Running Notes: 14 August 2026

**Topic: AWS Free Tier Account Created, First EC2 Server, Basic Identity Commands**

Friends, today was the exciting day — we actually created our AWS Free Tier account and launched our very first server (EC2 instance). Till yesterday it was all theory; from today we start touching real things. Don't worry if it feels new, these are literally the first commands every DevOps engineer runs on any new server.

---

## 1. What is an EC2 instance?

**EC2** stands for **Elastic Compute Cloud** — in simple words, it is just a virtual server running inside AWS's datacenter, which you can rent by the hour. Once you launch it, you "connect" into it remotely, and then you can run Linux commands on it just like any server.

**Real-time example:** This is literally day 1 of almost every real DevOps task. Before you can set up Jenkins, install Docker, deploy an application, or configure monitoring, you first need a server to work on. Provisioning a server — via the AWS console like today, or later using Terraform/CloudFormation once you're more advanced — is one of the most frequent things a DevOps engineer does, whether it's spinning up a temporary server to debug an issue, or a permanent one to host a production application.

---

## 2. Connecting to the server — first commands

Once you connect to a freshly launched EC2 instance, by default you land as a limited user called `ec2-user`.

```
whoami
```
This tells you **who you are currently logged in as**. Right after connecting, running this shows `ec2-user` — confirming you're not the all-powerful root user yet.

```
sudo su -
```
This command **switches you to the root user** — the "superuser" who has full permissions to do anything on the server (install software, create users, change system files, etc.). `sudo` means "do this as superuser," and `su -` means "switch user" (to root, by default, with a fresh login environment).

**Real-time example:** In real projects, DevOps engineers almost always SSH in as a limited user (`ec2-user`, `ubuntu`) and only escalate to root (`sudo su -`) when actually required — for example, installing Docker or Jenkins needs root, but simply checking a log file or a config doesn't. Staying logged in as root by default, out of habit, is flagged as a bad practice in almost every security audit and DevOps interview, because a mistyped command as root can do far more damage than the same mistake as a normal user.

```
hostnamectl set-hostname linux
```
This command **renames your server** to something meaningful — here, `linux`. By default, AWS gives long, auto-generated hostnames; renaming it to something short and clear (like `linux`, or later `b18linux`) makes it much easier to identify, especially when you're managing multiple servers.

**Real-time example:** On a real project you might be managing 15–20 EC2 instances at once — one running Jenkins, one running SonarQube, two or three running your application, one running a database. If every server keeps AWS's default auto-generated hostname like `ip-172-31-45-12`, you'll have no clue which is which the moment you SSH in. Renaming servers to `jenkins-server`, `sonar-server`, `app-server-1` is standard practice on every real DevOps project, and often required by internal naming-convention policies.

```
exit
```
This **logs you out of the current session** — for example, exiting out of root back to `ec2-user`, or exiting the server connection entirely, depending on where you run it.

```
sudo su -
```
We switch to root again, since after renaming the hostname, the change often needs a fresh shell session to fully reflect.

```
hostname
```
This simply **prints the current hostname** of the server — a quick way to confirm your `hostnamectl set-hostname` command actually worked.

```
uname
uname -a
```
`uname` prints the **name of the operating system kernel** (typically shows `Linux`). `uname -a` prints **all** the system information in one shot — kernel name, hostname, kernel version, architecture (like x86_64), and more.

**Real-time example:** Before installing any software — say Docker, Java, or a specific Jenkins agent — a DevOps engineer runs `uname -a` first to confirm the OS and CPU architecture (x86_64 vs ARM/Graviton). Installing the wrong binary for the wrong architecture is a very common beginner mistake when setting up a new EC2 instance, and it's the first thing to check when a downloaded package "just won't run."

---

## 3. Practicing basic Linux commands on Windows (via Git Bash)

Since not everyone has an EC2 server running all the time, we also practiced the same basic commands using **Git Bash** on our Windows laptops — Git Bash gives you a Linux-style terminal experience even on Windows.

```
pwd
```
"Print working directory" — shows you exactly which folder you are standing in right now.

```
ls
ll
ls -lrth
```
- `ls` — lists files and folders in the current directory.
- `ll` — same, but with extra details: permissions, owner, size, and modified date.
- `ls -lrth` — long listing (`l`), reverse order (`r`), human-readable sizes like KB/MB instead of raw bytes (`h`), sorted by modification time (`t`) — so your most recently touched files show up last, easy to spot.

**Real-time example:** You'll run `ll` constantly on real servers — for example, right after cloning a repo or pulling a deployment script, to check its file permissions before running it. A script without execute permission fails immediately with "permission denied," and `ll` is the first thing every DevOps engineer checks to confirm the `x` (execute) permission is actually set.

```
touch file1 file2 file3
```
Creates three empty files in one shot — `touch` is normally used to create a new, blank file (or update its "last modified" time if it already exists).

```
mkdir dir1 dir2 dir3
```
Creates three empty folders (directories) in one shot.

```
clear
```
(or **Ctrl + L**) — clears everything on your screen, giving you a fresh, clean terminal view. It doesn't delete any files — just cleans up the *display*.

```
rm -rf fname/dir
```
**Deletes** a file or folder — `r` means recursive (go inside folders and delete everything inside too), `f` means force (don't ask for confirmation, just do it).

⚠️ **Important:** There is **no undo** for `rm -rf`. Once you run it, that file/folder is gone permanently — no recycle bin, no "restore" option like Windows.

**Real-time example:** One of the most repeated DevOps horror stories is an engineer accidentally running `rm -rf` in the wrong directory — or worse, from the wrong server entirely — and wiping out live application files or logs on a production system. The standard safety habit every senior DevOps engineer follows: always run `pwd` and `ls` first to confirm exactly where you are and exactly what you're about to delete, **before** running `rm -rf`. This one habit prevents most self-inflicted production incidents.

```
cat fname
```
Prints the **entire content** of a file directly on the screen — like opening a file and reading everything written inside it.

**Real-time example:** You'll use `cat` constantly to quickly inspect config and script files — `cat Dockerfile`, `cat Jenkinsfile`, `cat /etc/hosts` — any time you need to see exactly what's inside a file without opening a full editor.

```
cd <dirname>
cd ..
```
- `cd dirname` — moves you **into** that folder.
- `cd ..` — moves you **out**, one level up (to the parent folder).

```
history
```
Shows you the **list of all commands you've typed** recently in this terminal session.

**Real-time example:** When troubleshooting "what did I just run that broke this deployment," `history` is often the very first command a DevOps engineer checks — especially useful when debugging together with a teammate on a screen share, to show exactly which commands were run, and in what order, leading up to the issue.

---

## Quick Recap Table

| Command | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `whoami` | Shows current logged-in user | Confirming you're `ec2-user`, not root, before running risky commands |
| `sudo su -` | Switch to root (superuser) | Escalating only when installing Docker/Jenkins, not by default |
| `hostnamectl set-hostname` | Rename the server | Naming servers `jenkins-server`, `app-server-1` across a fleet |
| `uname -a` | Show full OS/kernel info | Checking architecture (x86_64/ARM) before installing software |
| `pwd` | Show current folder location | Confirming your location before running `rm -rf` |
| `ls` / `ll` | List files/folders (with details) | Checking a deploy script has execute permission before running it |
| `touch` | Create empty file(s) | Creating a placeholder file for a script or log |
| `mkdir` | Create folder(s) | Setting up a project/deployment folder structure |
| `rm -rf` | Permanently delete file/folder | The #1 cause of accidental production incidents if used carelessly |
| `cat` | Print full file content on screen | Quickly checking a Dockerfile/Jenkinsfile/config file |
| `cd` | Move into/out of a folder | Navigating between project and deployment directories |
| `history` | Show recently typed commands | Reviewing exactly what commands led to a broken deployment |

That's today's session, friends — we now have our own live AWS server, and we know the basic commands to move around on it confidently. Next class, we go deeper into user management and file exploration.
