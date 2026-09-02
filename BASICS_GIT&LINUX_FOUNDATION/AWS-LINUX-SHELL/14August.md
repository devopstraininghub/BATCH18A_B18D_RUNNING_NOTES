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

**Sample output:**
```
$ whoami
ec2-user
```

**More examples:**
- Running `whoami` right after every fresh SSH login, as a quick sanity check that you landed on the correct server/account and not some other saved session.
- Inside a shell script, checking identity before doing risky work: `if [ "$(whoami)" != "root" ]; then echo "Please run as root"; exit 1; fi`.
- On a Jenkins build agent, running `whoami` inside a pipeline stage to confirm which service account is actually executing the build.

```
sudo su -
```
This command **switches you to the root user** — the "superuser" who has full permissions to do anything on the server (install software, create users, change system files, etc.). `sudo` means "do this as superuser," and `su -` means "switch user" (to root, by default, with a fresh login environment).

**Sample output:**
```
$ sudo su -
[root@ip-172-31-45-12 ~]#
```
Notice the prompt itself changes from `$` to `#` — in Linux, a `#` prompt is the visual signal that you are now root. Always glance at your prompt symbol before typing a command, especially a destructive one.

**Real-time example:** In real projects, DevOps engineers almost always SSH in as a limited user (`ec2-user`, `ubuntu`) and only escalate to root (`sudo su -`) when actually required — for example, installing Docker or Jenkins needs root, but simply checking a log file or a config doesn't. Staying logged in as root by default, out of habit, is flagged as a bad practice in almost every security audit and DevOps interview, because a mistyped command as root can do far more damage than the same mistake as a normal user.

**More examples:**
- `sudo yum install docker -y` — running just **one** command as root, without switching your whole session to root. Lighter and safer than a full `sudo su -` for a single task.
- `sudo su - jenkins` — switching into the `jenkins` service user specifically (not root), to test a script exactly as that account would run it.
- `sudo -i` — another very common way admins log in as root, works almost the same as `sudo su -`. You'll see both used interchangeably across projects.

```
hostnamectl set-hostname linux
```
This command **renames your server** to something meaningful — here, `linux`. By default, AWS gives long, auto-generated hostnames; renaming it to something short and clear (like `linux`, or later `b18linux`) makes it much easier to identify, especially when you're managing multiple servers.

**Sample output:**
```
$ hostnamectl set-hostname linux
$ hostname
linux
```
Notice `hostnamectl set-hostname` itself prints nothing back — that's normal in Linux, "no output" usually means "it worked." We confirm the change worked by separately running `hostname` right after.

**Real-time example:** On a real project you might be managing 15–20 EC2 instances at once — one running Jenkins, one running SonarQube, two or three running your application, one running a database. If every server keeps AWS's default auto-generated hostname like `ip-172-31-45-12`, you'll have no clue which is which the moment you SSH in. Renaming servers to `jenkins-server`, `sonar-server`, `app-server-1` is standard practice on every real DevOps project, and often required by internal naming-convention policies.

**More examples:**
- `hostnamectl set-hostname docker-host` — naming a server that's specifically dedicated to running Docker containers.
- `hostnamectl set-hostname db-server-prod` — clearly marking a production database server, so nobody confuses it with a test/QA one and accidentally runs a risky command on it.
- `hostnamectl` (with no argument at all) — just shows the current hostname plus other OS details, without changing anything. Good for a quick check.

```
exit
```
This **logs you out of the current session** — for example, exiting out of root back to `ec2-user`, or exiting the server connection entirely, depending on where you run it.

**Sample output:**
```
[root@ip-172-31-45-12 ~]# exit
logout
$
```
The prompt flips back from `#` to `$` — confirming you're a normal user again, not root.

```
sudo su -
```
We switch to root again, since after renaming the hostname, the change often needs a fresh shell session to fully reflect.

```
hostname
```
This simply **prints the current hostname** of the server — a quick way to confirm your `hostnamectl set-hostname` command actually worked.

**Sample output:**
```
$ hostname
linux
```

```
uname
uname -a
```
`uname` prints the **name of the operating system kernel** (typically shows `Linux`). `uname -a` prints **all** the system information in one shot — kernel name, hostname, kernel version, architecture (like x86_64), and more.

**Sample output:**
```
$ uname
Linux
$ uname -a
Linux linux 5.10.223-190.872.amzn2.x86_64 #1 SMP Fri Jun 21 20:00:39 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
```

**Real-time example:** Before installing any software — say Docker, Java, or a specific Jenkins agent — a DevOps engineer runs `uname -a` first to confirm the OS and CPU architecture (x86_64 vs ARM/Graviton). Installing the wrong binary for the wrong architecture is a very common beginner mistake when setting up a new EC2 instance, and it's the first thing to check when a downloaded package "just won't run."

**More examples:**
- `uname -r` — shows just the **kernel version**, useful when checking compatibility for a specific driver or kernel module before installing it.
- `uname -m` — shows the **machine architecture** (`x86_64`, `aarch64`), important before pulling a Docker image or downloading a binary built for a specific chip type.
- Comparing `uname -a` output across two servers that are behaving differently, to quickly rule out an OS/kernel version mismatch as the cause.

---

## 3. Practicing basic Linux commands on Windows (via Git Bash)

Since not everyone has an EC2 server running all the time, we also practiced the same basic commands using **Git Bash** on our Windows laptops — Git Bash gives you a Linux-style terminal experience even on Windows.

```
pwd
```
"Print working directory" — shows you exactly which folder you are standing in right now.

**Sample output:**
```
$ pwd
/c/Users/Madhukiran/Desktop/27july
```

**More examples:**
- Running `pwd` before any risky command like `rm -rf`, as a safety check — confirm exactly where you are before deleting anything.
- Inside a shell script: `echo "Running from $(pwd)"` — logs the working directory into your output, so it's easier to debug later if the script behaves oddly.
- Confirming you're inside the correct cloned repo folder before running `git` commands or a build tool like Maven.

```
ls
ll
ls -lrth
```
- `ls` — lists files and folders in the current directory.
- `ll` — same, but with extra details: permissions, owner, size, and modified date.
- `ls -lrth` — long listing (`l`), reverse order (`r`), human-readable sizes like KB/MB instead of raw bytes (`h`), sorted by modification time (`t`) — so your most recently touched files show up last, easy to spot.

**Sample output:**
```
$ ls
file1  file2  file3

$ ll
total 0
-rw-r--r-- 1 Madhukiran 197121 0 Aug 14 10:15 file1
-rw-r--r-- 1 Madhukiran 197121 0 Aug 14 10:15 file2
-rw-r--r-- 1 Madhukiran 197121 0 Aug 14 10:15 file3
```

**Real-time example:** You'll run `ll` constantly on real servers — for example, right after cloning a repo or pulling a deployment script, to check its file permissions before running it. A script without execute permission fails immediately with "permission denied," and `ll` is the first thing every DevOps engineer checks to confirm the `x` (execute) permission is actually set.

**More examples:**
- `ls -la` — also shows **hidden** files (names starting with a dot, like `.env`, `.git`), which plain `ls` doesn't show at all.
- `ll /var/log` — quickly check log files with their sizes and timestamps, to spot which log has grown too large.
- `ls -lrth /opt` — see most recently installed/updated software at a glance, since newest items are sorted to the bottom.

```
touch file1 file2 file3
```
Creates three empty files in one shot — `touch` is normally used to create a new, blank file (or update its "last modified" time if it already exists).

**Sample output:**
```
$ touch file1 file2 file3
$ ls
file1  file2  file3
```

**More examples:**
- `touch app.log` — create an empty log file **before** an application starts writing to it, so a `tail -f app.log` doesn't error out saying the file doesn't exist.
- Quickly creating a placeholder file to test folder permissions/ownership, before writing the real deployment script.
- `touch -c report.txt` — updates the timestamp of a file only if it already exists, without creating a new one if it's missing (used in some build scripts to "mark as seen").

```
mkdir dir1 dir2 dir3
```
Creates three empty folders (directories) in one shot.

**Sample output:**
```
$ mkdir dir1 dir2 dir3
$ ls
dir1  dir2  dir3
```

**More examples:**
- `mkdir releases` — a standard folder created before a deployment script drops a fresh build inside it.
- `mkdir backup_$(date +%F)` — automatically creating a dated backup folder inside a script, so every backup gets its own folder by date.
- Creating separate folders per environment, like `mkdir dev qa prod`, to keep configs organized on a shared server.

```
clear
```
(or **Ctrl + L**) — clears everything on your screen, giving you a fresh, clean terminal view. It doesn't delete any files — just cleans up the *display*.

**Sample output:**
```
$ clear
(screen is wiped clean, no output — your files/folders are untouched)
```

**More examples:**
- Clearing the screen before starting a fresh troubleshooting session, so old, unrelated output doesn't confuse you.
- Clearing the terminal before taking a screenshot to share with a teammate, so it doesn't show unrelated earlier commands.
- Using **Ctrl + L** as a quick shortcut when you're typing continuously and don't want to break your flow by reaching for the mouse or typing the full word.

```
rm -rf fname/dir
```
**Deletes** a file or folder — `r` means recursive (go inside folders and delete everything inside too), `f` means force (don't ask for confirmation, just do it).

⚠️ **Important:** There is **no undo** for `rm -rf`. Once you run it, that file/folder is gone permanently — no recycle bin, no "restore" option like Windows.

**Sample output:**
```
$ ls
dir1  dir2  dir3

$ rm -rf dir1
$ ls
dir2  dir3
```
Notice `rm -rf` itself prints nothing when it succeeds — silence means success in Linux. `dir1` is simply gone from the next `ls`.

**Real-time example:** One of the most repeated DevOps horror stories is an engineer accidentally running `rm -rf` in the wrong directory — or worse, from the wrong server entirely — and wiping out live application files or logs on a production system. The standard safety habit every senior DevOps engineer follows: always run `pwd` and `ls` first to confirm exactly where you are and exactly what you're about to delete, **before** running `rm -rf`. This one habit prevents most self-inflicted production incidents.

**More examples:**
- `rm -rf old_build/` — cleaning up an old build folder before a fresh deployment copies in the new one.
- `rm -rf *.tmp` — removing all temporary files matching a pattern, usually as a cleanup step at the end of a script.
- `rm -ri some_folder` — the safer, **interactive** version, where the system asks "delete this file? y/n" one by one. Slower, but many cautious engineers use this on a production server instead of a blind `-rf`.

```
cat fname
```
Prints the **entire content** of a file directly on the screen — like opening a file and reading everything written inside it.

**Sample output:**
```
$ echo "My name is madhukiran" > madhukiran
$ cat madhukiran
My name is madhukiran
```

**Real-time example:** You'll use `cat` constantly to quickly inspect config and script files — `cat Dockerfile`, `cat Jenkinsfile`, `cat /etc/hosts` — any time you need to see exactly what's inside a file without opening a full editor.

**More examples:**
- `cat /etc/os-release` — quickly check which Linux distro and version a server is running.
- `cat error.log | grep "Exception"` — combining `cat` with `grep` to pull out just the lines you care about from a big file.
- `cat file1 file2 > combined.txt` — merging the content of two files into one new file, in a single command.

```
cd <dirname>
cd ..
```
- `cd dirname` — moves you **into** that folder.
- `cd ..` — moves you **out**, one level up (to the parent folder).

**Sample output:**
```
$ pwd
/c/Users/Madhukiran/Desktop/27july
$ cd dir2
$ pwd
/c/Users/Madhukiran/Desktop/27july/dir2
$ cd ..
$ pwd
/c/Users/Madhukiran/Desktop/27july
```

**More examples:**
- `cd -` — jumps you back to the **previous** folder you were in. Very handy when bouncing back and forth between two folders repeatedly.
- `cd` (or `cd ~`) — takes you straight to your home directory from anywhere, no matter how deep you are.
- `cd /opt/apache-tomcat-9.0.121/logs` — a very typical DevOps move: jumping directly into an application's log folder the moment something goes wrong.

```
history
```
Shows you the **list of all commands you've typed** recently in this terminal session.

**Sample output:**
```
$ history
    1  pwd
    2  touch file1 file2 file3
    3  mkdir dir1 dir2 dir3
    4  ls
    5  rm -rf dir1
    6  cat madhukiran
    7  history
```

**Real-time example:** When troubleshooting "what did I just run that broke this deployment," `history` is often the very first command a DevOps engineer checks — especially useful when debugging together with a teammate on a screen share, to show exactly which commands were run, and in what order, leading up to the issue.

**More examples:**
- `history | grep docker` — searching your entire command history for every Docker-related command you've run so far.
- `!55` — re-runs command number 55 straight from history, without needing to retype the whole thing.
- `history -c` — clears your command history, done before handing over a shared or demo server to someone else, so your old commands aren't visible to them.

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
