# Batch 18 — Linux Running Notes: 24 August 2026

**Topic: Disk usage (`df`, `du`), File Permissions & Ownership (`chmod`, `chown`), Networking commands (`ping`, `traceroute`, `telnet`, `netstat`)**

Friends, so far we've been creating files, copying them, editing them, and running Tomcat as a process. Today we look at three practical, everyday topics: how to check how much disk space is used up on a server (`df`, `du`), how to control **who is allowed to read/write/run** a file (`chmod` — file permissions), and finally the basic networking commands (`ping`, `traceroute`, `telnet`, `netstat`) you'll use to check whether a server or a port is even reachable in the first place.

---

## 1. `df` — checking disk space usage

```
df
df -h
df -m
```
`df` stands for **disk filesystem** — it reports how much space is used and how much is still free on every mounted filesystem on the server. Plain `df` shows sizes in blocks, which is hard to read at a glance, so we almost always add a flag: `-h` shows sizes in **human-readable** form (KB/MB/GB), and `-m` shows everything in **megabytes**.

**Sample output:**
```
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       20G  6.1G   13G  33% /
tmpfs           487M     0  487M   0% /dev/shm
/dev/xvdb1       50G   38G   9.5G  81% /opt
```
The last column, `Use%`, is the one everyone actually looks at — 81% used on `/opt` is a warning sign; if it creeps toward 100%, applications on that mount can start failing to write logs or deploy new builds.

**A Windows-vs-Linux point that trips up a lot of people coming from Windows:** in Windows, each drive/partition gets its own letter — `C:`, `D:`, `E:` — and they feel like separate "worlds." **Linux has no drive letters at all.** There's just **one single tree**, starting at `/` (root), and every disk/partition/network share gets **mounted** onto some folder inside that same tree — so `/opt` might secretly be a whole separate disk, but to you it just looks like a normal folder. This is why `df -h` is the command that tells you what's *really* mounted where, since you can't tell just by looking at folder names.

**More examples:**
- `df -h /opt` — checking the usage of just one specific mount point instead of scrolling through the full list.
- `df -h | grep -v tmpfs` — filtering out the temporary/virtual filesystems (`tmpfs`) so you only see real disks.
- Checking `df -h` right before a big deployment or a log-heavy debugging session, so a build doesn't fail halfway through with a cryptic "No space left on device" error.

```
du -h <foldername/filename>
du -sh <foldername/filename>
```
`du` stands for **disk usage** — unlike `df` (which reports the whole filesystem), `du` tells you how much space one specific **folder or file** is actually consuming. `-h` again means human-readable. Plain `du -h` on a folder lists the size of **every subfolder inside it**, which can be a wall of output for a big folder; `-s` gives you just the **summary** — one single total size for that folder, instead of a size for every subfolder inside it.

**Sample output:**
```
$ du -h /opt/apache-tomcat-9.0.121
4.0K    /opt/apache-tomcat-9.0.121/temp
128K    /opt/apache-tomcat-9.0.121/conf
45M     /opt/apache-tomcat-9.0.121/webapps
52M     /opt/apache-tomcat-9.0.121

$ du -sh /opt/apache-tomcat-9.0.121
52M     /opt/apache-tomcat-9.0.121
```

**Real-time example:** `df -h` tells you *a disk is nearly full*; `du -sh */` tells you *which folder is actually eating up all that space*, so the two commands are almost always used one after the other — `df -h` to spot the problem, `du -sh` to hunt down the exact folder (usually old log files, or an old build artifact nobody cleaned up) responsible for it.

**More examples:**
- `du -sh /var/log/*` — sizing up every subfolder/file directly under `/var/log`, a classic first move when a server's disk is filling up from logs.
- `du -sh *` — run **inside** a folder, to quickly see which of its immediate subfolders is the biggest space hog.
- `du -h --max-depth=1 /opt` — showing sizes one level deep only, instead of every nested subfolder, for a quick overview without the noise.

---

## 2. File permissions & ownership — `chmod`

Every file and folder in Linux has an **owner**, a **group**, and permissions that decide who can read it, write to it, or run it. `chmod` (**ch**ange **mod**e) is the command that changes those permissions.

There are three categories of "who":

| Symbol | Means |
|---|---|
| `u` | **user** — the file's owner |
| `g` | **group** — the group the file belongs to |
| `o` | **others** — everyone else on the system |
| `a` | **all** — user + group + others together |

And three types of permission, shown as `r`, `w`, `x` when you run `ll`:

| Permission | Symbol | Meaning |
|---|---|---|
| read | `r` | can view the file's contents / list a folder |
| write | `w` | can modify the file / create-delete files in a folder |
| execute | `x` | can **run** the file as a program or script / enter a folder |

So a line like `rwxr-xr--` breaks into three groups of three: `rwx` (owner can read/write/execute), `r-x` (group can read/execute but not write), `r--` (others can only read).

**Numeric (octal) notation** — instead of typing letters, you can give each permission a number and add them up: `r=4`, `w=2`, `x=1`. This gives you one digit per category:

| Number | Meaning | Made from |
|---|---|---|
| `7` | read + write + execute | 4+2+1 |
| `6` | read + write | 4+2 |
| `5` | read + execute | 4+1 |
| `4` | read only | 4 |

So `chmod 755 script.sh` means: owner gets `7` (full rwx), group gets `5` (r-x), others get `5` (r-x) — a very common permission set for scripts.

```
chmod 755 deploy.sh
chmod -R 755 webapps/
```
`-R` = **recursive** — applies the permission change not just to the folder itself, but to **every file and subfolder inside it** as well.

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
Before `chmod`, the `x` was missing, so even the owner couldn't run `./deploy.sh` — it would fail with "Permission denied." After `chmod 755`, the `x` shows up in all three positions and the script runs.

**Real-time example — three situations every DevOps engineer runs into constantly:**
- **Make a script executable:** `chmod +x deploy.sh` or `chmod 755 deploy.sh` — you write a shell script and try to run it with `./deploy.sh`, and Linux says "Permission denied" — that's because the execute bit isn't set yet. This is one of the single most common beginner errors in Linux.
- **Secure private SSH keys:** `chmod 400 mykey.pem` — an SSH private key file *must* be readable only by its owner, and not writable/readable by anyone else at all. If the permissions are too open, SSH itself will flatly refuse to use the key and error out with a "UNPROTECTED PRIVATE KEY FILE" warning — this is a very common real mistake when downloading a `.pem` file from AWS.
- **Restrict a folder to the owner only:** `chmod 700 /home/madhu/secrets` — `7` for the owner (full access) and `0` for group and others (no access at all) — used for folders holding sensitive data that only one user account should ever be able to touch.

**More examples:**
- `chmod u+x script.sh` — the symbolic way to add just the execute permission for the owner only, without touching group/others at all (`+` adds a permission, `-` removes one).
- `chmod go-w file.txt` — removing write permission from group and others, while leaving the owner's permissions untouched.
- `ll` (or `ls -l`) before and after any `chmod` — always double check the permission string changed the way you expected, especially before using `-R` on a large folder.

---

## 3. `chown` — changing file/directory ownership

`chmod` controls **what** the owner/group/others are allowed to do; `chown` (**ch**ange **own**er) controls **who** the owner and group actually are in the first place. Every file has both a user-owner and a group-owner, and `chown` is how you change either or both.

```
chown newuser filename
chown :newgroup filename
chown newuser:newgroup filename
chown newuser:newgroup file1 file2 file3
```
- `chown newuser filename` — changes only the **user (owner)** of the file, leaving the group untouched.
- `chown :newgroup filename` — the leading `:` means only the **group** is changed, leaving the owner untouched.
- `chown newuser:newgroup filename` — changes **both** owner and group in one shot.
- `chown` also accepts multiple filenames at once, applying the same ownership change to all of them together.

**Sample output:**
```
$ ll deploy.sh
-rwxr-xr-x. 1 ec2-user ec2-user 128 Aug 24 11:05 deploy.sh

$ sudo chown madhu:devops deploy.sh
$ ll deploy.sh
-rwxr-xr-x. 1 madhu devops 128 Aug 24 11:05 deploy.sh
```
Notice only the 3rd and 4th columns (owner, group) changed from `ec2-user ec2-user` to `madhu devops` — the permission bits (`rwxr-xr-x`) themselves are completely unaffected by `chown`, since that's `chmod`'s job, not `chown`'s. Also notice the `sudo` — changing a file's ownership to someone else is a privileged operation, so you normally need root/sudo access to run `chown`.

**Real-time example:** A very common real scenario — a deployment script or a build tool (running as `root`, or as a `jenkins` service account) creates files on a server, and those files end up owned by that account. But the application itself needs to run as a different, unprivileged user (say `tomcat` or `appuser`) for security reasons — and that user can't manage files it doesn't own. `chown -R tomcat:tomcat /opt/apache-tomcat-9.0.121/webapps` fixes exactly this, handing ownership of the whole deployed app over to the account that should actually be running it.

**More examples:**
- `chown -R appuser:appgroup /var/www/myapp` — `-R` (recursive), just like with `chmod`, applies the ownership change to an entire folder tree at once — the usual way to fix ownership after deploying a whole application folder.
- Using `chmod` and `chown` together right after a deployment: `chown` to set the correct owner/group, then `chmod` to set the correct permissions — two different jobs, almost always done as a pair in a real deployment script.
- `ll` before and after a `chown`, the same habit as with `chmod` — always confirm the owner/group columns changed to exactly what you intended, especially before running it with `-R` on a large folder.

---

## 4. Networking commands — `ping`, `traceroute`, `telnet`, `netstat`

Before you even worry about "why isn't my application working," you first need to know: **is the server reachable at all**, and **is the specific port open**? These four commands answer exactly that.

```
ping google.com
ping -c 4 example.com
```
`ping` sends small test packets to a host and waits for a reply, to check basic network connectivity — "is this machine even alive and reachable over the network?" Plain `ping` keeps running forever until you press `Ctrl+C`; `-c 4` tells it to send exactly **4** packets and then stop on its own — much friendlier when you just want a quick check, especially in a script.

**Sample output:**
```
$ ping -c 4 google.com
PING google.com (142.250.193.78) 56(84) bytes of data.
64 bytes from 142.250.193.78: icmp_seq=1 ttl=115 time=3.21 ms
64 bytes from 142.250.193.78: icmp_seq=2 ttl=115 time=3.05 ms
64 bytes from 142.250.193.78: icmp_seq=3 ttl=115 time=3.44 ms
64 bytes from 142.250.193.78: icmp_seq=4 ttl=115 time=3.11 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
```
`0% packet loss` means every packet got a reply — the host is reachable and the network path is healthy. If you instead see `100% packet loss` or "Destination Host Unreachable," the server is down, the network path is broken, or (very commonly on AWS) the Security Group is blocking ICMP traffic entirely.

**Real-time example:** `ping` is almost always the **very first troubleshooting step** — before checking application logs, before checking Tomcat, before anything — because it answers the most basic question: is the server reachable over the network at all? If `ping` itself fails, there's no point debugging the application yet; the problem is at the network/infra level.

```
traceroute google.com
```
Shows the **path** — every intermediate network hop (router/gateway) — that your traffic passes through to reach the destination, along with the response time at each hop.

**Sample output:**
```
$ traceroute google.com
traceroute to google.com (142.250.193.78), 30 hops max
 1  192.168.1.1 (192.168.1.1)  1.123 ms  1.045 ms  1.012 ms
 2  10.10.0.1 (10.10.0.1)  4.201 ms  4.150 ms  4.098 ms
 3  * * *
 4  142.250.193.78 (142.250.193.78)  3.400 ms  3.312 ms  3.290 ms
```
A `* * *` on a hop means that particular router didn't respond — not always a problem, some routers are simply configured to ignore these probes.

**Real-time example:** If `ping` says a server is unreachable, `traceroute` helps narrow down **where exactly** the connection is breaking — is it failing right at the very first hop (your own network/VPC), or several hops later out on the wider internet? This distinction decides whether you go raise a ticket with your own infra team or with the ISP/cloud provider.

```
telnet www.google.com 443
telnet 100.26.144.255 8080
```
`telnet` here is being used **not** for its old original purpose (remote login), but as a quick way to test whether a **specific port** is open and accepting connections on a remote host — `telnet <host> <port>`.

**Sample output:**
```
$ telnet 100.26.144.255 8080
Trying 100.26.144.255...
Connected to 100.26.144.255.
Escape character is '^]'.
```
"Connected" means the port is open and something is listening on it. If instead it hangs for a long time and then times out, or says "Connection refused," the port is either blocked (Security Group / firewall) or nothing is running on that port.

**Real-time example:** This is *the* fastest way to answer "is my Security Group actually letting port 8080 through?" without opening a browser at all — `telnet <server-IP> 8080` right after starting Tomcat tells you immediately whether the port-level networking is fine, separate from whether the application itself is working correctly.

```
netstat -an
```
`netstat` displays active network connections, listening ports, and routing information on the local machine. `-a` shows **all** connections and listening ports, `-n` shows addresses and port **numbers** instead of trying to resolve them into hostnames (which is both faster and avoids confusing DNS lookups in the output).

**Sample output:**
```
$ netstat -an
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN
tcp        0      0 10.0.1.15:22            203.0.113.5:51022       ESTABLISHED
```
`LISTEN` on `0.0.0.0:8080` confirms Tomcat is actually up and waiting for connections **on this server itself** — a useful check to run locally before even reaching for `telnet` or a browser from somewhere else.

**Real-time example:** Combine it with `grep` the same way we did with `ps -ef`: `netstat -an | grep 8080` — instantly confirms whether Tomcat (or any app) is really listening on the port you expect, right on the server itself, before blaming the network or the Security Group for a connection failure.

**More examples:**
- `ping -c 4 <server-IP>` immediately after launching a new EC2 instance, as the first sanity check that it's up and reachable.
- `telnet <db-host> 3306` — checking whether a database port is reachable from an application server, a very common step while debugging "app can't connect to DB" issues.
- `netstat -an | grep LISTEN` — listing only the ports that are actively listening on a server, to get a quick picture of everything running on it.

---

## Quick Recap Table

| Command | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `df -h` | Disk space used/free on each mounted filesystem | First check when a server is running low on disk space |
| `du -sh <folder>` | Total size of one specific folder/file | Hunting down exactly which folder is eating up disk space |
| `chmod 755 file` / `chmod +x file` | Change read/write/execute permissions | Making a deployment script executable before running it |
| `chmod 400 key.pem` | Restrict a file to owner-read-only | Securing an SSH private key so SSH will actually accept it |
| `chown user:group file` | Change a file's owner and/or group | Handing a deployed app's files over to the correct service account |
| `ping -c 4 <host>` | Test basic network reachability | First troubleshooting step — is the server even reachable? |
| `traceroute <host>` | Show the network path/hops to a host | Narrowing down exactly where a connection is breaking |
| `telnet <host> <port>` | Test whether a specific port is open | Confirming a Security Group/firewall is really letting a port through |
| `netstat -an` | List listening ports & active connections on this machine | Confirming an app (e.g. Tomcat) is really listening on its port |

That's today's session, friends — `df`/`du` for disk space, `chmod`/`chown` for permissions and ownership, and `ping`/`traceroute`/`telnet`/`netstat` for basic network troubleshooting. Between today and the earlier `ps`/`grep`/`find`/`sed` session, you now have the core toolkit every DevOps engineer reaches for when something "isn't working" and you need to figure out why — practice running these on your own EC2 instance until they feel automatic.
