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
- Encryption available, using AWS KMS (Key Management Service) keys — secures data at rest.
- Can be resized anytime — increase size or change type, without even detaching the volume from its instance.
- High durability — a 99.999% durability rating, meaning data on an EBS volume is very well protected against loss.
- Multi-Attach (on `io2` Block Express volumes) — some volume types can be attached to **multiple** EC2 instances at the same time.
- Local Snapshots — point-in-time snapshots can be created directly on the EC2 instance itself, without needing S3.

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

## 4. Creating and attaching an EBS volume — Console + CLI

Creating and attaching a volume to an EC2 instance is a two-part job: a few clicks in the AWS Console, then a few commands on the instance itself.

**In the AWS Console:**
1. Log in to the AWS Management Console, go to the **EC2 dashboard**.
2. Under **"Elastic Block Store"**, select **"Volumes"** → click **"Create Volume"** → choose specifications (volume type, size in GiB, Availability Zone — must match the instance you'll attach it to) → click **"Create."**
3. Select the new volume → **"Actions"** → **"Attach Volume"** → choose the EC2 instance to attach it to → confirm a **device name** (AWS suggests one, e.g. `/dev/sdf`) → click **"Attach."**

⚠️ A useful note straight from AWS: newer Linux kernels may internally rename your device to something like `/dev/xvdf` (or on newer instance types, `/dev/nvme1n1`), even though the device name you entered in the console was `/dev/sdf`-style. `lsblk` is how you find out what it's actually called once you're connected — don't assume the console's device name is the final one.

**On the instance itself — format, mount, verify:**
```
sudo mkfs.ext4 /dev/xvdf
sudo mkdir /madhu
sudo mount -t ext4 /dev/xvdf /madhu
df -Th
```
- **`lsblk`** — run this first, to confirm the new volume is actually visible and to check its real device name (covered in section 1).
- **`mkfs.ext4 /dev/xvdf`** — **M**a**k**e **F**ile**s**ystem: formats the raw disk with the `ext4` filesystem type, so Linux can actually store files on it. This step **wipes** anything already on the disk — only do this on a genuinely new/empty volume.
- **`mkdir /madhu`** — creates an empty folder to use as the **mount point** — the location in the filesystem tree where the disk will "appear."
- **`mount -t ext4 /dev/xvdf /madhu`** — attaches the formatted disk to that folder. `-t ext4` tells `mount` what filesystem type to expect. From this point on, anything saved inside `/madhu` is actually being written onto the EBS volume, not the server's own root disk.
- **`df -Th`** — the verification step: confirms the volume shows up, mounted at `/madhu`, with the right size and filesystem type.

**Sample output (matching what we saw in class):**
```
$ lsblk
NAME       MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
xvda       202:0    0   8G  0 disk
├─xvda1    202:1    0   8G  0 part /
xvdf       202:80   0   1G  0 disk

$ sudo mkfs.ext4 /dev/xvdf
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 262144 4k blocks and 65536 inodes
...

$ sudo mkdir /madhu
$ sudo mount -t ext4 /dev/xvdf /madhu
$ df -Th
Filesystem  Type   Size  Used Avail Use% Mounted on
/dev/xvda1  xfs    8.0G  1.5G  6.5G  19% /
/dev/xvdf   ext4   974M   24K  907M   1% /madhu
```

**Easy memory trick:** `mkfs` once per disk, ever — never repeat it on a disk that already has data you want to keep.

---

## 5. Cloning a volume onto a second server — using a snapshot

This is the flow we actually practiced in class today, and it's the standard real-world way to get a **copy** of one server's data onto another server — not by physically unplugging the same disk, but by taking a snapshot and creating a fresh volume from it.

**Step 1 — create a snapshot of Server1's volume:**
- In the EC2 dashboard, under "Elastic Block Store" → "Volumes," select the volume attached to Server1 (`vol-1`).
- "Actions" → "Create Snapshot" → give it a meaningful name/description → "Create Snapshot."

**Step 2 — create a new volume from that snapshot:**
- "Snapshots" (left navigation) → select the snapshot just created.
- "Actions" → "Create Volume" → specify size and Availability Zone — **must match Server2's AZ** → "Create Volume." (This becomes `vol-2`.)

**Step 3 — attach the new volume to Server2:**
- "Volumes" → select the newly created volume (`vol-2`) → "Actions" → "Attach Volume" → choose Server2 → "Attach."

**Step 4 — connect to Server2 and mount it:**
```
lsblk
sudo mkdir /kiran
sudo mount -t ext4 /dev/xvdf /kiran
df -Th
```
Notice **`mkfs` is not run here at all** — the new volume was created *from a snapshot*, so it already contains Server1's exact filesystem and data. Server2 only needs a mount point folder (`mkdir /kiran`) and to `mount` the volume — every file that was on Server1's original volume shows up immediately on Server2, under `/kiran`.

**Real-time example:** This exact snapshot → new volume → attach-elsewhere flow is how you'd clone a production database's data onto a staging/test server, or move a workload's data to an instance in another Availability Zone, without ever manually copying files one by one.

**Easy memory trick:** Detach/reattach moves the *same* disk. Snapshot → new volume gives you a *copy* — the original keeps working, untouched.

---

## 6. Backup and disaster recovery — snapshots

- A **snapshot** is a backup of an EBS volume, taken at a point in time.
- Snapshots are stored in **S3** internally by AWS (you don't manage this storage yourself).
- A new EBS volume can be **restored** from a snapshot at any time — this is exactly what we just did in section 5.
- **Copying a snapshot** — snapshots can be copied, including to a **different AWS Region**, which is how a backup gets moved for disaster-recovery purposes.

**Used for:**
- Backups.
- Disaster recovery.
- Creating AMIs (a snapshot can become the base image for launching new EC2 instances).

**Real-time example:** Taking a snapshot of a production database's EBS volume every night, and copying that snapshot to a second AWS Region — if the primary Region ever has a major outage, a new volume (and a new EC2 instance) can be restored from that copied snapshot in the other Region.

**Easy memory trick:** Snapshot → a save-point for your disk, that you can rewind to or clone from anytime.

---

## 7. Creating a volume in another Region — copying a snapshot across Regions

Same idea as section 5, but the new volume ends up in a **different Region** entirely — the real building block behind disaster recovery.

1. **Source Region:** EC2 dashboard → "Elastic Block Store" → "Snapshots" → select the snapshot to use.
2. **Copy it:** "Actions" → "Copy Snapshot" → choose the **destination Region** → configure any other settings → "Copy."
3. **Switch to the destination Region** in the console → "Volumes" → "Create Volume" → in the "Snapshot" dropdown, pick the copied snapshot → specify size/settings → "Create Volume."
4. **Attach** the new volume to an EC2 instance already running in that destination Region.
5. **Connect** to that instance, run `lsblk` to identify the volume, format and mount it (same `mkfs`/`mkdir`/`mount` steps as before), and verify with `df -Th`.

**Real-time example:** A company running its main application in `us-east-1` keeps nightly snapshots copied over to `ap-south-1` (Mumbai) as well — if `us-east-1` ever has a serious outage, they can create a volume from that copied snapshot in Mumbai, attach it to a standby EC2 instance there, and be back up with minimal data loss.

**Easy memory trick:** Copy the *snapshot* across Regions, not the *volume* — a snapshot is what's actually allowed to travel between Regions.

---

## 8. Cleanup — don't forget to delete what you created

⚠️ **Important, tied back to yesterday's Free Tier caution:** volumes and snapshots you create during practice **keep costing you** until you delete them — AWS doesn't clean these up automatically.

- **Delete volumes:** EC2 dashboard → "Elastic Block Store" → "Volumes" → select the ones you created → "Actions" → "Delete Volume" → confirm.
- **Delete snapshots:** EC2 dashboard → "Elastic Block Store" → "Snapshots" → select the ones you created → "Actions" → "Delete Snapshot" → confirm.
- Do this in **every Region** you touched today, including the destination Region from section 7 — it's easy to forget resources sitting in a Region you're not actively looking at.

**Real-time example:** This is exactly the kind of forgotten resource — an old snapshot or an unattached volume sitting in some Region — that quietly shows up on a real AWS bill weeks later. Making cleanup a habit now saves that surprise later.

---

## Quick Recap Table

| Command / Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `hostnamectl set-hostname name` | Permanently rename the server | Giving each server a meaningful name instead of a random one |
| `lsblk` | List every disk/partition attached to the server, and its real device name | Confirming a newly attached EBS volume is visible to the OS |
| `df -Th` | Disk space + filesystem type, human-readable | Checking whether a disk is formatted/mounted yet |
| EBS (Elastic Block Store) | Persistent, detachable, resizable block storage for EC2 | The actual disk behind a database or app server |
| `mkfs.ext4 /dev/x` | Format a raw disk with a filesystem | One-time setup of a brand-new EBS volume — never repeat on a disk with data |
| `mount -t ext4 /dev/x /folder` | Attach a formatted disk to a folder path | Making an EBS volume's storage usable at `/madhu` |
| Detach + reattach an EBS volume | Move the *same* disk to another EC2 | Upgrading a server without copying any data manually |
| Snapshot → new Volume → attach elsewhere | Clone a disk's data onto another server | Cloning production data onto a staging server, e.g. `/kiran` on Server2 |
| Copy a snapshot to another Region | Move a backup across Regions | Disaster recovery — standing up a replacement server in a second Region |
| Delete unused volumes/snapshots | Stop paying for resources you no longer need | Avoiding a surprise AWS bill after practice sessions |
