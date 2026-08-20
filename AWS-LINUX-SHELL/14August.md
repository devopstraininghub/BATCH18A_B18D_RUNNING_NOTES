# Batch 18 — Linux Running Notes: 14 August 2026

**Topic: AWS Free Tier Account Created, First EC2 Server, Basic Identity Commands**

Friends, today was the exciting day — we actually created our AWS Free Tier account and launched our very first server (EC2 instance). Till yesterday it was all theory; from today we start touching real things. Don't worry if it feels new, these are literally the first baby steps everyone takes.

---

## 1. What is an EC2 instance?

**EC2** stands for **Elastic Compute Cloud** — in simple words, it is just a virtual computer/server running inside AWS's datacenter, which you can rent by the hour. Once you launch it, you "connect" into it just like remotely accessing any computer, and then you can run Linux commands on it.

**Real-time example:** Think of EC2 like renting a fully furnished flat instead of building your own house. You don't own the building (AWS owns the actual physical hardware), but you get full access to use "your flat" (your server) however you like — install software, create files, run applications — for as long as you're paying rent for it.

---

## 2. Connecting to the server — first commands

Once you connect to a freshly launched EC2 instance, by default you land as a limited user called `ec2-user`.

```
whoami
```
This tells you **who you are currently logged in as**. Right after connecting, running this shows `ec2-user` — confirming you're not the all-powerful root user yet.

```
sudo su -
```
This command **switches you to the root user** — the "superuser" who has full permissions to do anything on the server (install software, create users, change system files, etc.). `sudo` means "do this as superuser," and `su -` means "switch user" (to root, by default, with a fresh login environment).

**Real-time example:** `ec2-user` is like being a guest in someone's house — you can sit, eat, watch TV, but you can't rearrange the furniture or repaint the walls. `sudo su -` is like the house owner handing you the master key — now you can do literally anything in that house, including things that could break it if you're careless. That's exactly why root access must be used carefully.

```
hostnamectl set-hostname linux
```
This command **renames your server** to something meaningful — here, `linux`. By default, AWS gives long, hard-to-remember auto-generated hostnames; renaming it to something short and clear (like `linux`, or later `b18linux`) makes it much easier to identify, especially when you're managing multiple servers.

**Real-time example:** Think of this exactly like naming your WiFi router "MyHomeWiFi" instead of leaving it as the factory default "TP-LINK_5G_8821" — much easier for everyone to recognize which one is which.

```
exit
```
This **logs you out of the current session** — for example, exiting out of root back to `ec2-user`, or exiting the server connection entirely, depending on where you run it.

```
sudo su -
```
We switch to root again, since after renaming the hostname, the change often needs a fresh shell session to fully reflect.

```
hostname
```
This simply **prints the current hostname** of the server — a quick way to confirm your `hostnamectl set-hostname` command actually worked.

```
uname
uname -a
```
`uname` prints the **name of the operating system kernel** (typically shows `Linux`). `uname -a` prints **all** the system information in one shot — kernel name, hostname, kernel version, architecture (like x86_64), and more.

**Real-time example:** `uname -a` is like checking your phone's "About Phone" settings page — one screen that tells you the OS version, model number, and build details all together, instead of hunting for each piece of information separately.

---

## 3. Practicing basic Linux commands on Windows (via Git Bash)

Since not everyone has an EC2 server running all the time, we also practiced the same basic commands using **Git Bash** on our Windows laptops — Git Bash gives you a Linux-style terminal experience even on Windows.

```
pwd
```
"Print working directory" — shows you exactly which folder you are standing in right now.

```
ls
ll
ls -lrth
```
- `ls` — lists files and folders in the current directory.
- `ll` — same, but with extra details: permissions, owner, size, and modified date.
- `ls -lrth` — long listing (`l`), reverse order (`r`), human-readable sizes like KB/MB instead of raw bytes (`h`), sorted by modification time (`t`) — so your most recently touched files show up last, easy to spot.

**Real-time example:** `ls` is like glancing into a room and seeing what's kept there. `ll` is like actually picking up each item and checking the label — size, date bought, etc. `ls -lrth` is like arranging that same room so the newest items are right in front of you.

```
touch file1 file2 file3
```
Creates three empty files in one shot — `touch` is normally used to create a new, blank file (or update its "last modified" time if it already exists).

```
mkdir dir1 dir2 dir3
```
Creates three empty folders (directories) in one shot.

```
clear
```
(or **Ctrl + L**) — clears everything on your screen, giving you a fresh, clean terminal view. It doesn't delete any files — just cleans up the *display*.

```
rm -rf fname/dir
```
**Deletes** a file or folder — `r` means recursive (go inside folders and delete everything inside too), `f` means force (don't ask for confirmation, just do it).

⚠️ **Important:** There is **no undo** for `rm -rf`. Once you run it, that file/folder is gone permanently — no recycle bin, no "restore" option like Windows. Always double, triple check the name before hitting Enter.

**Real-time example:** `rm -rf` is like shredding a document instead of putting it in the dustbin — once shredded, there is no getting it back. This is why experienced Linux users always run `ls` first to double-check exactly what they're about to delete, before running `rm -rf`.

```
cat fname
```
Prints the **entire content** of a file directly on the screen — like opening a file and reading everything written inside it.

```
cd <dirname>
cd ..
```
- `cd dirname` — moves you **into** that folder.
- `cd ..` — moves you **out**, one level up (to the parent folder).

```
history
```
Shows you the **list of all commands you've typed** recently in this terminal session — very useful for scrolling back and re-checking exactly what you did.

**Real-time example:** Think of `history` like your phone's call log — instead of trying to remember "what number did I dial 10 minutes ago," you just scroll back and see the exact record.

---

## Quick Recap Table

| Command | One-line meaning | Real-time analogy |
|---|---|---|
| `whoami` | Shows current logged-in user | Checking your own ID badge |
| `sudo su -` | Switch to root (superuser) | Getting the master key to the house |
| `hostnamectl set-hostname` | Rename the server | Naming your WiFi router |
| `uname -a` | Show full OS/kernel info | Phone's "About Phone" screen |
| `pwd` | Show current folder location | "Which room am I in right now" |
| `ls` / `ll` | List files/folders (with details) | Looking around a room |
| `touch` | Create empty file(s) | Placing a fresh blank sheet of paper |
| `mkdir` | Create folder(s) | Setting up new empty drawers |
| `rm -rf` | Permanently delete file/folder | Shredding a document — no undo |
| `cat` | Print full file content on screen | Reading a letter out loud |
| `cd` | Move into/out of a folder | Walking into/out of a room |
| `history` | Show recently typed commands | Your phone's call log |

That's today's session, friends — we now have our own live AWS server, and we know the basic commands to move around on it confidently. Next class, we go deeper into user management and file exploration.
