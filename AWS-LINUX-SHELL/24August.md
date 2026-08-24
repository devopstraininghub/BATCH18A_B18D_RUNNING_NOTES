# Batch 18 — Linux Running Notes: 24 August 2026

**Topic: Disk usage (`df`, `du`) · File Permissions (`chmod`) · Groups · Ownership (`chown`) · Networking (`ping`, `traceroute`, `telnet`, `netstat`)**

Friends, today's session is all about the questions you'll get asked constantly once you're on a real project: "Is the disk full?", "Why can't I run this script?", "Who's allowed to touch this file?", and "Is the server even reachable?" We cover disk space (`df`/`du`), permissions and ownership (`chmod`, groups, `chown`), and the basic networking commands (`ping`, `traceroute`, `telnet`, `netstat`) that answer that last question.

---

## 1. Disk usage — `df` and `du`

`df` reports space at the level of the whole **filesystem**; `du` reports space used by one specific **file or folder**. You'll almost always use them together.

```
df
df -h
df -m
```
`df` alone shows Filesystem, Total size, Used, Available, Use%, and Mount point — but in raw blocks, which is hard to read. `-h` gives **human-readable** sizes (GB/MB); `-m` forces everything into megabytes.

**Sample output:**
```
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       20G   15G    5G  75% /
tmpfs           487M     0  487M   0% /dev/shm
```

**A point that trips up people coming from Windows:** Windows gives every disk its own drive letter — `C:`, `D:`, `E:` — each a separate little world. **Linux has no drive letters at all.** There's just one single tree starting at `/` (root), and every disk/partition gets **mounted** onto some folder inside that same tree — so a folder like `/opt` could secretly be its own separate disk, and you'd never know just by looking at it. `df -h` is what tells you what's really mounted where.

**Real-time example:** An application "just stops working" — nine times out of ten, `df -h` is the very first command you run. If `Use%` shows `100%`, the disk is full, full stop — the app can't write logs, can't write temp files, sometimes can't even start. Once you know *that* it's full, you switch to `du` to find out *what* filled it.

```
du -h <folder>
du -sh <folder>
```
`du -h` lists the size of every subfolder inside — can be a wall of output for a big folder. `-s` gives just the **summary**, one total number for that folder.

**Sample output:**
```
$ du -sh /var/log
4.5G    /var/log

$ du -sh /var/*
120M    /var/cache
4.5G    /var/log
8.0K    /var/mail
```

**More examples:**
- `du -sh *` run inside a folder — quickly spot which of its immediate subfolders is the biggest space hog.
- `du -sh --max-depth=1 /opt` — one level deep only, for a quick overview without drowning in nested output.

**Easy memory trick:** `df` → "How much disk space is **available**?" `du` → "Which files/folders are **using** the space?"

---

## 2. File permissions — `chmod`

Every file has an **owner**, a **group**, and permissions deciding who can read, write, or run it.

| Who | Symbol | Meaning |
|---|---|---|
| User | `u` | the file's owner |
| Group | `g` | the group the file belongs to |
| Others | `o` | everyone else |
| All | `a` | user + group + others |

| Permission | Symbol | Meaning |
|---|---|---|
| Read | `r` | view a file / list a folder |
| Write | `w` | modify a file / create-delete inside a folder |
| Execute | `x` | run a file as a program / enter a folder |

A line like `rwxr-xr--` (seen via `ls -l` or `ll`) is really three groups of three: `rwx` (owner) `r-x` (group) `r--` (others).

**Numeric (octal) notation** — add up `r=4`, `w=2`, `x=1` per category, giving one digit each for owner/group/others:

| Number | Meaning | Made from |
|---|---|---|
| `7` | rwx | 4+2+1 |
| `6` | rw- | 4+2 |
| `5` | r-x | 4+1 |
| `4` | r-- | 4 |
| `0` | --- | no permission |

```
chmod 755 deploy.sh
chmod -R 755 webapps/
```
`chmod 755` means owner gets `7` (full rwx), group and others get `5` (r-x) each — the standard permission set for a script. `-R` = recursive, applies to every file/subfolder inside a directory too.

**Sample output:**
```
$ ll deploy.sh
-rw-r--r--. 1 ec2-user ec2-user 128 Aug 24 11:05 deploy.sh

$ chmod 755 deploy.sh
$ ll deploy.sh
-rwxr-xr-x. 1 ec2-user ec2-user 128 Aug 24 11:05 deploy.sh

$ ./deploy.sh
Deploying application...
```
Before `chmod`, the `x` was missing — even the owner couldn't run `./deploy.sh`, it would fail with "Permission denied." That's exactly what "make a script executable" means.

**Real-time example:** Three situations you'll hit constantly:
- **Make a script executable** — `chmod +x deploy.sh`. Jenkins pulls a script from your repo and tries to run it; without the execute bit, it fails with `Permission denied` — one of the most common pipeline errors there is.
- **Secure a private SSH key** — `chmod 400 mykey.pem`. A `.pem` key *must* be readable only by its owner; if it's too open, SSH itself refuses it outright with an "UNPROTECTED PRIVATE KEY FILE" error.
- **Restrict a folder to the owner only** — `chmod 700 /home/madhu/secrets` — `7` for owner, `0` for everyone else, for anything sensitive that only one account should ever touch.

**Easy memory trick:** `chmod` → "Who can **do** what?"

---

## 3. Groups

A group is a **collection of users**, so you can hand out the same access to several people at once instead of one by one. Every file is owned by exactly one user **and** exactly one group.

```
cat /etc/group
```
Lists every group on the system and its members.

```
groupadd devops
usermod -aG devops madhu
usermod -aG devops kiran
```
`groupadd devops` creates the group. `usermod -aG devops madhu` adds `madhu` into it — `-a` (append) matters: without it, you'd wipe out every other group `madhu` already belongs to.

**Sample output:**
```
$ groupadd devops
$ usermod -aG devops madhu
$ usermod -aG devops kiran
$ cat /etc/group | grep devops
devops:x:1001:madhu,kiran
```

**Real-time example — a shared team directory**, the classic reason groups exist. `madhu` and `kiran` are on the same team and need to share one project folder, nobody else should get in:
```
groupadd devops
usermod -aG devops madhu
usermod -aG devops kiran
mkdir /project
chown root:devops /project
chmod 770 /project
```
`chown root:devops /project` sets the folder's group-owner to `devops`; `chmod 770` gives owner and group full `rwx` while others get nothing. Result: both teammates work freely inside `/project`, nobody outside the group can even look in. Group + `chown` + `chmod` together is exactly how shared project/deployment folders get set up on real servers.

**More examples:**
- `groups madhu` — quick check of every group a user belongs to.
- `usermod -aG docker jenkins` — adding the `jenkins` service account to the `docker` group so build jobs can run Docker commands without full root access.

---

## 4. `chown` — changing ownership

`chmod` controls **what** owner/group/others can do; `chown` (change owner) controls **who** the owner and group actually are.

```
chown newuser filename
chown :newgroup filename
chown newuser:newgroup filename
chown -R newuser:newgroup dir/
```
- `chown newuser file` — changes only the owner.
- `chown :newgroup file` — the leading `:` means only the group changes.
- `chown newuser:newgroup file` — changes both together.
- `-R` — recursive, applies to a whole directory tree, the usual move right after deploying an app folder.

**Sample output:**
```
$ ll deploy.sh
-rwxr-xr-x. 1 ec2-user ec2-user 128 Aug 24 11:05 deploy.sh

$ sudo chown madhu:devops deploy.sh
$ ll deploy.sh
-rwxr-xr-x. 1 madhu devops 128 Aug 24 11:05 deploy.sh
```
Only the owner/group columns changed — permission bits are untouched, since that's `chmod`'s job, not `chown`'s. Notice the `sudo` — changing ownership to someone else needs root/sudo access.

**Real-time example:** A deployment script (running as `root` or a `jenkins` account) drops files on the server, but the app itself must run as an unprivileged user like `tomcat` for security. `chown -R tomcat:tomcat /opt/apache-tomcat-9.0.121/webapps` hands ownership over to the account that should actually run it — `chmod`/`chown` are almost always used as a pair right after a deployment.

**Easy memory trick:** `chown` → "Who **owns** it?" (vs `chmod` → "Who can **do** what?")

---

## 5. Networking commands

Before debugging an application, you first need to know: is the server reachable, and is the port open?

```
ping google.com
ping -c 4 example.com
```
Sends test packets to check basic reachability. Plain `ping` runs forever until `Ctrl+C`; `-c 4` sends exactly 4 and stops — friendlier for a quick check or a script.

**Sample output:**
```
$ ping -c 4 google.com
64 bytes from 142.250.193.78: icmp_seq=1 ttl=115 time=3.21 ms
64 bytes from 142.250.193.78: icmp_seq=2 ttl=115 time=3.05 ms
64 bytes from 142.250.193.78: icmp_seq=3 ttl=115 time=3.44 ms
64 bytes from 142.250.193.78: icmp_seq=4 ttl=115 time=3.11 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss
```

⚠️ **Important:** Ping failure does **not** always mean the server is down — ICMP is very commonly blocked by a firewall, a Security Group, or a Network ACL, especially on AWS. Ping is one check, not final proof.

```
traceroute google.com
```
Shows every network hop between you and the destination, with the time taken at each one — useful for narrowing down *where* a connection is actually breaking when `ping` fails: right at your own network, or somewhere further out.

**Sample output:**
```
$ traceroute google.com
 1  192.168.1.1        1.12 ms
 2  10.10.0.1           4.20 ms
 3  * * *
 4  142.250.193.78      3.40 ms
```
A `* * *` just means that hop didn't reply — not always a real problem.

```
telnet www.google.com 443
telnet 100.26.144.255 8080
```
Used here not for its old remote-login purpose, but as a fast way to test whether one specific **port** is open on a remote host — `telnet <host> <port>`.

**Sample output:**
```
$ telnet 100.26.144.255 8080
Trying 100.26.144.255...
Connected to 100.26.144.255.
Escape character is '^]'.
```
"Connected" = the port is open. Hangs and times out, or "Connection refused" = the port is blocked or nothing's listening on it.

**Real-time example:** Right after starting Tomcat, `telnet <server-IP> 8080` is the fastest way to confirm whether the Security Group is actually letting port 8080 through — before you even bother opening a browser.

```
netstat -an
```
Shows active connections and listening ports on the **local** machine. `-a` = all, `-n` = show numeric addresses/ports instead of resolving hostnames.

**Sample output:**
```
$ netstat -an | grep 8080
tcp   0   0 0.0.0.0:8080   0.0.0.0:*   LISTEN
```
`LISTEN` on `0.0.0.0:8080` confirms Tomcat is really up and waiting for connections, on the server itself — check this before blaming the network for a connection failure.

**Easy memory trick:**
- `ping` → "Can I reach the host?"
- `traceroute` → "What path does traffic take?"
- `telnet` → "Can I reach this specific port?"
- `netstat` → "What's actually listening on this machine?"

---

## Real-time troubleshooting — putting it all together

**Scenario:** users can't access your application. Here's the order a real DevOps engineer would work through it:

| Step | Command | Checking |
|---|---|---|
| 1 | `df -h` | Is the disk full? |
| 2 | `du -sh /var/*` | Which folder is eating the space? |
| 3 | `ps -ef \| grep java` | Is the app process even running? |
| 4 | `netstat -an \| grep 8080` | Is the app listening on its port? |
| 5 | `ping server-ip` | Is the server reachable over the network? |
| 6 | `traceroute server-ip` | Where exactly is the network path breaking? |
| 7 | `telnet server-ip 8080` | Is the port reachable from outside? |
| 8 | `ll /opt/app` | Are permissions/ownership correct? |
| 9 | `chown -R appuser:appgroup /opt/app` | Fix ownership if wrong |
| 10 | `chmod -R 755 /opt/app` | Fix permissions if wrong |

Disk → process → port → network → permissions — that's the mental checklist, and it's exactly what today's commands were for.

---

## Quick Recap Table

| Command | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `df -h` | Disk space used/free per mounted filesystem | First check when a server is running low on disk space |
| `du -sh <folder>` | Total size of one specific folder/file | Hunting down which folder is eating up disk space |
| `chmod 755` / `chmod +x` | Change read/write/execute permissions | Making a deployment script executable before running it |
| `chmod 400 key.pem` | Restrict a file to owner-read-only | Securing an SSH private key so SSH will accept it |
| `groupadd` / `usermod -aG` | Create a group / add a user to it | Putting teammates in one group to share a project folder |
| `chown user:group file` | Change a file's owner and/or group | Handing deployed app files to the correct service account |
| `ping -c 4 <host>` | Test basic network reachability | First troubleshooting step — is the server reachable? |
| `traceroute <host>` | Show the network path/hops to a host | Narrowing down exactly where a connection is breaking |
| `telnet <host> <port>` | Test whether a specific port is open | Confirming a Security Group is really letting a port through |
| `netstat -an` | List listening ports & active connections | Confirming an app is really listening on its port |

---

## Interview questions

1. What's the difference between `df` and `du`?
2. What does `chmod 755` mean, digit by digit?
3. What's the difference between `chmod` and `chown`?
4. What are User, Group, and Others permissions?
5. Why does `usermod -aG` need the `-a`, and what happens if you forget it?
6. Why would you `chmod 400` an SSH private key?
7. Does a `ping` failure always mean the server is down? Why not?
8. What's the difference between `traceroute` and `ping`?
9. Why use `telnet` to test a port instead of just opening it in a browser?
10. How do you check whether a specific application is listening on a specific port on a server?
11. Walk through how you'd troubleshoot a server where users report the app is "not working."

That's today's session, friends — practice `df`/`du`, `chmod`/`chown`/groups, and the networking commands on your own EC2 instance until running through that troubleshooting checklist feels automatic.
