# Batch 18 — Linux Running Notes: 20 August 2026

**Topic: Starting/Stopping Tomcat, Linux Processes (`ps`/`kill`), `grep`, `diff`/`sdiff`, `top -Bn1`, `find`, `sed`**

Friends, in the last class we downloaded Tomcat using `wget`, and covered compressing/extracting it with zip and tar. Today we actually **start** Tomcat and see it running, and along the way learn what a **process** is, how to search inside files (`grep`), compare files (`diff`), watch system load in a script-friendly way (`top -Bn1`), search the filesystem (`find`), and do bulk find-and-replace editing (`sed`) — all commands you'll use almost daily as a DevOps engineer. We'll have a full separate session on Tomcat later; today is just enough to get it running and understand the process concept around it.

---

## 1. Starting and stopping Tomcat

```
tar -xvf apache-tomcat-9.0.121.tar.gz
cd /opt/apache-tomcat-9.0.121
cd bin
./startup.sh
```
After extracting Tomcat, its scripts live inside the `bin` folder. `./startup.sh` **starts** the Tomcat server — `./` in front means "run this script from the current folder," since Linux doesn't automatically search the current directory for executables like Windows does.

**Sample output:**
```
$ cd /opt/apache-tomcat-9.0.121/bin
$ ./startup.sh
Using CATALINA_BASE:   /opt/apache-tomcat-9.0.121
Using CATALINA_HOME:   /opt/apache-tomcat-9.0.121
Using CATALINA_TMPDIR: /opt/apache-tomcat-9.0.121/temp
Using JRE_HOME:        /usr
Using CLASSPATH:       /opt/apache-tomcat-9.0.121/bin/bootstrap.jar:/opt/apache-tomcat-9.0.121/bin/tomcat-juli.jar
Tomcat started.
```

Once started, Tomcat is reachable in a browser at `http://<server-IP>:8080`.

```
./shutdown.sh
```
Stops the running Tomcat server cleanly.

**Sample output:**
```
$ ./shutdown.sh
Using CATALINA_BASE:   /opt/apache-tomcat-9.0.121
Using CATALINA_HOME:   /opt/apache-tomcat-9.0.121
...
$
```

**Real-time example:** This exact sequence — extract, `cd bin`, `./startup.sh` — is literally how a Java web application gets hosted on a server in a real project. On day 1 you'll do this manually to understand it; later, this same sequence gets wrapped inside a Jenkins deployment job or a shell script, so a new build gets deployed automatically without anyone SSH-ing in by hand. Also — accessing `IP:8080` from your browser only works if the EC2 **Security Group** allows inbound traffic on port 8080; "Tomcat started fine but I can't open it in the browser" is almost always a Security Group issue, not a Tomcat issue.

**More examples:**
- `curl -I <server-IP>:8080` — run **on the server itself** (over SSH), right after `./startup.sh`, to confirm Tomcat is actually responding, before even worrying about browser/network access.
- Checking Tomcat's own logs at `/opt/apache-tomcat-9.0.121/logs/catalina.out` if `startup.sh` says "started" but the browser still doesn't load — the real error, if any, shows up there.
- Wrapping `startup.sh` inside a `systemd` service so Tomcat restarts automatically if the server reboots, instead of depending on someone remembering to start it manually.

---

## 2. What is a process? — `ps`, `ps -ef`, `kill -9`

The moment you ran `./startup.sh`, Linux started a **process** — a running instance of that Tomcat program, sitting in memory, doing work, with its own unique **Process ID (PID)**. Every single running program on Linux, from `bash` itself to Tomcat to Jenkins, is a process with a PID.

```
ps
```
Shows the processes running in **your current terminal session** only — a short, limited list.

**Sample output:**
```
$ ps
  PID TTY          TIME CMD
 1234 pts/0    00:00:00 bash
 5678 pts/0    00:00:00 ps
```

```
ps -ef
```
Shows **every** process running on the entire system, from every user — not just your session. `-e` means "every process," `-f` means "full format" (shows user, PID, parent PID, start time, and the full command).

**Sample output:**
```
$ ps -ef | head -5
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 09:00 ?        00:00:02 /sbin/init
root         512       1  0 09:00 ?        00:00:00 /usr/lib/systemd/systemd-journald
ec2-user    2001       1  2 10:15 ?        00:00:12 /usr/lib/jvm/java/bin/java -Dcatalina.base=/opt/apache-tomcat-9.0.121 org.apache.catalina.startup.Bootstrap start
```

```
ps -ef | grep tomcat
```
Since `ps -ef` alone shows far too many lines to scan by eye, piping it into `grep` filters down to just the process(es) you actually care about.

**Sample output:**
```
$ ps -ef | grep tomcat
ec2-user   2001      1  0 10:15 ?        00:00:12 /usr/lib/jvm/java/bin/java ... org.apache.catalina.startup.Bootstrap start
ec2-user   2050   1998  0 10:20 ?        00:00:00 grep --color=auto tomcat
```
Notice **two** lines show up, not one — `grep` always matches its own command line too, since it literally contains the word "tomcat". This confuses every beginner once; after that, you just learn to ignore the `grep --color=auto tomcat` line.

```
kill -9 pid
```
**Forcefully terminates** a process immediately, using its PID (found via `ps -ef`). `-9` sends the `SIGKILL` signal — an unconditional kill, the process gets no chance to clean up or save anything before dying.

**Sample output:**
```
$ kill -9 2001
$ ps -ef | grep tomcat
ec2-user   2070   1998  0 10:25 ?        00:00:00 grep --color=auto tomcat
```
The real Tomcat process line is gone now — only the harmless `grep` self-match remains.

**Real-time example:** `ps -ef | grep <app>` → note the PID → `kill -9 <pid>` is the standard emergency move every DevOps/support engineer reaches for when an application has hung and `./shutdown.sh` (or the equivalent stop command) simply isn't working. It's a last resort though — always try a graceful stop first (`kill -15 pid`, or the app's own stop script), since `-9` doesn't let the application save state or close connections cleanly, and can occasionally leave things in a messy state.

**More examples:**
- `ps -ef | grep java` — a broader search to spot any Java-based process (Tomcat, or Jenkins itself, which also runs on Java) that might be consuming too much CPU/memory.
- `kill -15 pid` — the polite version, giving the process a chance to shut down gracefully; escalate to `kill -9` only if `-15` doesn't work after a few seconds.
- Running `ps -ef | grep <pid>` again right after a `kill`, to confirm the process is actually gone before assuming it's safe to proceed with a redeploy.

---

## 3. `grep` — searching for text inside files

```
grep -i "madhu" linuxfile
```
`grep` searches for a pattern inside a file and prints every matching line. `-i` makes it **case-insensitive** — so it matches "madhu", "Madhu", and "MADHU" all the same way.

**Sample output:**
```
$ grep -i "madhu" linuxfile
My name is madhukiran
useradd madhu
```

```
grep -iR "madhu"
```
`-R` makes the search **recursive** — it searches inside every file in the current folder **and** all its subfolders, not just one specific file.

**Sample output:**
```
$ grep -iR "madhu" .
./linuxfile:My name is madhukiran
./notes/day1.txt:useradd madhu
```
Each result also shows you exactly which file the match came from, which matters once you're searching across many files at once.

**Real-time example:** `grep` is one of the single most-used commands in all of DevOps work. Searching a huge application log for every error: `grep ERROR app.log`. Searching an entire project's config files to find where a particular setting is defined: `grep -iR "database_url" /etc/myapp/`. Searching a whole codebase to find every place a variable or function is used before you rename it. There's barely a troubleshooting session that doesn't involve `grep` somewhere.

**More examples:**
- `grep ERROR app.log` — the classic first move when investigating an application issue, pulling out only the error lines from a huge log.
- `grep -c ERROR app.log` — `-c` counts the matching lines instead of printing them, so you get a quick "how many errors" number.
- `grep -v INFO app.log` — `-v` **inverts** the match, showing lines that do **not** contain "INFO" — useful to filter out noisy routine log lines and see only what's unusual.

---

## 4. Creating a file — three different ways

We've actually used all three already; today we saw them side by side as three deliberate options for the same goal.

```
touch file2
echo "docker k8s terraform jenkins " > file2
echo "aws linux git github " >> file2
```

**Sample output:**
```
$ touch file2
$ echo "docker k8s terraform jenkins " > file2
$ echo "aws linux git github " >> file2
$ cat file2
docker k8s terraform jenkins
aws linux git github
```

**Real-time example:** In practice, DevOps engineers pick whichever of the three fits the moment: `touch` when you just need an empty file to exist (a placeholder, or to "reserve" a filename). `echo >`/`>>` when writing content **from inside a script**, since scripts can't interact with an editor — for example, a Jenkins pipeline stage writing a version number into a `build-info.txt` file automatically. `vim` when you need to sit and type multi-line content interactively and review it as you go, like editing a real config file by hand.

**More examples:**
- `echo "$(date): Deployment completed" >> deploy.log` — appending a timestamped status line into a log file from inside a deployment script.
- `vim server.properties` — the natural choice when you need to carefully hand-edit a multi-line config file, not just drop in one line.
- `touch .gitkeep` — a common trick to force Git to track an otherwise-empty folder (Git normally ignores empty directories).

---

## 5. `diff` and `sdiff` — comparing two files

```
diff file1 file2
```
Shows the **differences** between two files, line by line — the same underlying idea as `git diff`, except this works on any two plain files, whether or not they're tracked by Git.

**Sample output:**
```
$ diff file1 file2
1c1
< docker jenkins
---
> docker k8s terraform jenkins
```
`1c1` means "line 1 changed" — the `<` line is from `file1`, the `>` line is from `file2`.

```
sdiff file1 file2
```
The **side-by-side** version of `diff` — shows both files next to each other in two columns, with differing lines marked, which many people find easier to read visually than `diff`'s inline format.

**Sample output:**
```
$ sdiff file1 file2
docker jenkins                    | docker k8s terraform jenkins
aws linux                           aws linux
```
The `|` in the middle marks a line that differs between the two files; identical lines line up cleanly with no marker.

**Real-time example:** Before overwriting a live config file during a deployment, a careful DevOps engineer runs `diff old_config.yaml new_config.yaml` first, to see **exactly** what's about to change. This catches an accidental typo or an unintended change before it goes live, instead of blindly copying a new file over a working one and hoping for the best.

**More examples:**
- `diff -u file1 file2` — the "unified" diff format, using `+`/`-` lines, the same style Git uses — often easier to read than plain `diff`.
- Comparing two versions of a `Jenkinsfile` after a teammate's edit, to quickly confirm exactly what changed before approving a pull request.
- `sdiff -s file1 file2` — `-s` hides identical lines and shows **only** the differing ones side by side, handy when two files are mostly the same with just a couple of real changes.

---

## 6. `top` and `top -Bn1` — watching system load

```
top
```
A **live, continuously refreshing** view of running processes and resource usage (CPU, memory). This is the very first command a DevOps engineer runs when someone says "the server feels slow" — it shows exactly what's eating CPU/RAM right now. Press `q` to exit.

**Sample output:**
```
$ top
top - 10:15:32 up 2:14,  1 user,  load average: 0.15, 0.10, 0.05
Tasks: 132 total,   1 running, 131 sleeping,   0 stopped,   0 zombie
%Cpu(s):  2.3 us,  1.1 sy,  0.0 ni, 96.4 id,  0.2 wa
MiB Mem :    957.0 total,    410.2 free,    210.5 used,    336.3 buff/cache

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
 2001 ec2-user  20   0  987600  78400  54200 S   1.3   8.0   0:12.44 java
    1 root      20   0  167000  11200   8900 S   0.0   1.1   0:01.02 systemd
```

```
top -Bn1
```
`-B` runs `top` in **batch mode** (no live, interactive screen — just plain text output), and `-n1` means "only run **1** iteration, then stop." Together, this turns `top` from a live dashboard into a single, script-friendly snapshot.

**Sample output:**
```
$ top -Bn1
top - 10:16:02 up 2:15,  1 user,  load average: 0.18, 0.11, 0.06
Tasks: 132 total,   1 running, 131 sleeping,   0 stopped,   0 zombie
%Cpu(s):  3.1 us,  1.2 sy,  0.0 ni, 95.5 id,  0.2 wa
MiB Mem :    957.0 total,    405.1 free,    215.0 used,    336.9 buff/cache
$
```
It prints once and drops you straight back to the prompt — no live refresh, and you don't need to press `q` to get out.

**Real-time example:** A monitoring or health-check script (or a step inside a Jenkins/cron job) can't interact with `top`'s live-refreshing screen the way a human can — so it uses `top -Bn1` to grab one clean text snapshot, parse the CPU/memory numbers out of it, and decide whether to raise an alert. This is exactly the mechanism behind a lot of "high CPU usage" alerts that page an on-call engineer.

**More examples:**
- Running plain `top` interactively first, to eyeball what's actually consuming resources, then switching to `top -Bn1` once you know what you're looking for and want to automate the check.
- `top -Bn1 | head -20` — capturing just the summary/top portion of a batch snapshot for quick logging, instead of the full process list.
- `top -Bn1 -o %CPU` — a batch snapshot sorted by CPU usage, so the single biggest resource-hogging process shows up first.

---

## 7. `find` — searching the filesystem for files and folders

```
find / -name <fname/dirname>
```
Searches starting from a given folder — here `/`, meaning the **entire filesystem** — for anything (file or folder) matching that exact name.

```
find / -name docker -type f
```
`-type f` restricts the results to **files only**.

```
find / -name docker -type d
```
`-type d` restricts the results to **directories only**.

**Sample output:**
```
$ find / -name docker
/opt/docker
/usr/bin/docker

$ find / -name docker -type f
/usr/bin/docker

$ find / -name docker -type d
/opt/docker
```

**Real-time example:** You've just deployed an application, and a teammate asks "where exactly did the config file land on this server?" Instead of guessing folder by folder, `find / -name app.properties` searches the whole filesystem and tells you exactly where it is. This is also how you'd locate a binary that a package manager installed somewhere, when you don't remember (or were never told) exactly which folder it went into.

**More examples:**
- `find /var/log -name "*.log"` — restricting the search to one specific folder (much faster than searching all of `/`), matching a wildcard pattern.
- `find / -name "*.war" -mtime -1` — finding files modified in the **last 1 day**, handy for quickly spotting the most recently deployed build artifact.
- `find /opt -name "*.tmp" -delete` — combining `find` with `-delete` to clean up matching junk files in a single command. ⚠️ Use carefully — like `rm -rf`, there's no confirmation prompt.

---

## 8. `sed` — find and replace text inside files

```
sed 's/madhu/kiran/' input.txt
```
`sed` (Stream EDitor) reads a file line by line and can **replace** one piece of text with another — like "Find & Replace," but from the command line, which makes it scriptable. `s` means "substitute." By default, this replaces only the **first** match of "madhu" on each line, and just prints the result to the screen — the original file is untouched.

```
sed 's/madhu/kiran/g' input.txt
```
`g` = **global** — replaces **every** occurrence of "madhu" on each line, not just the first.

```
sed 's/madhu/kiran/2' input.txt
```
Replaces only the **2nd** occurrence of "madhu" on each line — the 1st and 3rd (if any) are left untouched.

```
sed 's/userstanga/madhustanga/' jenkins > jenkins2file
```
Redirects the substituted output into a **brand-new file** (`jenkins2file`) instead of printing it to the screen — the original `jenkins` file stays completely untouched.

```
sed -i 's/yum/apt/g' jenkins
```
`-i` means **in-place** — this actually **modifies the original file directly**, instead of just printing the result. There's no output shown on screen by default, but the real file is changed permanently.

⚠️ **Important:** Unlike the earlier examples (which only print to screen), `sed -i` changes the real file immediately, with no undo — always test your `sed` command **without** `-i` first to confirm it does exactly what you expect.

**Sample output:**
```
$ cat jenkins
yum install jenkins
yum install java

$ sed -i 's/yum/apt/g' jenkins
$ cat jenkins
apt install jenkins
apt install java
```

**Real-time example:** Say you're migrating a batch of shell scripts from a RHEL/Amazon Linux server (which uses `yum`) to an Ubuntu server (which uses `apt`). Instead of manually opening every script and hand-editing `yum` to `apt`, `sed -i 's/yum/apt/g' *.sh` does it across every matching script in seconds. This exact pattern — bulk find-and-replace across many files — is used constantly for things like updating a hostname, a version number, or an environment name across dozens of config files in one shot, instead of opening each one by hand.

**More examples:**
- `sed -n '5,10p' file.txt` — printing **only** lines 5 through 10 of a file, without changing anything.
- `sed 's/PROD/STAGING/g' config.yaml > config-staging.yaml` — safely generating a **new**, modified copy for a different environment, without touching the original production config at all.
- Always run a `sed` command **without** `-i` first (let it just print to the screen) to visually confirm it does exactly what you expect, before adding `-i` to actually modify the real file.

---

## Quick Recap Table

| Command | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `./startup.sh` / `./shutdown.sh` | Start / stop Tomcat | Hosting a Java web app; wrapped inside deployment scripts in real projects |
| `ps` | List processes in current session | Quick check of what's running in this terminal |
| `ps -ef` | List every process on the system | Full system-wide process inspection |
| `ps -ef \| grep <app>` | Find a specific running process | Locating an app's PID before stopping/restarting it |
| `kill -9 pid` | Force-kill a process immediately | Last-resort move when an app is hung and won't stop cleanly |
| `grep -i` / `grep -iR` | Search text in one file / recursively in all files | Finding every occurrence of a config key or error across many files |
| `diff` / `sdiff` | Compare two files (inline / side-by-side) | Reviewing exactly what changed before overwriting a config in production |
| `top` / `top -Bn1` | Live / one-shot snapshot of CPU & memory | First command when "server feels slow"; `-Bn1` used inside monitoring scripts |
| `find / -name <x>` | Search the filesystem for a file/folder | Locating where a deployed config file or installed binary actually landed |
| `sed 's/x/y/'` / `sed -i` | Find & replace text (preview / modify in place) | Bulk-updating `yum` → `apt`, or a hostname, across many files in one command |

That's today's session, friends — processes, `grep`, `diff`, `top`, `find`, and `sed` together form the core "troubleshooting toolkit" you'll reach for almost every single day once you're on a real project. Practice getting Tomcat up and down a few times, and get comfortable finding/killing its process, before moving to the next topic.
