# Batch 18 — AWS Cloud Running Notes: 25 September 2026

**Topic: Amazon RDS (Relational Database Service)**

Friends, on 23 September we looked at databases conceptually — structured vs semi-structured vs unstructured data, and a quick summary of which AWS database service fits where (see `23September_Databases.md`). Today we go hands-on with the one you'll use most as a DevOps engineer: **Amazon RDS**, AWS's fully-managed relational database service — we'll create a real MySQL RDS instance, connect to it, and run our first SQL queries against it.

---

## 1. What is Amazon RDS?

- **RDS (Relational Database Service)** = a fully-managed AWS service for running relational databases, without you having to manage the underlying server yourself.
- Supported engines: **MySQL, PostgreSQL, MariaDB, Oracle, SQL Server**, and AWS's own **Aurora** (MySQL/PostgreSQL-compatible).
- "Fully-managed" means AWS handles: OS patching, database engine patching, backups, storage scaling (if enabled), and failover (in Multi-AZ) — you focus on the schema, the queries, and the application.

---

## 2. Why use RDS instead of installing MySQL yourself?

- No OS-level maintenance — no patching a server just to keep the database engine current.
- Automated backups and point-in-time recovery, out of the box.
- Built-in high availability via **Multi-AZ** (a standby copy in a second Availability Zone, automatic failover) — covered in more depth in `23September_Databases.md`.
- Easy vertical scaling — resize the instance class without a manual migration.
- Monitoring built in via CloudWatch, without installing anything extra.

---

## 3. Why not just install MySQL on an EC2 instance?

You *can* — nothing stops you from running `yum install mysql-server` on an EC2 box. But then **you** become responsible for everything RDS would otherwise handle:

- Patching the OS and the MySQL engine yourself.
- Setting up and testing backups yourself.
- Building your own failover mechanism for high availability.
- Manually resizing storage as data grows.

**Easy memory trick:** MySQL-on-EC2 = you own the whole stack, top to bottom. RDS = AWS owns the database-server layer, you only own the schema and the data.

---

## 4. RDS vs MySQL-on-EC2 — comparison

| | RDS | MySQL on EC2 |
|---|---|---|
| OS patching | Managed by AWS | Your responsibility |
| Engine patching | Managed by AWS (with a maintenance window) | Your responsibility |
| Backups | Automated, built-in | You script and manage it |
| High availability | Multi-AZ, one setting to enable | You build it yourself |
| Storage scaling | Can be automatic | Manual (resize/attach volumes) |
| Full OS-level access | No — you don't get shell access to the DB server | Yes — full root access |
| Best for | Most production relational database needs | Cases needing full control over the OS/engine configuration |

---

## 5. What is an RDS "DB Instance"?

- A **DB Instance** is the actual running database environment RDS creates and manages for you — the equivalent of "the server the database lives on," except you never SSH into it.
- Every RDS deployment starts with creating at least one DB Instance.

---

## 6. RDS MySQL — architecture at a glance

```
Application / EC2
        │
        │  TCP 3306
        ▼
   RDS Endpoint (DNS name)
        │
        ▼
   RDS DB Instance (MySQL engine)
        │
        ▼
   Underlying storage (managed by AWS)
```

You never address the database by a raw IP — you always connect through its **endpoint**, a stable DNS name AWS gives the instance (§10 below).

---

## 7. Important RDS components

- **DB Instance** — the running database engine itself.
- **DB Instance Class** — the compute size (CPU + memory), e.g. `db.t3.micro`.
- **Storage** — the disk backing the database (type + allocated size).
- **Database Engine** — MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, or Aurora.
- **Endpoint** — the DNS hostname used to connect.
- **Port** — the TCP port the engine listens on (3306 for MySQL).
- **DB Subnet Group** — the set of subnets RDS is allowed to place the instance into.
- **Security Group** — the firewall controlling what can reach the instance.
- **Multi-AZ** — optional standby replica in a second AZ for automatic failover.
- **Read Replica** — optional read-only copy for scaling read traffic.
- **Parameter Group** — engine configuration settings (e.g. MySQL config variables).
- **Option Group** — additional engine features (mainly relevant for Oracle/SQL Server).
- **Backup / Snapshot** — automated and manual backups of the instance.
- **Maintenance Window** — the scheduled time AWS applies patches.
- **Public Accessibility** — whether the instance can be reached directly from the public Internet.

**Easy memory trick:** think of these the same way you'd think about an EC2 instance's building blocks (instance type, storage, SG, subnet) — RDS just adds a few database-specific pieces (engine, endpoint, parameter group) on top of that same pattern.

---

## 8. Database engine

- You choose the engine at creation time — for today's hands-on, **MySQL**.
- The engine and its major version affect feature availability and client compatibility, so check compatibility with your application before choosing.

---

## 9. MySQL's default port

```
3306
```

Every MySQL client (CLI, SQL Electron, your application's connection string) needs to know this port to connect, unless you've deliberately changed it.

---

## 10. RDS Endpoint

- The **Endpoint** is the DNS hostname RDS assigns to your DB Instance — this is what you connect to, never a raw IP (the underlying IP can change; the endpoint doesn't).

**Example:**
```
Endpoint:
    prod-mysql.xxxxxxxxxxxx.ap-south-1.rds.amazonaws.com

Port:
    3306
```

A client only needs three things to attempt a connection: the endpoint, the port, and valid credentials.

---

## 11. DB Subnet Group

- A **DB Subnet Group** is a collection of subnets (across two or more AZs) that tells RDS *where it's allowed to place* the DB instance and any Multi-AZ standby.
- Required for any RDS instance that's inside a VPC (which is the default today).
- Needs subnets in **at least two AZs**, even for a Single-AZ deployment — so that Multi-AZ can be enabled later without re-architecting.

---

## 12. Why RDS normally sits in a private subnet

- The database itself doesn't need to be reachable from the public Internet — only your application (typically on EC2, in turn behind an ALB) needs to reach it.
- Keeping RDS in a **private subnet** means it has no direct path to/from the Internet, cutting off a whole category of external attacks.
- This is the same private-subnet reasoning already applied to the mini-project's backend EC2 instances (see `17September_MiniProject.md`).

---

## 13. Public vs Private RDS

| | Public RDS | Private RDS |
|---|---|---|
| Reachable from the Internet? | Yes (if SG also allows it) | No |
| Typical use | Learning/testing, quick demos | Production |
| Risk | Directly exposed to Internet-based attacks | Isolated — only reachable from inside the VPC (or via VPN/bastion) |

---

## 14. RDS Security Group

- Controls what's allowed to reach the DB instance on its port — same concept as an EC2 Security Group (see `10September_SG.md`), just attached to RDS instead.
- Stateful, allow-only, evaluated the same way EC2 SGs are.

---

## 15. Best-practice Security Group design for RDS

**Recommended:**
```
RDS-SG
   |
   +---- Inbound TCP 3306
                |
                v
             EC2-SG   (source = the application's Security Group, not an IP range)
```

**Avoid:**
```
TCP 3306
Source: 0.0.0.0/0
```

Setting the source as *another Security Group* (rather than an IP/CIDR) means only instances that are themselves in `EC2-SG` can ever reach the database — even if the EC2 fleet's IPs change (e.g. after Auto Scaling replaces an instance), the rule doesn't need updating.

---

## 16. Putting it together — a full project architecture with RDS

```
Internet
   │
   ▼
  ALB   (public subnet)
   │
   ▼
  EC2 (Auto Scaling Group)   (private subnet)
   │
   │  TCP 3306, EC2-SG → RDS-SG
   ▼
  RDS MySQL   (private subnet, Multi-AZ)
```

This is the same layered pattern from the mini project (`17September_MiniProject.md`) — RDS simply becomes the private, database-layer tier at the bottom of it.

---

## 17. Hands-on — creating a MySQL RDS instance (console walkthrough)

**Step 1 — Open the RDS console**
```
AWS Console → search "RDS" → open Amazon RDS
```

**Step 2 — Start creation**
```
Databases → Create database
```

**Step 3 — Choose a database creation method**
- **Standard create** — full control over every setting (recommended while learning).
- **Easy create** — AWS picks sensible defaults for you.

**Step 4 — Select engine**
```
Engine: MySQL
Version: pick a supported version, check compatibility with your app
```

**Step 5 — Select a template**
```
Production | Dev/Test | Free tier
```

**Step 6 — DB Instance Identifier**
- This is the **name of the RDS instance itself** in the AWS console — **not** the same as the database name created inside it (§30 below is a different thing).

**Example:**
```
DB instance identifier: prod-mysql-db
```

**Step 7 — Master username**
```
Master username: admin
```
⚠️ **Never hardcode the master password** in Git, GitHub, Terraform files, shell scripts, Dockerfiles, or any public documentation. Use a proper secrets-management approach (AWS Secrets Manager, SSM Parameter Store, or a vault) for anything beyond a personal learning environment.

**Step 8 — Master password**
- Set a strong password.
- Avoid anything guessable — `password`, `admin123`, `mysql123`, etc.
- For production: rotate credentials according to your organization's security policy, and manage the password through a secrets-management tool rather than typing it once and forgetting where it's stored.

**Step 9 — DB Instance Class**
- Defines the compute capacity: CPU, memory, and network performance.

**Example:**
```
db.t3.micro
```
`db.t3.micro` and `db.t4g.micro` are both free-tier eligible (Single-AZ, up to 750 hours/month in your first 12 months, on MySQL/MariaDB/PostgreSQL/SQL Server Express) — a solid fit for learning and testing. Pick a larger class based on actual workload once you move toward production.

**Think:** `DB Instance Class = CPU + Memory capacity` (mirrors EC2 instance types).

**Step 10 — Storage**
```
Storage: 20 GiB (example)
```
You can also configure the storage type and enable storage autoscaling. **Think:** `Instance Class = Compute`, `Storage = Database Disk` — two separate dials.

**Step 11 — Connectivity**
- Select the **VPC** the instance belongs in.

**Example (this batch's project VPC):**
```
VPC: prod-vpc
CIDR: 10.81.0.0/16
```
- Then select the **DB Subnet Group** and **Security Group** (§11, §14–15).

**Step 12 — Public accessibility**
```
Public access: No   (production-style setup)
```
Keeps the database reachable only from inside the VPC — see §12–13.

**Step 13 — Security Group for RDS**
```
RDS-SG
  Inbound: MySQL/Aurora, TCP, port 3306, source = EC2's Security Group
```
(§15 — never `0.0.0.0/0`.)

**Step 14 — Database port**
```
3306   (MySQL default — leave as-is unless you have a specific reason to change it)
```
If you do change it, every client and application connecting to it must be updated to use the same custom port.

**Step 15 — Initial database name (optional)**

**Example:**
```
Initial database name: mindcircuit
```
This pre-creates one database inside the instance so you have something to connect to immediately after launch — you can still create more databases later via SQL.

**Step 16 — Review and create**
```
Review all settings → Create database
```
- Status will show **Creating** at first.
- Wait for it to reach **Available** before attempting to connect — connecting while it's still "Creating" will simply fail.

---

## 18. Finding your RDS endpoint

```
RDS → Databases → select your DB instance → Connectivity & security tab
```
Look for **Endpoint** and **Port**.

**Example:**
```
Endpoint: prod-mysql.xxxxxxxxxxxx.ap-south-1.rds.amazonaws.com
Port:     3306
```

---

## 19. Connecting with a SQL client — SQL Electron

- **SQL Electron** is a free graphical SQL client (a desktop GUI) used to connect to a database server and run SQL queries visually, instead of purely from a terminal.
- To connect to your RDS MySQL instance, you need five things: **Host, Port, Username, Password, Database**.

**Example:**
```
Host:     prod-mysql.xxxxxxxxxxxx.ap-south-1.rds.amazonaws.com
Port:     3306
User:     admin
Password: ********
Database: mindcircuit
```

**Steps to connect:**
1. Open SQL Electron.
2. Create a new MySQL connection.
3. Enter Host / Port / Username / Password / Database.
4. Test connection.
5. Connect.
6. Open the SQL editor/query window.
7. Run SQL queries.

---

## 20. Checklist — why a SQL Electron connection might fail

For the connection to succeed:
1. The RDS instance must be **Available**, not still "Creating."
2. Correct **endpoint**.
3. Correct **port**.
4. Correct **username**.
5. Correct **password**.
6. The RDS **Security Group** must allow your client's IP (if connecting straight from your laptop).
7. RDS must be **publicly accessible**, if you're connecting directly over the public Internet.
8. **Network ACLs** must not be blocking the traffic (see `11September_NACL.md`).
9. Your local/company **firewall** must allow the outbound connection.

**Easy memory trick:** this is basically the same "can I even reach it, and am I allowed to" checklist you'd run through for any EC2 connectivity issue — endpoint/port/credentials get you to the door, SG/NACL/firewall decide whether the door opens.

---

## 21. Connecting to a *private* RDS instance

If the database is private (§12–13), your laptop cannot connect to it directly over the public Internet — you need one of:
```
VPN
AWS Direct Connect
Bastion / Jump Host   (see 17September_Bastion.md)
```

**Example:**
```
Laptop
   │
   ▼
Bastion / VPN
   │
   ▼
Private RDS
```

---

## 22. A simple development-only connection setup

Strictly for learning/testing — **not** how production should be configured:

```
RDS Public access: Yes

RDS Security Group inbound:
    MySQL, TCP, 3306, source = YOUR PUBLIC IP/32   (e.g. 203.0.113.25/32)

NEVER: source = 0.0.0.0/0
```
Even in a public, temporary dev setup, scope the source to your own IP with a `/32`, not the whole Internet.

---

## 23. SQL basics — commands you'll use once connected

```
CREATE DATABASE
USE
CREATE TABLE
INSERT
SELECT
UPDATE
DELETE
ALTER
DROP
```
(SQL syntax and the CRUD mapping are covered in more depth with worked examples in `23September_Databases.md` — today's session is the first time we ran these against a *real, live RDS instance* instead of just on paper.)

---

## 24. Hands-on — our actual queries against the live RDS instance

**Check what's there, and switch to our database:**
```sql
SHOW DATABASES;
USE facebookdb;
SELECT DATABASE();
```

**Create a table:**
```sql
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,  -- Employee ID, auto-incremented
    first_name VARCHAR(50),                      -- First Name
    last_name VARCHAR(50)                         -- Last Name
);
```

**Insert rows (Create):**
```sql
INSERT INTO employees (first_name, last_name) VALUES ('MADHU', 'KIRAN');
INSERT INTO employees (first_name, last_name) VALUES ('x', 'y');
INSERT INTO employees (first_name, last_name) VALUES ('a', 'b');
```

**Read the data back:**
```sql
SELECT * FROM employees;
```
**Sample output:**
```
+-------------+------------+-----------+
| employee_id | first_name | last_name |
+-------------+------------+-----------+
|           1 | MADHU      | KIRAN     |
|           2 | x          | y         |
|           3 | a          | b         |
+-------------+------------+-----------+
```

```sql
SELECT first_name, last_name FROM employees;
```

**Update a row:**
```sql
UPDATE employees
SET last_name = 'kotha'
WHERE employee_id = 3;
```

**Delete a row:**
```sql
DELETE FROM employees
WHERE employee_id = 3;
```
⚠️ Always include a `WHERE` clause with `UPDATE`/`DELETE` — leaving it off updates or deletes **every row in the table**.

**CRUD, mapped to exactly what we just ran:**
```
Create : INSERT INTO employees (...)
Read   : SELECT * FROM employees
Update : UPDATE employees SET column_name = value WHERE condition
Delete : DELETE FROM employees WHERE condition
```

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| RDS | AWS's fully-managed relational database service | MySQL/PostgreSQL/Aurora without managing the OS |
| DB Instance | The actual running database environment | Created the moment you launch RDS |
| DB Instance Class | The compute size (CPU + memory) of the instance | `db.t3.micro` for learning, larger for production |
| Endpoint | The stable DNS hostname used to connect | `prod-mysql.xxxx.ap-south-1.rds.amazonaws.com` |
| DB Subnet Group | Subnets (2+ AZs) RDS is allowed to use | Required for any VPC-based RDS instance |
| RDS Security Group | Firewall controlling access to the DB port | Inbound 3306 from `EC2-SG` only, never `0.0.0.0/0` |
| Public vs Private RDS | Whether the instance is Internet-reachable | Private + EC2/ALB in front, for production |
| SQL Electron | A GUI SQL client for connecting and running queries | Connect via Host/Port/User/Password/Database |
| Bastion/VPN for private RDS | How you reach a private DB from outside the VPC | Laptop → Bastion → Private RDS |
| CRUD in SQL | Create/Read/Update/Delete, mapped to SQL statements | `INSERT` / `SELECT` / `UPDATE` / `DELETE` |
