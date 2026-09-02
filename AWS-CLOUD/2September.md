# Batch 18 — AWS Cloud Running Notes: 2 September 2026

**Topic: A Few More EC2 Commands (`lsblk`, `df -Th`), Regions/AZs Recap, EBS (Elastic Block Store) — Volumes, Mounting, Moving Between Servers, Snapshots**

Friends, yesterday we launched our very first EC2 instance and ran a few basic commands on it. Today we look at how to identify the disks attached to a server, revisit the EC2 create/connect flow hands-on, and then get into **EBS (Elastic Block Store)** — the actual disk storage behind every EC2 instance, including how to set one up, move it between servers, and back it up with snapshots.

---

## 1. A few more commands on your EC2 instance

- **`sudo su -`** — switch to the root user with full access (same as day 1 — you'll use this constantly).
- **`hostnamectl set-hostname serv.name`** — permanently renames the server. Example: `hostnamectl set-hostname serv.name` changes the machine's hostname to `serv.name`, and it stays that way even after a reboot.
- **`lsblk`** — **L**i**s**t **Bl**oc**k** devices. Shows every disk and partition attached to the server, and where each one is mounted (if at all).
- **`df -Th`** — checks disk space, same `df` we already know, with two flags together:
  - `-T` — also show the **filesystem type** (like `ext4` or `xfs`) for each disk.
  - `-h` — human-readable sizes (GB/MB instead of raw numbers).
- **`touch file1 file2`** / **`mkdir dir1 dir2`** / **`cd dirname`** — the same file/folder commands from yesterday, just more practice.

**Sample output:**
```
$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
nvme0n1     259:0    0    8G  0 disk
└─nvme0n1p1 259:1    0    8G  0 part /
nvme1n1     259:2    0   10G  0 disk

$ df -Th
Filesystem      Type  Size  Used Avail Use% Mounted on
/dev/nvme0n1p1  xfs   8.0G  1.6G  6.5G  20% /
```
Notice `nvme1n1` shows up in `lsblk` with **no** mount point — that's a second disk attached to this EC2 instance that isn't usable yet. That's exactly the EBS volume we'll set up in section 3.

**Real-time example:** `lsblk` and `df -Th` together are the first two commands a DevOps engineer runs when told "we've attached extra storage to this server" — `lsblk` confirms the new disk is visible to the OS at all, `df -Th` confirms whether it's actually formatted and mounted somewhere usable yet.

**Easy memory trick:** `lsblk` → "what disks does this server even have?" `df -Th` → "which of those disks are actually usable, and what type?"

---

## 2. Quick recap — Regions, AZs, and the EC2 create/connect flow

Today's class also revisited two practical skills hands-on, building on yesterday's Region/Availability Zone concepts:
- **How to create your EC2 instance** — choosing an AMI, instance type, and key pair.
- **How to connect to your EC2 instance** — SSH, using the `.pem` key from that instance.

If either of these still feels unfamiliar, that's expected on day 2 — repetition is exactly how this becomes second nature.

---

## 3. What is EBS (Elastic Block Store)?

- **EBS** stands for **E**lastic **B**lock **S**tore.
- It's a **block-level storage volume** used with EC2 — works like a virtual hard disk you attach to an instance.
- **Persistent storage** — data on an EBS volume survives even if the EC2 instance is stopped (this is different from an instance's temporary local storage, which can be lost).

Think of EBS as a portable, durable SSD/HDD that you plug into your EC2 instance.

### Key features

- Persistent storage — data survives a stop/start of the instance.
- High availability — replicated across its Availability Zone automatically.
- Can be **detached** from one EC2 instance and **attached** to another.
- Multiple volume types available (SSD, HDD — see below).
- Supports **snapshots** (backups).
- Encryption available.
- Can be resized anytime — increase size, or change type.

### Types of EBS volumes

| Type | Best for |
|---|---|
| General Purpose SSD (`gp3`/`gp2`) | Most everyday workloads |
| Provisioned IOPS SSD (`io1`/`io2`) | High-performance databases |
| Throughput Optimized HDD (`st1`) | Big data, log processing |
| Cold HDD (`sc1`) | Rarely accessed data |

### How EBS works — the simple flow

1. Launch an EC2 instance.
2. Attach an EBS volume to it.
3. Format and mount it, like a normal hard disk.
4. Store files, databases, logs, etc. on it.
5. Create snapshots of it for backup.

### Real-world use cases

- Data storage for EC2 servers.
- Databases (MySQL, MongoDB, PostgreSQL).
- Application logs.
- General file systems.
- Docker storage.
- Backup and restore, via snapshots.

**Easy memory trick:** EBS → a hard disk you can unplug from one server and plug into another, without losing what's on it.

---

## 4. Setting up an EBS volume — format, mount, and move it to another server

**On Server 1 — a brand-new, unformatted volume:**
```
sudo mkfs -t ext4 /dev/nvme1n1
sudo mkdir /madhu
sudo mount /dev/nvme1n1 /madhu
```
- **`mkfs -t ext4 /dev/nvme1n1`** — **M**a**k**e **F**ile**s**ystem: formats the raw disk `/dev/nvme1n1` with the `ext4` filesystem type, so Linux can actually store files on it. This step **wipes** anything already on the disk — only do this on a genuinely new/empty volume.
- **`mkdir /madhu`** — creates an empty folder to use as the **mount point** — the location in the filesystem tree where the disk will "appear."
- **`mount /dev/nvme1n1 /madhu`** — attaches the formatted disk to that folder. From this point on, anything saved inside `/madhu` is actually being written onto the EBS volume, not the server's own root disk.

**Sample output:**
```
$ sudo mkfs -t ext4 /dev/nvme1n1
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 2621440 4k blocks and 655360 inodes
...

$ sudo mount /dev/nvme1n1 /madhu
$ df -Th | grep madhu
/dev/nvme1n1  ext4  9.8G   24K  9.3G   1% /madhu
```

**On Server 2 — after detaching this same volume from Server 1 and attaching it here instead:**
```
sudo mkdir /madhu
sudo mount /dev/nvme1n1 /madhu
```
Notice **`mkfs` is not run again here** — the disk was already formatted on Server 1, and formatting it again would erase all its data. Server 2 only needs a mount point folder (`mkdir`) and to `mount` the existing, already-formatted disk — all the files that were on it from Server 1 show up immediately.

**Real-time example:** This exact detach-and-reattach pattern is how you'd move a database's data volume to a bigger/different EC2 instance during an upgrade — stop the app, detach the EBS volume, attach it to the new instance, mount it at the same path, start the app. The data itself never has to be copied anywhere, since it lives on the volume, not the instance.

**Easy memory trick:** `mkfs` once per disk, ever — never repeat it on a disk that already has data you want to keep.

---

## 5. Backup — snapshots

- A **snapshot** is a backup of an EBS volume, taken at a point in time.
- Snapshots are stored in **S3** internally by AWS (you don't manage this storage yourself).
- A new EBS volume can be **restored** from a snapshot at any time.
- **Copying a snapshot** — snapshots can be copied, including to a different AWS Region, which is exactly how you'd move a backup for disaster-recovery purposes.

**Used for:**
- Backups.
- Disaster recovery.
- Creating AMIs (a snapshot can become the base image for launching new EC2 instances).

**Real-time example:** Taking a snapshot of a production database's EBS volume every night, and copying that snapshot to a second AWS Region — if the primary Region ever has a major outage, a new volume (and a new EC2 instance) can be restored from that copied snapshot in the other Region.

**Easy memory trick:** Snapshot → a save-point for your disk, that you can rewind to or clone from anytime.

---

## Quick Recap Table

| Command / Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `hostnamectl set-hostname name` | Permanently rename the server | Giving each server a meaningful name instead of a random one |
| `lsblk` | List every disk/partition attached to the server | Confirming a newly attached EBS volume is visible to the OS |
| `df -Th` | Disk space + filesystem type, human-readable | Checking whether a disk is formatted/mounted yet |
| EBS (Elastic Block Store) | Persistent, detachable block storage for EC2 | The actual disk behind a database or app server |
| `mkfs -t ext4 /dev/x` | Format a raw disk with a filesystem | One-time setup of a brand-new EBS volume |
| `mount /dev/x /folder` | Attach a formatted disk to a folder path | Making an EBS volume's storage usable at `/madhu` |
| Detach + reattach an EBS volume | Move a disk (and its data) to another EC2 | Upgrading a server without copying any data manually |
| Snapshot | Point-in-time backup of an EBS volume | Nightly database backup, restorable or copyable to another Region |
