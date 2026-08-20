# Batch 18 — Linux Running Notes: 19 August 2026

**Topic: Linux File System Hierarchy, Copy/Move Operations, Compression (zip/tar)**

Friends, today we understood how Linux **organizes** all its files and folders (the "file system hierarchy"), practiced copying and moving files around properly, and learned how to download, compress, and extract files — all things you will use constantly in real DevOps work, especially when installing software like Tomcat on a server.

---

## 1. Linux File System Hierarchy — the "map" of a Linux system

In Linux, **everything starts from one single root folder**, written as `/`. Unlike Windows (which has separate drives like `C:`, `D:`), Linux has just one tree, and every single file/folder — no matter which disk it physically lives on — hangs somewhere under this one root `/`.

```
top ---> /  (root directory)
```

When you run `ls -l /`, you see folders like this:

```
bin    -> usr/bin      (commands like ls, cat, etc.)
boot                    (files needed to boot up the system)
dev                     (device files — hard disks, USB, etc.)
etc                     (system-wide configuration files)
home                    (personal folders for each user)
lib, lib64  -> usr/lib  (shared libraries needed by programs)
media, mnt              (mount points for external/removable drives)
opt                     (optional/third-party software)
proc                    (live information about running processes)
root                    (home directory of the root user specifically)
run                     (runtime data for currently running processes)
sbin   -> usr/sbin      (admin-only commands)
srv                     (data for services running on this server)
sys                     (kernel and hardware info)
tmp                     (temporary files, cleared periodically)
usr                     (user programs and files — the biggest folder)
var                     (variable data — logs, mail, spool files, etc.)
```

**Real-time example:** As a DevOps engineer, you navigate specific folders constantly, almost without thinking: application/service logs live under `/var/log` — it's the very first place you check during an incident. Installed third-party software often goes under `/opt` — that's exactly where we're about to install Tomcat today. Temporary build or download files land in `/tmp`, and gets cleaned up automatically. Configuration files you'll edit to set up services live under `/etc`. Knowing this layout by heart is what lets you troubleshoot an unfamiliar server quickly during an incident, instead of hunting around blindly while production is down.

### Absolute path vs Relative path

- **Absolute path** — the *full* address starting from root, e.g. `/opt/a/b/c`. It always works, no matter where you currently are.
- **Relative path** — the address *relative to where you currently are*, e.g. `cd b/c` (only works correctly if you're already inside the right starting folder).

**Real-time example:** In Jenkins pipelines, deployment scripts, and cron jobs, always prefer **absolute paths** (like `/opt/apache-tomcat-9.0.121/webapps`) over relative paths. A script that works perfectly fine when you run it manually from your home folder can silently fail inside a Jenkins job or a cron job, because those start from a completely different working directory than your terminal session does. This exact mismatch is one of the most common causes of "it works on my machine, but fails in the pipeline" bugs that DevOps engineers get called in to debug.

---

## 2. Installing software with `yum`

```
yum install <pkg>
```
`yum` is the **package manager** for RHEL/Amazon Linux/CentOS-based systems — it downloads and installs software packages directly from the internet, handling all the setup for you.

**Real-time example:** You'll use `yum install` (or `apt install` on Ubuntu/Debian) to set up almost every tool you need on a fresh server — Java, Git, Docker, Jenkins, Ansible. It's usually one of the very first commands run on any brand-new EC2 instance, right after connecting to it, before installing your actual DevOps toolchain on top.

---

## 3. Creating nested folders in one shot: `mkdir -p`

```
mkdir -p a/b/c/d/e
```
Normally, `mkdir` can only create one folder at a time, and it fails if the parent folder doesn't exist yet. The `-p` flag (**parents**) tells Linux: "create every folder in this path that doesn't already exist, all in one go."

**Real-time example:** This is exactly how you'd set up a standard deployment folder structure on a new server in a single command — for example, `mkdir -p /opt/myapp/releases/current`. Deployment scripts use `mkdir -p` constantly so they don't fail just because a parent folder happens to be missing on a fresh server.

---

## 4. Copying and moving files: `cp -rp` and `mv`

```
cp -rp src.path dest.path
```
`cp` **copies** a file or folder. `-r` means recursive (copy folders and everything inside them too), `-p` means preserve (keep the original permissions, ownership, and timestamps on the copy, instead of resetting them).

```
mv src dest
```
`mv` **moves** a file or folder to a new location — or, if the destination is just a new name in the same folder, it effectively **renames** it. Unlike `cp`, the original is gone from its old location after `mv`.

**Real-time example:** Before overwriting a config file during a deployment, a careful DevOps engineer always takes a backup first: `cp -rp app.properties app.properties.bak` — the `-p` matters here because it preserves the original timestamp, which is exactly what you need when comparing "what changed and when" during an incident review. `mv` is used in real deployments to swap in a new application version with minimal downtime — build the new release in a temp folder, then `mv` it into the live `current` folder (or symlink) in one atomic step, which is the basic idea behind blue-green style deployments.

---

## 5. Downloading files from the internet: `wget`

```
wget <link>

wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.121/bin/apache-tomcat-9.0.121.zip
```
`wget` **downloads a file directly from a URL** onto your server — no browser needed, works purely from the command line. This is extremely useful on servers, since servers usually don't have a graphical browser at all.

**Real-time example:** This is exactly how we downloaded Apache Tomcat onto our EC2 server, and it's the same pattern you'll use to pull any installer, binary, or artifact directly onto a headless server — a specific JDK version, a Jenkins WAR file, a Maven binary, or even an application build artifact copied from an S3 bucket URL.

---

## 6. Compressing and extracting files: zip/unzip and tar

### zip / unzip

```
unzip apache-tomcat-9.0.121.zip
```
**Extracts** (unpacks) the contents of a `.zip` file into the current folder.

```
zip -r devopskeys.zip devopskeys
```
**Compresses** a folder (here, `devopskeys`) into a single `.zip` file. `-r` means recursive — include all the files and subfolders inside it, not just the top-level folder itself.

**Real-time example:** In real projects, build tools like Maven package your entire application into a single deployable file (a `.war` or `.jar`) — a very similar idea to zipping. On the server side, you often need to `unzip`/extract an artifact that was copied over from a CI/CD pipeline before actually deploying it to Tomcat.

### tar — the other common compression format

```
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.121/bin/apache-tomcat-9.0.121.tar.gz

tar -xvf apache-tomcat-9.0.121.tar.gz
```
`tar` is another, very common way to package/extract files on Linux (short for "tape archive," from its old backup-tape days). `-x` means extract, `-v` means verbose (show each file as it's being extracted, so you can see progress), `-f` means the next argument is the filename to work on.

```
tar -cvf tomcat.tar.gz apache-tomcat-9.0.121
```
Here `-c` means **create** a new archive (instead of extracting), packing the `apache-tomcat-9.0.121` folder into `tomcat.tar.gz`. `-v` and `-f` mean the same as above.

**Real-time example:** This is precisely how we prepared Tomcat for use in a real project: download it as `.tar.gz`, extract it with `tar -xvf` into `/opt`. Later, if you need to move that installed application to another server, or take a backup before an upgrade, you'd package it back up with `tar -cvf`. In real DevOps work, `.tar.gz` is what you'll see used to distribute almost every open-source tool you install — Tomcat, Maven, Jenkins agents, Prometheus, and more.

**Quick memory trick:** think of `tar -x` as "e**X**tract" and `tar -c` as "**C**reate" — the letter itself hints at what it does.

---

## Quick Recap Table

| Command | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `/` (root) | The single top-level folder everything lives under | `/var/log` for logs, `/opt` for installed software, `/etc` for configs |
| Absolute path | Full address, works from anywhere | Always use in Jenkins pipelines/cron jobs to avoid path bugs |
| Relative path | Address relative to where you stand now | Works fine manually, but can silently fail inside a pipeline job |
| `yum install <pkg>` | Installs software from the internet | First command run on a fresh EC2 instance — installing Java, Git, Docker |
| `mkdir -p a/b/c` | Creates nested folders in one shot | Deployment scripts creating `/opt/myapp/releases/current` in one go |
| `cp -rp` | Copies files/folders, keeping original details | Backing up a config file before overwriting it during a deployment |
| `mv` | Moves or renames a file/folder | Swapping in a new release folder with minimal downtime |
| `wget <url>` | Downloads a file from the internet | Pulling Tomcat, a JDK, or a build artifact onto a headless server |
| `zip -r` / `unzip` | Compress / extract a `.zip` archive | Extracting a CI/CD build artifact before deploying it to Tomcat |
| `tar -cvf` / `tar -xvf` | Create / extract a `.tar` archive | Installing Tomcat/Maven/Jenkins agents, distributed as `.tar.gz` |

That's today's session, friends — file system hierarchy plus copy/move/compress commands are things you will use in almost every single real DevOps task, from installing Tomcat to deploying application code. Practice these with your own hands, not just by reading.
