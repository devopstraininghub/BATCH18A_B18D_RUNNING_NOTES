# Batch 18 — Linux Running Notes: 24 August 2026

**Topic:** Disk Usage | File Permissions | Groups | Ownership | Networking

---

## 1. Disk Usage — `df` and `du`

**What is disk usage?**

Used to check:
- Total disk space
- Used disk space
- Available disk space
- Which files/folders are consuming space

### `df` command

`df` = Disk Free — checks disk/filesystem-level usage.

- `df` — shows disk usage in blocks
- `df -h` — human-readable format
- `df -m` — shows values in MB

**Example:**
```
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       20G   15G    5G  75% /
tmpfs           487M     0  487M   0% /dev/shm
```

**What `df` shows:**

| Column | Meaning |
|---|---|
| Filesystem | disk/filesystem |
| Size | total size |
| Used | used space |
| Avail | available space |
| Use% | percentage used |
| Mounted on | location where filesystem is mounted |

**Real-time use case:** Application suddenly stops working → first check `df -h`. If `Use% = 100%`, disk is full. Application may not be able to:
- Write logs
- Create temporary files
- Write application data
- Start properly

### Linux mounting concept

Windows: `C:`, `D:`, `E:` — separate drive letters.

Linux does **not** use drive letters. Linux has one filesystem tree: `/`. Different disks/partitions can be **mounted** to directories.

Example: `/opt`, `/var`, `/home` could each potentially be separate filesystems. Use `df -h` to see what filesystem is mounted where.

### `du` command

`du` = Disk Usage — finds how much space a file or directory is consuming.

- `du -h /opt` — human-readable directory usage
- `du -sh /var/log` — total size only (`-s` = summary, `-h` = human-readable)
- `du -sh *` — size of each item in the current directory
- `du -sh /var/*` — quickly identify large directories

**Example:**
```
$ du -sh /var/log
4.5G    /var/log

$ du -sh /var/*
120M    /var/cache
4.5G    /var/log
8.0K    /var/mail
```

### `df` vs `du`

| Command | Shows | Question it answers |
|---|---|---|
| `df` | filesystem/disk space | "How much disk space is available?" |
| `du` | file/directory usage | "What is consuming the disk?" |

**Easy memory trick:** `df` → Disk Free. `du` → Disk Usage.

---

## 2. File Permissions — `chmod`

Every Linux file has an **owner**, a **group**, and **permissions**. Permissions control who can read, write, execute.

**Permission types:** `r` = read, `w` = write, `x` = execute

**Who gets permissions:** `u` = user/owner, `g` = group, `o` = others, `a` = all

**Meaning of r, w, x:**

| | For a file | For a directory |
|---|---|---|
| `r` | read/view the file | list directory contents |
| `w` | modify the file | create/delete files inside |
| `x` | execute the file | enter/access the directory |

**Example:**
```
$ ls -l deploy.sh
-rwxr-xr--
```
Break into 3 groups: `rwx` (user) `r-x` (group) `r--` (others).

### Numeric permissions

`r = 4`, `w = 2`, `x = 1`

| Value | Meaning |
|---|---|
| `7` = rwx | 4+2+1 |
| `6` = rw- | 4+2 |
| `5` = r-x | 4+1 |
| `4` = r-- | 4 |
| `0` = --- | no permission |

**Common permissions:**

| Value | Owner | Group | Others |
|---|---|---|---|
| `755` | rwx | r-x | r-x |
| `644` | rw- | r-- | r-- |
| `700` | rwx | --- | --- |
| `400` | r-- | --- | --- |

### `chmod` command

`chmod` = Change Mode — used to change file permissions.

```
chmod 755 deploy.sh
chmod -R 755 webapps/
```
`-R` = recursive — applies permissions to files/subdirectories inside.

**Make script executable:**
```
chmod +x deploy.sh
./deploy.sh
```

**Before `chmod`:**
```
-rw-r--r--  deploy.sh
```
No execute permission.

**After:**
```
$ chmod 755 deploy.sh
-rwxr-xr-x  deploy.sh
```
Now `./deploy.sh` can execute.

**Real-time `chmod` examples:**
1. **Jenkins deployment script** — `chmod +x deploy.sh` — allows Jenkins to execute the script.
2. **SSH private key** — `chmod 400 mykey.pem` — restricts the key so only the owner can read it.
3. **Private directory** — `chmod 700 /home/madhu/secrets` — only the owner gets access.

**Easy memory trick:** `chmod` → "Who can DO what?"

---

## 3. Groups

A group is a collection of users. Groups let multiple users receive the same access permissions.

- `cat /etc/group` — check groups
- `groupadd devops` — create group
- `usermod -aG devops madhu` / `usermod -aG devops kiran` — add user to group
- `groups madhu` — check user's groups

`-a` = append, `-G` = add user to supplementary group.

⚠️ **Important:** Do NOT forget `-a`. Without it, existing supplementary group memberships can be replaced.

**Real-time group example:** `madhu` and `kiran` are DevOps team members, both need access to `/project`.
```
groupadd devops
usermod -aG devops madhu
usermod -aG devops kiran
mkdir /project
chown root:devops /project
chmod 770 /project
```
Result: Owner → full access, Group → full access, Others → no access.

---

## 4. `chown` — Ownership

`chown` = Change Owner — used to change file owner, file group, or both.

**Check ownership:**
```
$ ls -l deploy.sh
-rwxr-xr-x 1 ec2-user ec2-user deploy.sh
```
Owner = `ec2-user`, Group = `ec2-user`.

- `chown madhu deploy.sh` — owner becomes `madhu`
- `chown :devops deploy.sh` — group becomes `devops`
- `chown madhu:devops deploy.sh` — owner `madhu`, group `devops`
- `chown -R madhu:devops /opt/app` — recursive, applies to directory + everything inside

### `chmod` vs `chown`

| Command | Changes | Example |
|---|---|---|
| `chmod` | permissions | `chmod 755 deploy.sh` |
| `chown` | ownership | `chown madhu:devops deploy.sh` |

**Easy memory trick:** `chmod` → Who can DO what? `chown` → Who OWNS it?

**Real-time `chown` example:** Deployment creates `/opt/app`, but the application must run as `tomcat`.
```
chown -R tomcat:tomcat /opt/app
```
Now the Tomcat user owns the application files.

---

## 5. Networking Commands

Common networking troubleshooting: is the server reachable? is the network path working? is the port open? is the application listening?

### `ping`

Tests basic network reachability.
```
ping google.com
ping -c 4 google.com
```
`-c 4` = send 4 packets and stop.

**Real-time example:** `ping server-ip` — if replies are received, basic connectivity exists.

⚠️ **Important:** Ping failure does NOT always mean the server is down. ICMP may be blocked by a firewall, AWS Security Group, or Network ACL.

### `traceroute`

Shows the network path/hops between source and destination.
```
traceroute google.com
```
Path: Your Machine → Router → ISP → Internet Routers → Destination.

**Why use it:** troubleshooting network latency, routing problems, connectivity issues.

**Note:** may need to install — `sudo yum install traceroute -y` (RHEL/Amazon Linux) or `sudo apt install traceroute` (Ubuntu).

### `telnet`

Tests whether a TCP port is reachable.
```
telnet <host> <port>
telnet 10.0.1.20 8080
```
If connected → port 8080 is reachable.

**Real-time example:** App server `10.0.1.20`, app on port `8080` → `telnet 10.0.1.20 8080`. Path being tested: Client → Network → Server → Port 8080.

⚠️ **Important:** Telnet itself is an old, insecure remote-login protocol. For secure remote login use `ssh`. For modern TCP port testing use `nc -zv <host> <port>`.

### `netstat`

Displays network connections, listening ports, network information.
```
netstat -an
```
`-a` = show all connections/listening sockets. `-n` = show numeric IPs/ports.

**Check specific port:**
```
$ netstat -an | grep 8080
tcp  0  0 0.0.0.0:8080  0.0.0.0:*  LISTEN
```
`LISTEN` = application is listening on port 8080.

**Common DevOps command:**
```
netstat -tulnp
```
`-t` TCP, `-u` UDP, `-l` listening, `-n` numeric, `-p` process.

**Modern alternative:** `ss -tulnp` — preferred on modern Linux systems, but `netstat` is still common in interviews and on older servers.

**Easy memory trick:**
- `ping` → Can I reach the host?
- `traceroute` → What path does traffic take?
- `telnet` / `nc` → Can I reach this TCP port?
- `netstat` / `ss` → What is listening on the server?

---

## 6. Real-Time Troubleshooting Scenario

**Problem:** Users cannot access the application.

| Step | Command | Question |
|---|---|---|
| 1 | `df -h` | Is disk usage 100%? |
| 2 | `du -sh /var/*` | Which directory is consuming space? |
| 3 | `ps -ef \| grep java` | Is the application running? |
| 4 | `netstat -an \| grep 8080` or `ss -tulnp \| grep 8080` | Is application listening on 8080? |
| 5 | `ping server-ip` | Can I reach the server? |
| 6 | `traceroute server-ip` | Where is traffic going? |
| 7 | `telnet server-ip 8080` or `nc -zv server-ip 8080` | Can I reach port 8080? |
| 8 | `ls -l /opt/app` | Is ownership/permission correct? |
| 9 | `chown -R appuser:appgroup /opt/app` | Fix ownership if required |
| 10 | `chmod -R 755 /opt/app` | Fix permissions if required |

---

## 7. Quick Recap

| Command | Meaning |
|---|---|
| `df -h` | Check filesystem disk space |
| `du -sh /var/log` | Check directory size |
| `chmod 755 file` | Change permissions |
| `chmod +x script.sh` | Make script executable |
| `chmod 400 key.pem` | Restrict private key access |
| `groupadd devops` | Create group |
| `usermod -aG devops user` | Add user to group |
| `chown user:group file` | Change owner and group |
| `ping server-ip` | Test basic connectivity |
| `traceroute server-ip` | Show network path |
| `telnet server-ip 8080` | Test TCP port |
| `netstat -an` | Show network connections |
| `ss -tulnp` | Show listening ports/processes |

---

## 8. Interview Questions

1. What is the difference between `df` and `du`?
2. What does `chmod 755` mean?
3. What is the difference between `chmod` and `chown`?
4. What are User, Group, and Others?
5. What are `r`, `w`, and `x` permissions?
6. Why do we use groups in Linux?
7. Why do we use `-a` with `usermod -aG`?
8. Why do we use `chmod 400` for an SSH private key?
9. Does `ping` failure always mean the server is down?
10. What is `traceroute` used for?
11. How do you check whether port 8080 is listening?
12. What is the difference between `telnet` and `SSH`?
13. What is `netstat`?
14. What is the modern alternative to `netstat`?
15. How would you troubleshoot an application that users cannot access?

---

## Easy Memory Trick — Full Recap

| Command | Trick |
|---|---|
| `df` | How much disk space? |
| `du` | What is consuming the disk? |
| `chmod` | Who can DO what? |
| `chown` | Who OWNS it? |
| `groups` | Who belongs to which group? |
| `ping` | Can I reach the host? |
| `traceroute` | What path does traffic take? |
| `telnet` / `nc` | Can I reach this TCP port? |
| `netstat` / `ss` | What is listening on the server? |
