# Batch 18 — Linux Running Notes: 24 August 2026

**Topic: Disk usage (`df`, `du`) · File Permissions (`chmod`) · Groups · Ownership (`chown`) · Networking (`ping`, `traceroute`, `telnet`, `netstat`)**

---

## 1. Disk Usage — `df` and `du`

**What is disk usage?**

Checking how much storage is:
- Used
- Free
- Available

As a DevOps engineer, you check disk usage all the time — a very common reason an application "just stops working" is simply that the server ran out of disk space.

### `df` — Disk Free

Checks disk space at the **filesystem** level.

```
df
```
Shows Filesystem, Total size, Used space, Available space, Use%, Mount point.

```
df -h
```
`-h` = human-readable (GB/MB instead of raw blocks). This is the one you'll actually use.

**Sample output:**
```
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       20G   15G    5G  75% /
```

**Real-time use case:** Application is not working → first check `df -h` → if `Use%` shows `100%`, the disk is full, that's your answer. Then you go find *what* filled it up, using `du`.

### `du` — Disk Usage

Checks how much space a specific **file or directory** is consuming.

```
du -sh /var/log
```
`-s` = summary (one total, not every subfolder). `-h` = human-readable.

**Sample output:**
```
$ du -sh /var/log
4.5G    /var/log
```

```
du -sh /var/*
```
Checks the size of every directory under `/var` in one shot — the fastest way to spot which folder is the culprit.

### `df` vs `du`

| Command | Answers |
|---|---|
| `df` | "How much disk space is available?" (whole filesystem) |
| `du` | "Which files/folders are using the space?" (specific path) |

**Easy memory trick:** `df` = **D**isk/**F**ilesystem space. `du` = **D**irectory/File **u**sage.

---

## 2. File Permissions — `chmod`

Linux controls who can **read (r)**, **write (w)**, and **execute (x)** a file or directory, for three categories of user:

| Who | Symbol | Meaning |
|---|---|---|
| User | `u` | the file's owner |
| Group | `g` | the group tied to the file |
| Others | `o` | everyone else |

**Example:**
```
$ ls -l app.sh
-rwxr-xr--
```
- `-` → regular file
- `rwx` → owner
- `r-x` → group
- `r--` → others

### Numeric permissions

`r = 4`, `w = 2`, `x = 1` — add them up per category.

| Number | Meaning |
|---|---|
| `7` | rwx (4+2+1) |
| `6` | rw- (4+2) |
| `5` | r-x (4+1) |
| `4` | r-- |
| `0` | --- (no permission) |

### Common `chmod` values

| Value | Owner | Group | Others | Typical use |
|---|---|---|---|---|
| `755` | rwx | r-x | r-x | scripts, executables |
| `644` | rw- | r-- | r-- | normal files, configs |
| `700` | rwx | --- | --- | private folder, only owner |
| `600` | rw- | --- | --- | private file (e.g. SSH key) |

### `chmod` command

```
chmod 755 script.sh
```

**Sample output:**
```
$ ls -l script.sh
-rw-r--r--. 1 ec2-user ec2-user 128 Aug 24 11:05 script.sh

$ chmod 755 script.sh
$ ls -l script.sh
-rwxr-xr-x. 1 ec2-user ec2-user 128 Aug 24 11:05 script.sh
```

```
chmod +x deploy.sh
./deploy.sh
```
`+x` just adds execute permission for everyone who already had some access — the quickest way to make a script runnable.

**Real-time use case:** Jenkins downloads `deploy.sh` from your repo, tries to run it, and fails with `Permission denied`. Fix: `chmod +x deploy.sh`. One of the most common pipeline errors you'll hit.

**Easy memory trick:** `chmod` → "Who can **do** what?"

---

## 3. Groups

A Linux **group** is a collection of users — useful when multiple people need the same access to the same files/directories, without setting permissions one user at a time.

**Real-time use case:** A company has `developer1`, `developer2`, `developer3`, all needing access to the same project folder.

```
groupadd devops
usermod -aG devops developer1
usermod -aG devops developer2
usermod -aG devops developer3
```
- `groupadd devops` — creates a new group called `devops`.
- `usermod -aG devops <user>` — adds that user into the `devops` group. `-a` = append (don't remove their other groups), `-G` = the group name.

```
groups madhu
```
Shows every group `madhu` currently belongs to.

**Sample output:**
```
$ groupadd devops
$ usermod -aG devops madhu
$ groups madhu
madhu : madhu devops
```

---

## 4. `chown` — Change Ownership

`chmod` changes **permissions**. `chown` changes **who owns** the file — the user-owner and/or the group-owner.

### Check current ownership

```
ls -l file.txt
```
**Sample output:**
```
-rw-r--r-- 1 root devops file.txt
```
Owner = `root`, Group = `devops`.

### Change owner

```
chown madhu file.txt
```
Owner becomes `madhu`; group is untouched.

### Change owner and group together

```
chown madhu:devops file.txt
```

### Recursive ownership

```
chown -R madhu:devops /opt/app
```
`-R` applies the change to the directory **and everything inside it** — the usual way to fix ownership right after deploying a whole app folder.

**Sample output:**
```
$ chown -R madhu:devops /opt/app
$ ls -l /opt/app
-rw-r--r-- 1 madhu devops 4096 Aug 24 12:00 config.yaml
```

### `chmod` vs `chown`

| Command | Changes | Example |
|---|---|---|
| `chmod` | Permissions | `chmod 755 app.sh` |
| `chown` | Ownership | `chown ec2-user:devops app.sh` |

**Easy memory trick:** `chmod` → "Who can **do** what?" `chown` → "Who **owns** it?"

---

## 5. Networking Commands

DevOps engineers regularly troubleshoot connectivity, ports, and network routes. Four go-to commands:

### `ping` — is the host reachable?

```
ping google.com
ping -c 4 8.8.8.8
```
`-c 4` sends just 4 packets and stops (otherwise it runs forever until `Ctrl+C`).

**Sample output:**
```
$ ping -c 4 8.8.8.8
64 bytes from 8.8.8.8: icmp_seq=1 ttl=115 time=3.21 ms
...
4 packets transmitted, 4 received, 0% packet loss
```

⚠️ **Important:** Ping failure does **not** always mean the server is down — ICMP can simply be blocked by a firewall, Security Group, or Network ACL. Ping is only one check, not final proof.

### `traceroute` — what path does traffic take?

```
traceroute google.com
```
Shows every network hop between your machine and the destination — Your Machine → Router → ISP → Internet → Destination.

**Why use it:** network latency, routing problems, or "reachable from one place but not another" issues.

**Note:** may need to install it first — `sudo yum install traceroute` or `sudo apt install traceroute`.

### `telnet` — is a specific TCP port open?

```
telnet 10.0.1.20 8080
```
If it connects, port 8080 is reachable on that host.

**Real-time use case:** App server is at `10.0.1.20`, app runs on port `8080`. `telnet 10.0.1.20 8080` tells you instantly whether the port-level networking is fine — before even opening a browser.

⚠️ Telnet itself is an old, insecure remote-login protocol — for actual remote login use `ssh`. For just testing a port, `nc -zv 10.0.1.20 8080` (netcat) is the more modern choice.

### `netstat` — what's listening on this machine?

```
netstat -tulnp
```
| Flag | Meaning |
|---|---|
| `-t` | TCP |
| `-u` | UDP |
| `-l` | Listening |
| `-n` | numeric addresses/ports |
| `-p` | show the process |

**Sample output:**
```
$ netstat -tulnp
Proto Local Address       State    PID/Program name
tcp   0.0.0.0:8080        LISTEN   2001/java
```
Confirms your app really is listening on 8080, on the server itself.

**Modern alternative:** `ss -tulnp` — preferred on most current Linux systems, `netstat` is considered a bit legacy now.

**Easy memory trick:**
- `ping` → "Can I reach the host?"
- `traceroute` → "What path does traffic take?"
- `telnet` / `nc` → "Can I reach this TCP port?"
- `netstat` / `ss` → "What ports are listening?"

---

## 6. Real-Time DevOps Troubleshooting — Putting It All Together

**Scenario:** Users can't access your application. Walk through it step by step:

| Step | Command | Checking |
|---|---|---|
| 1 | `df -h` | Is the server's disk full? |
| 2 | `du -sh /var/*` | Which folder is eating the space? |
| 3 | `ps -ef \| grep java` | Is the application process even running? |
| 4 | `ss -tulnp` | Is the app listening on its port? |
| 5 | `nc -zv localhost 8080` | Can I reach the port locally? |
| 6 | `ping server-ip` | Is the server reachable over the network? |
| 7 | `traceroute server-ip` | Where exactly is the network path breaking? |
| 8 | `ls -l /opt/app` | Are permissions/ownership correct? |
| 9 | `chown -R appuser:appgroup /opt/app` | Fix ownership if wrong |
| 10 | `chmod -R 755 /opt/app` | Fix permissions if wrong |

This is the mental checklist real DevOps engineers run through — disk → process → port → network → permissions — when something "just isn't working" and nobody knows why yet.

---

## Quick Command Summary

| Category | Command | Meaning |
|---|---|---|
| Disk | `df -h` | Filesystem disk space |
| Disk | `du -sh /path` | Size of one folder/file |
| Permissions | `ls -l` | Check permissions & ownership |
| Permissions | `chmod 755 file` | Change permissions |
| Permissions | `chmod +x script.sh` | Make executable |
| Ownership | `chown user file` | Change owner |
| Ownership | `chown user:group file` | Change owner + group |
| Ownership | `chown -R user:group dir` | Recursive ownership |
| Groups | `groupadd devops` | Create a group |
| Groups | `groups username` | Show a user's groups |
| Groups | `usermod -aG devops username` | Add user to group |
| Network | `ping host` | Test basic connectivity |
| Network | `traceroute host` | Check network path |
| Network | `telnet host port` | Test a TCP port |
| Network | `netstat -tulnp` | Show listening ports |
| Network | `ss -tulnp` | Modern alternative to netstat |
| Network | `nc -zv host port` | Test TCP connectivity |

---

## Interview Questions

1. What is the difference between `df` and `du`?
2. What does `chmod 755` mean?
3. What does `chmod 644` mean?
4. What is the difference between `chmod` and `chown`?
5. What are User, Group, and Others permissions?
6. What do `r`, `w`, and `x` mean?
7. What is the purpose of Linux groups?
8. What is the difference between `chown` and `chgrp`?
9. What is `ping` used for?
10. Does `ping` always prove a server is reachable?
11. What is `traceroute` used for?
12. How do you check whether port 8080 is listening?
13. What is the difference between `telnet` and `SSH`?
14. What is `netstat`?
15. What is the modern alternative to `netstat`?
16. How would you troubleshoot a server showing 100% disk usage?
