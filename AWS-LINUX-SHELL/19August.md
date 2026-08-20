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

**Real-time example:** Think of Linux's file system like a big company building. `/` is the main entrance/ground floor. `/home` is like individual employee cabins — everyone gets their own space. `/etc` is like the admin office holding all the official configuration papers/rules for how the building runs. `/tmp` is like a shared photocopy room — people dump stuff there temporarily, and it gets cleaned out regularly. `/var` is like the building's logbook/register — constantly changing, recording ongoing activity. `/bin` and `/sbin` are like toolboxes — `/bin` tools anyone can use, `/sbin` tools only the building manager (root/admin) is meant to use.

### Absolute path vs Relative path

- **Absolute path** — the *full* address starting from root, e.g. `/opt/a/b/c`. It always works, no matter where you currently are.
- **Relative path** — the address *relative to where you currently are*, e.g. `cd b/c` (only works correctly if you're already inside the right starting folder).

**Real-time example:** An absolute path is like giving someone your full postal address (house no., street, city, pincode) — they can find you from *anywhere* in the world. A relative path is like saying "take the second left from here" — that direction only makes sense if the person is already standing at the same starting point as you.

---

## 2. Installing software with `yum`

```
yum install <pkg>
```
`yum` is the **package manager** for RHEL/Amazon Linux/CentOS-based systems — it downloads and installs software packages directly from the internet, handling all the setup for you.

**Real-time example:** `yum install tree` is exactly like searching an app on the Play Store and tapping "Install" — you don't need to manually download files and configure anything yourself; the package manager does all the heavy lifting.

---

## 3. Creating nested folders in one shot: `mkdir -p`

```
mkdir -p a/b/c/d/e
```
Normally, `mkdir` can only create one folder at a time, and it fails if the parent folder doesn't exist yet. The `-p` flag (**parents**) tells Linux: "create every folder in this path that doesn't already exist, all in one go."

**Real-time example:** Without `-p`, trying to create `a/b/c/d/e` directly would fail with "no such file or directory" if `a`, `b`, `c`, `d` don't already exist — like trying to place a letter in "Floor 5, Room 3" of a building that doesn't have Floor 5 built yet. `mkdir -p` is like saying "build floors 1 through 5, and room 3 on floor 5, all in one instruction" — no manual step-by-step folder creation needed.

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

**Real-time example:** `cp -rp` is like photocopying an entire file folder, including all the documents inside, and keeping the exact same staple marks, sticky notes, and dates as the original — the original stays where it was, you now just have two identical copies. `mv` is like physically picking up that same folder and walking it to a different shelf (or writing a new name on its spine) — there's still only **one** copy, just in a new place or with a new name.

---

## 5. Downloading files from the internet: `wget`

```
wget <link>

wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.121/bin/apache-tomcat-9.0.121.zip
```
`wget` **downloads a file directly from a URL** onto your server — no browser needed, works purely from the command line. This is extremely useful on servers, since servers usually don't have a graphical browser at all.

**Real-time example:** `wget` is exactly like pasting a download link into your browser and clicking download — except here, there's no browser at all, just the terminal doing the downloading directly onto the server, which is exactly how we downloaded Apache Tomcat onto our EC2 server.

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

**Real-time example:** `zip -r` is like packing an entire suitcase (folder, with everything inside it) into one sealed package for easy shipping. `unzip` is like opening that package back up at the destination and taking everything out again.

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

**Real-time example:** `.zip` and `.tar.gz` are basically two different "packaging styles" for the same purpose — like choosing between a cardboard box and a vacuum-sealed bag to pack the same suitcase. On Linux servers, `.tar.gz` is far more common than `.zip`, so it's worth being comfortable with both `tar -xvf` (unpack) and `tar -cvf` (pack).

**Quick memory trick:** think of `tar -x` as "e**X**tract" and `tar -c` as "**C**reate" — the letter itself hints at what it does.

---

## Quick Recap Table

| Command | One-line meaning | Real-time analogy |
|---|---|---|
| `/` (root) | The single top-level folder everything lives under | Ground floor / main entrance of a building |
| Absolute path | Full address, works from anywhere | Your complete postal address |
| Relative path | Address relative to where you stand now | "Take the second left from here" |
| `yum install <pkg>` | Installs software from the internet | Installing an app from the Play Store |
| `mkdir -p a/b/c` | Creates nested folders in one shot | Building all the floors of a building at once |
| `cp -rp` | Copies files/folders, keeping original details | Photocopying a folder, staples and all |
| `mv` | Moves or renames a file/folder | Physically shifting a folder to a new shelf |
| `wget <url>` | Downloads a file from the internet | Clicking "Download" without needing a browser |
| `zip -r` / `unzip` | Compress / extract a `.zip` archive | Packing/unpacking a sealed suitcase |
| `tar -cvf` / `tar -xvf` | Create / extract a `.tar` archive | Vacuum-packing/unpacking a suitcase |

That's today's session, friends — file system hierarchy plus copy/move/compress commands are things you will use in almost every single real DevOps task, from installing Tomcat to deploying application code. Practice these with your own hands, not just by reading.
