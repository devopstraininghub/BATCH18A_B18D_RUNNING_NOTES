# Batch 18 — Linux Running Notes: 19 August 2026

**Topic: Linux File System Hierarchy, Vi/Vim Navigation & Editing, Copy/Move Operations, Compression (zip/tar)**

Friends, today we understood how Linux **organizes** all its files and folders (the "file system hierarchy"), went deeper into vim's actual navigation and editing commands, practiced copying and moving files around properly, and learned how to download, compress, and extract files — all things you will use constantly in real DevOps work, especially when installing software like Tomcat on a server.

---

## 1. Linux File System Hierarchy — the "map" of a Linux system

In Linux, **everything starts from one single root folder**, written as `/`. Unlike Windows (which has separate drives like `C:`, `D:`), Linux has just one tree, and every single file/folder — no matter which disk it physically lives on — hangs somewhere under this one root `/`.

```
top ---> /  (root directory)
```

**Sample output — what you actually see at the root of a real EC2 server:**
```
$ cd /
$ ll
total 32
lrwxrwxrwx.   1 root root     7 Jan 30  2023 bin -> usr/bin
dr-xr-xr-x.   5 root root 16384 Aug 12 03:10 boot
drwxr-xr-x.  14 root root  3100 Aug 19 14:09 dev
drwxr-xr-x.  76 root root 16384 Aug 19 14:25 etc
drwxr-xr-x.   5 root root    48 Aug 19 14:25 home
lrwxrwxrwx.   1 root root     7 Jan 30  2023 lib -> usr/lib
lrwxrwxrwx.   1 root root     9 Jan 30  2023 lib64 -> usr/lib64
drwxr-xr-x.   2 root root     6 Jan 30  2023 media
drwxr-xr-x.   2 root root     6 Jan 30  2023 mnt
drwxr-xr-x.   2 root root     6 Aug 19 14:31 opt
dr-xr-xr-x. 120 root root     0 Aug 19 14:09 proc
dr-xr-x---.   3 root root   124 Aug 19 14:25 root
drwxr-xr-x.  28 root root   840 Aug 19 14:09 run
lrwxrwxrwx.   1 root root     8 Jan 30  2023 sbin -> usr/sbin
drwxr-xr-x.   2 root root     6 Jan 30  2023 srv
dr-xr-xr-x.  13 root root     0 Aug 19 14:09 sys
drwxrwxrwt.  11 root root   220 Aug 19 14:31 tmp
drwxr-xr-x.  12 root root   144 Aug 12 03:08 usr
drwxr-xr-x.  19 root root   266 Aug 19 14:09 var
```

**What each folder is for:**

| Folder | Purpose |
|---|---|
| `bin` | commands like `ls`, `cat`, etc. (symlinked to `usr/bin`) |
| `boot` | files needed to boot up the system |
| `dev` | device files — hard disks, USB, etc. |
| `etc` | system-wide configuration files |
| `home` | personal folders for each user |
| `lib`, `lib64` | shared libraries needed by programs |
| `media`, `mnt` | mount points for external/removable drives |
| `opt` | optional/third-party software |
| `proc` | live information about running processes |
| `root` | home directory of the root user specifically |
| `run` | runtime data for currently running processes |
| `sbin` | admin-only commands |
| `srv` | data for services running on this server |
| `sys` | kernel and hardware info |
| `tmp` | temporary files, cleared periodically |
| `usr` | user programs and files — the biggest folder |
| `var` | variable data — logs, mail, spool files, etc. |

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

**Sample output:**
```
$ yum install tree -y
Installed:
  tree-1.8.0-10.amzn2.0.1.x86_64

Complete!
```

**Real-time example:** You'll use `yum install` (or `apt install` on Ubuntu/Debian) to set up almost every tool you need on a fresh server — Java, Git, Docker, Jenkins, Ansible. It's usually one of the very first commands run on any brand-new EC2 instance, right after connecting to it, before installing your actual DevOps toolchain on top.

**More examples:**
- `yum install -y docker` — the `-y` flag auto-confirms the install, which is essential inside automation scripts, since nobody is sitting there to type "y" manually.
- `yum list installed | grep java` — checking whether a package is already installed before trying to install it again.
- `yum remove <pkg>` — the opposite command, used to uninstall old/unused software from a server during cleanup.

---

## 3. Vi/Vim — navigation and editing commands (going beyond `i`, `Esc`, `:wq`)

On 17 August we learned just enough vim to survive — insert mode, save, quit. Today we went a level deeper into vim's actual **navigation and editing** commands, which is where vim genuinely becomes faster than a normal editor once your fingers get used to it. All of these are typed in **Normal mode** — press `Esc` first, since typing them in Insert mode would just type those letters into the file as text.

| Command | Action |
|---|---|
| `gg` | Jump to the top (first line) of the file |
| `G` | Jump to the bottom (last line) of the file |
| `yy` | Copy (yank) the current line |
| `n` + `yy` | Copy `n` lines — e.g. `3yy` copies 3 lines starting from the cursor |
| `p` | Paste after the cursor — pastes whatever was last yanked or deleted |
| `dd` | Delete (cut) the current line — it also gets copied, so `p` can paste it elsewhere |
| `n` + `dd` | Delete `n` lines — e.g. `3dd` deletes 3 lines |
| `u` | Undo the last change |
| `dw` | Delete a single word |
| `:set nu` | Show line numbers on the left |
| `:set nonu` | Hide line numbers again |
| `/pattern` | Search forward for `pattern` — e.g. `/madhu`, `/touch`, `/useradd` |
| `n` (after a search) | Jump to the next occurrence of the last search |

**Sample output — searching inside a file:**
```
$ vim notes.txt

:set nu
  1 useradd madhu
  2 passwd madhu
  3 touch mcfile
  4 su - madhu
  5 userdel madhu

/madhu
  1 useradd madhu    <-- cursor jumps here (first match)

n
  4 su - madhu        <-- next match

n
  5 userdel madhu     <-- next match after that
```

**Sample output — copying and moving a line:**
```
Before (cursor on line 2):
  1 line one
  2 line two
  3 line three

yy      → copies "line two"
G       → jump to last line
p       → pastes "line two" after it

After:
  1 line one
  2 line two
  3 line three
  4 line two
```

**Real-time example:** This is exactly the kind of thing you'll do constantly while editing a `Jenkinsfile` or a Kubernetes YAML manifest directly over SSH. Say a Jenkinsfile has 200 lines and you need to check a `stage` block near the bottom — instead of scrolling line by line, `G` jumps you straight to the end, `gg` jumps you straight back to the top. If your teammate says "there's a typo in the line with `useradd`," `/useradd` finds it instantly instead of you eyeballing the whole file. And `dd` + `p` is exactly how you move a line up or down in a YAML file — cut the line with `dd`, move the cursor, paste it back with `p`.

**More examples:**
- `:set nu` before reporting a bug to a teammate — so you can say "the problem is on line 42" instead of "somewhere in the middle of the file."
- `5dd` — deleting 5 lines in one shot, e.g. removing an old, unused block of environment variables from a config file.
- `/ERROR` inside a large log file opened in vim, to jump straight to the first occurrence of "ERROR" instead of scrolling through hundreds of lines.

---

## 4. Creating nested folders in one shot: `mkdir -p`

```
mkdir -p a/b/c/d/e
```
Normally, `mkdir` can only create one folder at a time, and it fails if the parent folder doesn't exist yet. The `-p` flag (**parents**) tells Linux: "create every folder in this path that doesn't already exist, all in one go."

**Sample output:**
```
$ mkdir -p a/b/c/d/e
$ tree a
a
└── b
    └── c
        └── d
            └── e

4 directories, 0 files
```
All four missing parent folders (`b`, `c`, `d`, `e`) got created in one shot, without a single "no such file or directory" error.

**Real-time example:** This is exactly how you'd set up a standard deployment folder structure on a new server in a single command — for example, `mkdir -p /opt/myapp/releases/current`. Deployment scripts use `mkdir -p` constantly so they don't fail just because a parent folder happens to be missing on a fresh server.

**More examples:**
- `mkdir -p /opt/app/{logs,config,releases}` — creating multiple subfolders for a new application setup, all in one shot.
- `mkdir -p ~/backups/$(date +%Y-%m-%d)` — auto-creating a dated backup folder inside a script, without worrying whether the parent `backups` folder already exists.
- Used at the start of almost every install/setup script, to guarantee the target folder structure exists before copying any files into it.

---

## 5. Copying and moving files: `cp -rp` and `mv`

```
cp -rp src.path dest.path
```
`cp` **copies** a file or folder. `-r` means recursive (copy folders and everything inside them too), `-p` means preserve (keep the original permissions, ownership, and timestamps on the copy, instead of resetting them).

**Sample output:**
```
$ cp -rp test a/b/c/test
$ tree a
a
└── b
    └── c
        └── test

2 directories, 0 files
```

```
mv src dest
```
`mv` **moves** a file or folder to a new location — or, if the destination is just a new name in the same folder, it effectively **renames** it. Unlike `cp`, the original is gone from its old location after `mv`.

**Sample output:**
```
$ ls
f2  file2  test

$ mv f2 file2
$ ls
file2  test
```
Notice `f2` disappeared from the listing — `mv` renamed it to `file2` in place, overwriting the old empty `file2`. There's only ever **one** copy after `mv`, unlike `cp`.

**Real-time example:** Before overwriting a config file during a deployment, a careful DevOps engineer always takes a backup first: `cp -rp app.properties app.properties.bak` — the `-p` matters here because it preserves the original timestamp, which is exactly what you need when comparing "what changed and when" during an incident review. `mv` is used in real deployments to swap in a new application version with minimal downtime — build the new release in a temp folder, then `mv` it into the live `current` folder (or symlink) in one atomic step, which is the basic idea behind blue-green style deployments.

**More examples:**
- `cp -rp /opt/app/current /opt/app/backup_before_upgrade` — taking a full backup of a live application folder before attempting a risky upgrade.
- `cp -rp ~/.ssh/id_rsa ~/.ssh/id_rsa.bak` — backing up an SSH key before regenerating or modifying it, just in case.
- `mv app-v2.war app.war` — renaming a freshly built artifact to the exact filename Tomcat expects, so it gets auto-deployed correctly.
- `mv old_config.yaml old_config.yaml.old` — a quick way to "disable" a config file by renaming it, without actually deleting it, in case you need to roll back.

---

## 6. Downloading files from the internet: `wget`

```
wget <link>

wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.121/bin/apache-tomcat-9.0.121.zip
```
`wget` **downloads a file directly from a URL** onto your server — no browser needed, works purely from the command line. This is extremely useful on servers, since servers usually don't have a graphical browser at all.

**Sample output:**
```
$ wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.121/bin/apache-tomcat-9.0.121.zip
--2026-08-19 14:31:02--  https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.121/bin/apache-tomcat-9.0.121.zip
Resolving dlcdn.apache.org... 151.101.2.132
Connecting to dlcdn.apache.org|151.101.2.132|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 11816598 (11M) [application/zip]
Saving to: 'apache-tomcat-9.0.121.zip'

apache-tomcat-9.0.121.zip   100%[=================================>]  11.27M  8.42MB/s    in 1.3s

2026-08-19 14:31:04 (8.42 MB/s) - 'apache-tomcat-9.0.121.zip' saved [11816598/11816598]
```

**Real-time example:** This is exactly how we downloaded Apache Tomcat onto our EC2 server, and it's the same pattern you'll use to pull any installer, binary, or artifact directly onto a headless server — a specific JDK version, a Jenkins WAR file, a Maven binary, or even an application build artifact copied from an S3 bucket URL.

**More examples:**
- `wget -O jdk.tar.gz <url>` — downloading a file but saving it under a custom filename using `-O`, instead of whatever name the URL gives it.
- `wget -q <url>` — quiet mode, useful inside automation scripts where you don't want the download progress bar cluttering up your pipeline logs.
- `wget <url> -P /opt/downloads` — downloading straight into a specific target folder, instead of wherever you currently happen to be standing.

---

## 7. Compressing and extracting files: zip/unzip and tar

### zip / unzip

```
unzip apache-tomcat-9.0.121.zip
```
**Extracts** (unpacks) the contents of a `.zip` file into the current folder.

**Sample output:**
```
$ unzip apache-tomcat-9.0.121.zip
Archive:  apache-tomcat-9.0.121.zip
   creating: apache-tomcat-9.0.121/
   creating: apache-tomcat-9.0.121/bin/
  inflating: apache-tomcat-9.0.121/bin/catalina.sh
  ...
$ ls
apache-tomcat-9.0.121  apache-tomcat-9.0.121.zip
```

```
zip -r devopskeys.zip devopskeys
```
**Compresses** a folder (here, `devopskeys`) into a single `.zip` file. `-r` means recursive — include all the files and subfolders inside it, not just the top-level folder itself.

**Sample output:**
```
$ zip -r devopskeys.zip devopskeys
  adding: devopskeys/ (stored 0%)
  adding: devopskeys/id_rsa (deflated 22%)
  adding: devopskeys/id_rsa.pub (deflated 18%)
$ ls
devopskeys  devopskeys.zip
```

**Real-time example:** In real projects, build tools like Maven package your entire application into a single deployable file (a `.war` or `.jar`) — a very similar idea to zipping. On the server side, you often need to `unzip`/extract an artifact that was copied over from a CI/CD pipeline before actually deploying it to Tomcat.

**More examples:**
- `unzip -l file.zip` — lists the contents of a zip file first, **without** extracting it, so you can check what's inside before unpacking.
- `unzip file.zip -d /opt/app` — extracts directly into a specific target folder using `-d`, instead of dumping everything into the current folder.
- `zip -r backup.zip /opt/app/config` — zipping up just the config folder for a quick backup/sharing, instead of the entire application.

### tar — the other common compression format

```
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.121/bin/apache-tomcat-9.0.121.tar.gz

tar -xvf apache-tomcat-9.0.121.tar.gz
```
`tar` is another, very common way to package/extract files on Linux (short for "tape archive," from its old backup-tape days). `-x` means extract, `-v` means verbose (show each file as it's being extracted, so you can see progress), `-f` means the next argument is the filename to work on.

**Sample output:**
```
$ tar -xvf apache-tomcat-9.0.121.tar.gz
apache-tomcat-9.0.121/
apache-tomcat-9.0.121/bin/
apache-tomcat-9.0.121/bin/catalina.sh
apache-tomcat-9.0.121/conf/
apache-tomcat-9.0.121/conf/server.xml
...
$ ls
apache-tomcat-9.0.121  apache-tomcat-9.0.121.tar.gz
```

```
tar -cvf tomcat.tar.gz apache-tomcat-9.0.121
```
Here `-c` means **create** a new archive (instead of extracting), packing the `apache-tomcat-9.0.121` folder into `tomcat.tar.gz`. `-v` and `-f` mean the same as above.

**Sample output:**
```
$ tar -cvf tomcat.tar.gz apache-tomcat-9.0.121
apache-tomcat-9.0.121/
apache-tomcat-9.0.121/bin/
apache-tomcat-9.0.121/bin/catalina.sh
...
$ ls
apache-tomcat-9.0.121  tomcat.tar.gz
```

**Real-time example:** This is precisely how we prepared Tomcat for use in a real project: download it as `.tar.gz`, extract it with `tar -xvf` into `/opt`. Later, if you need to move that installed application to another server, or take a backup before an upgrade, you'd package it back up with `tar -cvf`. In real DevOps work, `.tar.gz` is what you'll see used to distribute almost every open-source tool you install — Tomcat, Maven, Jenkins agents, Prometheus, and more.

**More examples:**
- `tar -tvf file.tar.gz` — lists the contents of a tar archive **without** extracting it, so you can check what's inside first, same idea as `unzip -l`.
- `tar -xvf file.tar.gz -C /opt` — extracts directly into a specific target folder using `-C`, instead of the current directory.
- `tar -czvf backup.tar.gz /opt/app` — the extra `z` flag adds gzip compression while creating the archive, giving you a smaller file than a plain `-cvf`.

**Quick memory trick:** think of `tar -x` as "e**X**tract" and `tar -c` as "**C**reate" — the letter itself hints at what it does.

---

## Quick Recap Table

| Command | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `/` (root) | The single top-level folder everything lives under | `/var/log` for logs, `/opt` for installed software, `/etc` for configs |
| Absolute path | Full address, works from anywhere | Always use in Jenkins pipelines/cron jobs to avoid path bugs |
| Relative path | Address relative to where you stand now | Works fine manually, but can silently fail inside a pipeline job |
| `yum install <pkg>` | Installs software from the internet | First command run on a fresh EC2 instance — installing Java, Git, Docker |
| `gg` / `G` | Jump to top / bottom of file in vim | Jumping to the end of a long Jenkinsfile instead of scrolling |
| `yy` / `dd` / `p` | Copy / cut / paste a line in vim | Moving a line up/down in a YAML manifest |
| `/pattern` + `n` | Search a file in vim, jump to next match | Finding `useradd` or `ERROR` instantly in a large file |
| `mkdir -p a/b/c` | Creates nested folders in one shot | Deployment scripts creating `/opt/myapp/releases/current` in one go |
| `cp -rp` | Copies files/folders, keeping original details | Backing up a config file before overwriting it during a deployment |
| `mv` | Moves or renames a file/folder | Swapping in a new release folder with minimal downtime |
| `wget <url>` | Downloads a file from the internet | Pulling Tomcat, a JDK, or a build artifact onto a headless server |
| `zip -r` / `unzip` | Compress / extract a `.zip` archive | Extracting a CI/CD build artifact before deploying it to Tomcat |
| `tar -cvf` / `tar -xvf` | Create / extract a `.tar` archive | Installing Tomcat/Maven/Jenkins agents, distributed as `.tar.gz` |

That's today's session, friends — file system hierarchy plus copy/move/compress commands are things you will use in almost every single real DevOps task, from installing Tomcat to deploying application code. Practice these with your own hands, not just by reading.
