# Batch 18 — Linux Running Notes: 17 August 2026

**Topic: Server Info Commands, User Management, File Exploration, vi/vim Editor**

Friends, today's class had two big parts — first, checking useful information *about* our server (like how much memory it has), and second, creating and managing **users** on Linux, which is a very important real-world admin skill. We also explored a few handy commands for peeking inside files, and got our first proper hands-on with the `vi`/`vim` editor.

---

## 1. Server information commands

After logging in and switching to root (`sudo su -`), and renaming the server (`hostnamectl set-hostname <ser-name>`), we checked some basic server details:

```
hostname
hostname -I
```
`hostname` shows the server's name. `hostname -I` shows the server's **IP address** — the unique address that identifies this machine on the network.

**Real-time example:** `hostname` is like the server's nickname; `hostname -I` is like its actual home address — you need the address if you want to actually go visit (connect to) it from somewhere else.

```
uptime
```
Shows **how long the server has been running** without a restart, along with current time, number of logged-in users, and system load. A server with high uptime is generally a sign of stability.

```
uname
uname -a
```
Already covered on 14 Aug — shows the OS kernel name and, with `-a`, full system details in one shot.

```
lscpu
```
Shows detailed information about the server's **CPU** — how many cores, architecture, speed, and more.

```
free
free -m
free -g
```
Shows how much **RAM (memory)** is being used and how much is free. `free -m` shows the numbers in megabytes, `free -g` shows them in gigabytes — much easier to read than the default raw bytes.

**Real-time example:** `free -m` is exactly like checking how much storage is left on your phone before installing a new app — except here we're checking memory (RAM) instead of storage, to make sure the server has enough "working space" to run applications smoothly.

---

## 2. User management — creating and managing Linux users

On a real server, multiple people might need their own login — just like a shared office computer where every employee has their own Windows account.

```
useradd madhu
```
Creates a **new user** called `madhu` on the system.

```
passwd madhu
```
Sets (or resets) the **password** for that user.

```
su - madhu
```
**Switches** from the current user (probably root) to the user `madhu` — as if madhu themselves logged in.

```
whoami
```
Confirms who you're currently logged in as — after `su - madhu`, this correctly shows `madhu`.

```
exit
```
Logs out of the current user session, taking you back to whoever you were before (e.g., back to root).

**Real-time example:** Think of a Linux server like one big shared apartment building. `useradd` is like registering a new tenant's name at the building entrance. `passwd` is like giving them their own door key. `su - madhu` is like temporarily walking into madhu's own flat and looking around as if you were madhu. `whoami` is just double-checking "wait, whose flat am I standing in right now?"

### Where does a user's data live?

**User home directory:** `/home/<username>` — every user gets their own personal folder here, just like every tenant gets their own flat.

### `/etc/passwd` — the master list of all users

```
cat /etc/passwd
```
This file contains the **list of all user accounts** on the system, one line per user, in this format:
```
ec2-user:x:1000:1000:EC2 Default User:/home/ec2-user:/bin/bash
madhu:x:1001:1001::/home/madhu:/bin/bash
```
Each line tells you: username, a placeholder for password (`x`, actual password is stored securely elsewhere in `/etc/shadow`), user ID, group ID, description, home directory, and default shell.

**Real-time example:** `/etc/passwd` is like the building's official tenant registry — it lists every tenant's name, their flat number, and other basic details, all in one place, so the building manager (the system) always knows exactly who lives where.

### Modifying and removing users

```
usermod -c "DevOps User" madhu
```
`usermod` **modifies** an existing user's settings — here, `-c` sets a **comment/description** ("DevOps User") next to madhu's entry in `/etc/passwd`. Useful for noting a person's role or full name.

```
userdel -r kiran
```
**Deletes** the user `kiran` completely. The `-r` flag also removes their home directory and all their personal files — without `-r`, the user account is removed but their files would still remain behind.

**Real-time example:** `usermod -c` is like updating a tenant's file with their job title, for easy reference later. `userdel -r` is like a tenant permanently moving out — you cancel their registration *and* clear out their flat completely, versus just cancelling the registration and leaving their old stuff lying around.

---

## 3. Peeking inside files — wc, tail, head, more

```
wc /etc/passwd
wc -l
wc -w
wc -c
```
`wc` stands for **word count**, and by default shows lines, words, and characters (bytes) in a file. `-l` shows only the **line count**, `-w` only the **word count**, `-c` only the **character/byte count**.

**Real-time example:** If someone asks "how many users are on this server," instead of manually counting every line in `/etc/passwd`, you simply run `wc -l /etc/passwd` — instant answer, no manual counting.

```
tail -n 3 /etc/passwd
```
Shows only the **last 3 lines** of the file — very useful when a file is huge and you only care about the most recent entries (like the most recently added users, or the latest log entries).

```
head -n 2 /etc/passwd
```
Shows only the **first 2 lines** of the file — opposite of `tail`.

```
more /etc/passwd
```
Displays the file content **page by page**, letting you scroll through a long file bit by bit, instead of it all flooding your screen at once (like `cat` does).

**Real-time example:** Imagine a very long WhatsApp group chat. `cat` is like scrolling all the way from message 1 to the latest message in one continuous dump — overwhelming for a huge chat. `tail` is like jumping straight to the most recent messages. `head` is like reading only the very first messages when the group was created. `more` is like reading the chat comfortably, one screen at a time, at your own pace.

---

## 4. File creation, and the `vi`/`vim`/`nano` editor

```
touch fname
```
Creates a new empty file.

```
echo "get ready to workhard" > b18file
```
`echo` prints text — and the `>` symbol **redirects** that text into a file, **overwriting** whatever was there before (or creating the file fresh if it didn't exist).

```
echo "adding new content" >> b18file
```
The **double** `>>` also redirects text into a file, but it **appends** (adds to the end) instead of overwriting — the existing content stays safe, and the new line gets added below it.

**Real-time example:** Single `>` is like erasing a whiteboard completely and writing a fresh line. Double `>>` is like just adding a new line below whatever is already written on the whiteboard, without erasing anything.

### vi / vim / nano — text editors inside the terminal

These are all **text editors that run directly inside your terminal** — no separate app window needed, unlike Notepad. `vim` is an improved version of the older `vi`; `nano` is a simpler, beginner-friendly alternative.

```
vim fname
```
Opens (or creates, if it doesn't exist) the file `fname` inside the vim editor.

```
Esc, then i          → enters Insert mode (now you can type)
   ----- data ----
   ----- data ----
Esc                  → leaves Insert mode, back to Normal/Command mode
:w                    → write/save the file
:q                    → quit the editor
:wq!                  → save and quit, forcefully (even overriding read-only warnings)
```

**Real-time example:** Vim always opens in "Command mode" by default — meaning if you start typing immediately, nothing appears on screen, and instead your keystrokes are treated as commands (which can be confusing the first time!). You must press `i` first to enter "Insert mode" before typing your actual content — exactly like a locked phone screen: you need to unlock it (press `i`) before you can start typing a message; pressing `Esc` locks it again, and `:wq` is like tapping "Save" before closing the app.

```
date
```
Simply prints the current date and time of the server.

---

## Quick Recap Table

| Command | One-line meaning | Real-time analogy |
|---|---|---|
| `hostname -I` | Shows server's IP address | The server's home address |
| `free -m` / `-g` | Shows RAM usage in MB/GB | Checking free storage on your phone |
| `useradd` | Creates a new user | Registering a new tenant |
| `passwd` | Sets/resets a user's password | Giving them a door key |
| `su - <user>` | Switch to that user's session | Walking into their flat as them |
| `/etc/passwd` | Master list of all users | Building's tenant registry |
| `usermod -c` | Add a description/comment to a user | Updating tenant's file with job title |
| `userdel -r` | Delete user AND their home folder | Tenant moving out, flat cleared too |
| `wc -l` | Count lines in a file | Counting entries without manual counting |
| `tail -n` | Show last N lines of a file | Jumping to most recent chat messages |
| `head -n` | Show first N lines of a file | Reading the very first messages |
| `more` | View a file page by page | Reading chat comfortably, screen by screen |
| `echo "text" > file` | Overwrite file with text | Erasing whiteboard, writing fresh |
| `echo "text" >> file` | Append text to end of file | Adding a new line, nothing erased |
| `vim fname` | Open/create file in vim editor | Opening a note-taking app |
| `i` / `Esc` / `:wq` | Insert mode / back to command / save & quit | Unlock, type, lock, save |

That's today's session, friends — user management and file exploration are things you'll use almost every single day as a Linux admin, so make sure to practice these hands-on, not just read them.
