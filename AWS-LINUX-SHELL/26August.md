# Batch 18 — Linux Running Notes: 26 August 2026

**Topic: Inodes, Hard vs Soft Links (`ln`), Text Column Tools (`cut`, `awk`), File Transfer (`scp`, WinSCP), Networking (`ip addr`, `nslookup`/`dig`, `curl`)**

Friends, last class we covered disk usage, permissions, ownership, and basic connectivity checks. Today we go one level deeper: how Linux actually tracks a file internally (inodes), two different ways to "link" one file to another, two tools for pulling specific columns out of structured text (`cut`, `awk`), how to move files between your PC and a server (`scp`/WinSCP), and a few more networking commands (`ip addr`, `nslookup`/`dig`, `curl`) that round out your troubleshooting toolkit.

---

## 1. Inodes — how Linux tracks a file

An **inode** (index node) is a data structure holding a file's **metadata** — Linux doesn't track a file by its name internally, it tracks it by inode number; the filename is just a label pointing at one.

**What an inode stores:**
- File type — regular file, directory, symbolic link, etc.
- Permissions — read/write/execute for owner, group, others
- Owner and group — UID and GID
- Timestamps:
  - `atime` — last **accessed** (opened/read)
  - `mtime` — last **content** modified
  - `ctime` — last **metadata** (permissions/owner) changed
- File size in bytes

```
ls -i file.txt
ll -i file.txt
```
`-i` prints the file's inode number alongside its normal listing.

**Sample output:**
```
$ ls -i notes.txt
884521 notes.txt

$ ll -i notes.txt
884521 -rw-r--r-- 1 madhu madhu 120 Aug 26 09:00 notes.txt
```

**Real-time example:** Two "different" filenames pointing at the exact same inode number is exactly how a **hard link** works (next section) — this is the concept that makes hard links possible in the first place.

**Easy memory trick:** inode → a file's **ID card**, not its name.

---

## 2. Hard link vs soft link — `ln`

Both let one file "point to" another, like a shortcut — but they behave very differently.

| | Hard link | Soft (symbolic) link |
|---|---|---|
| Command | `ln target link` | `ln -s target link` |
| Points to | the same **inode** (same data on disk) | the **path** of the target file |
| If original is deleted | link still works — data isn't gone until all hard links are removed | link **breaks** ("dangling" link) |
| Shown in `ll` as | a normal file | starts with `l`, shows `link -> target` |

```
ln /opt/app/config.yaml /opt/app/config-backup.yaml
ln -s /opt/apache-tomcat-9.0.121 /opt/tomcat
```

**Sample output:**
```
$ ln -s /opt/apache-tomcat-9.0.121 /opt/tomcat
$ ll /opt/tomcat
lrwxrwxrwx 1 root root 28 Aug 26 09:10 /opt/tomcat -> /opt/apache-tomcat-9.0.121
```
The `l` and the `->` arrow are how Linux marks a symbolic link.

**Real-time example:** Point a generic name like `/opt/tomcat` at whatever Tomcat version is currently installed via a soft link — deployment scripts always reference `/opt/tomcat`, and upgrading Tomcat later is just re-pointing the link, no script changes needed.

**Easy memory trick:** hard link → same file, two names. Soft link → a shortcut that can go dangling.

---

## 3. `cut` — pull out specific columns

`cut` slices each line by a delimiter and prints just the column(s) you want — great for structured files like `/etc/passwd` (colon-separated: `username:password:UID:GID:description:home:shell`).

```
cut -d ":" -f 1 /etc/passwd
cut -d ":" -f 1,6 /etc/passwd
cut -d ":" -f 1,2,3,4 /etc/passwd
cut -d ":" -f 1-4 /etc/passwd
```
`-d` sets the delimiter, `-f` picks the field number(s) — a single number, a comma list, or a `start-end` range.

**Sample output:**
```
$ cut -d ":" -f 1,6 /etc/passwd
root:/bin/bash
madhu:/bin/bash
```

**Piped version:**
```
cat /etc/passwd | cut -d ":" -f 1,6
```

**Real-time example:** Pulling just the username column out of `/etc/passwd` to get a quick list of every account on a server — a common first step during a user-access audit.

---

## 4. `awk` — a more powerful column tool

`awk` does the same job as `cut` but is more flexible — it can combine fields, add custom separators, and do simple text processing.

```
awk -F":" '{print $1}' /etc/passwd
awk -F":" '{print $1 "=" $6}' /etc/passwd
cat /etc/passwd | awk -F":" '{print $1}'
```
`-F` sets the field separator (like `cut -d`); `$1`, `$6` refer to field 1 and field 6; `print` builds the output line, and you can glue fields together with any text (like `"="` above).

**Sample output:**
```
$ awk -F":" '{print $1 "=" $6}' /etc/passwd
root=/bin/bash
madhu=/bin/bash
```

### `cut` vs `awk`

| | `cut` | `awk` |
|---|---|---|
| Best for | grabbing plain column(s) as-is | combining/formatting fields, custom output |
| Syntax | simpler | more powerful, script-like |

**Real-time example:** `cut` for a quick "just give me column 1"; `awk` when you need to reformat the output (e.g. `user=shell`) or eventually add conditions — `awk` is what you reach for once `cut` isn't flexible enough.

**Easy memory trick:** `cut` → simple slice. `awk` → slice **and** reshape.

---

## 5. File transfer — WinSCP and `scp`

**WinSCP** — a free Windows GUI tool to copy files between your PC and a Linux server. Two-pane window (PC on one side, server on the other), drag-and-drop — no commands needed. Under the hood it uses the same SFTP/SSH connection as `scp`.

To connect to an EC2 server: New Session → File protocol **SFTP** → Host = server's public IP/DNS → Username = `ec2-user` → Advanced → SSH → Authentication → select your `.pem` key.

**`scp`** — Secure Copy, the command-line version of the same thing. `cp`, but over the network.

```
scp -i madhu.pem Prabhas ec2-user@ec2-54-92-176-107.compute-1.amazonaws.com:/tmp/Prabhas
```
- `-i madhu.pem` — the private key proving your identity (same key used to SSH in)
- `Prabhas` — local file being copied
- `ec2-user@<host>` — remote user + server address
- `:/tmp/Prabhas` — destination path on the remote server

**Real-time example:** Copying a build artifact or a config file from your laptop straight onto an EC2 instance without opening a browser or a GUI — `scp` is the version you'd put inside a deployment script; WinSCP is the version you'd use to manually browse and drag files while debugging.

**Easy memory trick:** `scp` → `cp`, but across the network.

---

## 6. `ip addr` / `ifconfig` — network interfaces

Shows this machine's network interfaces and their IP addresses. `ip addr` (or `ip a`) is the modern command; `ifconfig` is the older one it replaced.

```
ip addr
```

**Sample output:**
```
$ ip addr
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 172.31.20.15/20 brd 172.31.31.255 scope global eth0
```

**Real-time example:** Confirming what private IP a freshly launched EC2 instance actually has, especially useful when `hostname -I` output needs double-checking against what the AWS console shows.

---

## 7. `nslookup` / `dig` — DNS lookup

Looks up the IP address a domain name resolves to.

```
nslookup www.mindcircuit.in
```

**Sample output:**
```
$ nslookup www.mindcircuit.in
Name:    www.mindcircuit.in
Address: 172.67.128.45
```

**Real-time example:** Right after updating a domain's DNS records (say, pointing it at a new server), `nslookup`/`dig` confirms whether the change has actually propagated — before assuming "the app is broken" when really it's just DNS still pointing at the old IP.

**Easy memory trick:** `nslookup`/`dig` → "What IP does this name point to?"

---

## 8. `curl` — test an endpoint from the terminal

Hits a web/API endpoint directly, without a browser.

```
curl http://<server-IP>:8080
curl -I https://www.google.com
```
`-I` fetches only the HTTP headers/status code, not the full page — a fast "is this URL up, what status code?" check.

**Sample output:**
```
$ curl -I https://www.google.com
HTTP/2 200
server: gws
content-type: text/html; charset=ISO-8859-1
```

**`curl` can download too:**
```
curl -O https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.121/bin/apache-tomcat-9.0.121.tar.gz
curl -o tomcat.tar.gz https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.121/bin/apache-tomcat-9.0.121.tar.gz
```
`-O` (capital O) saves the file under its original name from the URL. `-o` (lowercase o) saves it under a filename you choose.

**Sample output:**
```
$ curl -O https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.121/bin/apache-tomcat-9.0.121.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
100 11.8M  100 11.8M    0     0  9821k      0  0:00:01  0:00:01 --:--:-- 9834k
```

### `curl` vs `wget`

| | `curl` | `wget` |
|---|---|---|
| Main use | testing/inspecting an endpoint (headers, API responses) — downloading is a secondary use | dedicated downloader — that's its one job |
| Download flag | `-O` (keep original filename) / `-o` (custom filename) | just the URL, saves the file directly |
| Extra strengths | talks to APIs — custom headers, POST data, auth | can resume interrupted downloads, recursively download whole sites |

**Real-time example:** Right after `./startup.sh`, `curl -I <server-IP>:8080` (run on the server itself, over SSH) confirms Tomcat is actually responding, before you even worry about Security Groups or browser access. For grabbing a file — like the Tomcat archive itself — `wget <url>` is still the more common habit on servers since it's simpler for a plain download, but `curl -O <url>` does the exact same job.

**Easy memory trick:** `curl` → talk to a URL and see the response (and can download too, with `-O`). `wget` → built specifically to download.

---

## Quick Recap Table

| Command | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `ls -i` / `ll -i` | Show a file's inode number | Confirming two filenames share the same underlying data (hard link) |
| `ln target link` | Create a hard link | Rarely used directly, but explains how hard links survive deletion |
| `ln -s target link` | Create a soft/symbolic link | Pointing `/opt/tomcat` at whatever version is currently installed |
| `cut -d ":" -f 1 file` | Extract column(s) by delimiter | Pulling usernames out of `/etc/passwd` |
| `awk -F":" '{print $1}' file` | Extract/reshape columns | Formatting `user=shell` pairs from `/etc/passwd` |
| `scp -i key.pem src user@host:dest` | Copy a file to/from a remote server | Pushing a build artifact onto an EC2 instance from a script |
| `ip addr` | Show network interfaces & IPs | Confirming a server's private IP |
| `nslookup <domain>` | DNS lookup | Verifying DNS actually points to the new server after a change |
| `curl -I <url>` | Test an endpoint, headers only | Confirming Tomcat is responding right after startup |
| `curl -O <url>` | Download a file, keeping its original name | Grabbing an archive without switching to `wget` |
