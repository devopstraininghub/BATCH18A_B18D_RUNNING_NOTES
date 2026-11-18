# Batch 18 — AWS Cloud Running Notes: 23 September 2026

**Topic: Database Types & AWS Database Services (RDS and beyond)**

Friends, today's topic steps back from pure networking/IAM and looks at **where your application's data actually lives** — the three broad categories of data storage (structured, semi-structured, unstructured), and which AWS service is built for each one.

---

## 1. Structured databases (relational databases)

- Store data in a **predefined schema** — organized into tables, with rows and columns.
- Use **SQL** (Structured Query Language) to query and manage the data.

**Key characteristics:**
- Fixed schema.
- Tables, rows, columns, with relationships expressed through **foreign keys**.
- **ACID compliant** (transactions behave reliably).
- Strong consistency.

**Examples:**
- **MySQL** — open-source RDBMS, commonly used for web applications.
- **PostgreSQL** — advanced open-source RDBMS, supports complex queries and extensions.
- **Microsoft SQL Server** — enterprise database, strong integration with the .NET ecosystem.
- **Oracle Database** — enterprise-grade commercial database, high scalability.
- **IBM Db2** — enterprise RDBMS optimized for large workloads.
- **SQLite** — lightweight, embedded relational database, used in mobile/desktop apps.

**AWS's relational services:**
- **Amazon RDS** supports MySQL, PostgreSQL, MariaDB, SQL Server, and Oracle.
- **Amazon Aurora** — AWS's own high-performance relational database engine.

### What Amazon RDS actually is

- RDS = **R**elational **D**atabase **S**ervice — a **fully managed** relational database. AWS handles patching, backups, and storage under the hood, so you don't manage the underlying server yourself.
- **Multi-AZ** — a synchronous standby copy in a different Availability Zone, purely for **high availability**. If the primary fails, RDS fails over to the standby automatically. It does **not** help with read performance.
- **Read Replica** — an **asynchronous** copy of the database, purely for **scaling reads**. You can send read-only queries to it to take load off the primary, but since replication is asynchronous, there's always a small lag before it's fully caught up.

**Easy memory trick:** Multi-AZ → for **availability** (failover). Read Replica → for **scale** (offloading reads). Don't confuse the two — this is one of the most commonly tested RDS facts.

**Amazon Aurora**, specifically, separates storage from compute and claims up to 5x MySQL throughput and 3x PostgreSQL throughput, with storage that auto-scales up to 128 TB — AWS's own "supercharged" version of MySQL/PostgreSQL compatibility.

### CRUD — the basic operations on structured data

- **C**reate — insert new data.
- **R**ead — query existing data.
- **U**pdate — modify existing data.
- **D**elete — remove data.

Almost everything an application does to a relational database boils down to one of these four operations — worth knowing the acronym by heart, since it comes up constantly in both interviews and everyday application design.

### What is SQL?

- **SQL** = **S**tructured **Q**uery **L**anguage — the language used to talk to a relational database.
- Lets you **create** tables, **insert** data, **read/filter** data, **update** existing rows, and **delete** rows — i.e. SQL is literally how you perform CRUD.
- One core language, understood (with small dialect differences) across MySQL, PostgreSQL, SQL Server, Oracle, and every other relational database — learn SQL once, and it transfers almost everywhere.

**Easy memory trick:** SQL is to a database what the AWS CLI is to AWS — the actual command interface, underneath whatever GUI tool you might click through instead.

### What is an ACID transaction?

A **transaction** is a group of one or more database operations that must succeed or fail **together, as a single unit**. **ACID** is the set of four guarantees that make transactions trustworthy:

- **Atomicity** — a transaction is **all-or-nothing**. If any part of it fails, the **entire** transaction is rolled back, as if it never happened.
- **Consistency** — a transaction always moves the database from one **valid** state to another valid state — it can never leave the data broken or half-updated.
- **Isolation** — transactions running **at the same time** don't see each other's unfinished, in-progress changes.
- **Durability** — once a transaction is **committed**, the change is permanent — it survives even if the server crashes or loses power one second later.

**Real-time example — a bank transfer (the classic ACID example):** transferring ₹500 from Account A to Account B is really two operations: debit A, credit B.
- **Atomicity:** if the debit succeeds but the credit fails (say, the app crashes mid-transaction), the **whole** transaction rolls back — the ₹500 is never silently deducted without landing somewhere.
- **Consistency:** if a rule says "balance can never go negative," the transaction is rejected outright rather than leaving an account in an invalid state.
- **Isolation:** if two transfers touch Account A at the exact same moment, one doesn't see the other's half-finished update and calculate the wrong balance.
- **Durability:** once the transfer is confirmed, it's on disk — even a power failure immediately after doesn't undo it.

**Easy memory trick:** ACID → a transaction that's **A**ll-or-nothing, keeps the data **C**orrect, doesn't **I**nterfere with others running at the same time, and **D**oesn't disappear once confirmed.

### Example tables — a mini relational schema

To make CRUD and SQL concrete, here are three simple, related tables — exactly the kind of setup used in almost every SQL tutorial:

**`department`**
| dept_id | dept_name |
|---|---|
| 101 | HR |
| 102 | Engineering |
| 103 | Sales |

**`employee`** (`dept_id` here is a **foreign key**, pointing back to `department`)
| emp_id | emp_name | salary | dept_id |
|---|---|---|---|
| 1 | Ravi | 55000 | 102 |
| 2 | Priya | 62000 | 102 |
| 3 | Kiran | 48000 | 101 |
| 4 | Anjali | 51000 | 103 |

**`student`**
| student_id | student_name | age | course |
|---|---|---|---|
| 1 | Arjun | 21 | DevOps |
| 2 | Meena | 22 | Cloud Computing |
| 3 | Suresh | 20 | DevOps |

### Basic SQL queries against these tables

**Creating a table:**
```sql
CREATE TABLE department (
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

CREATE TABLE employee (
    emp_id   INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary   INT,
    dept_id  INT,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);
```
`FOREIGN KEY` is what actually creates the relationship between `employee` and `department` — it's the mechanism behind the "relationships using foreign keys" bullet from earlier in this file.

**Inserting data:**
```sql
INSERT INTO department VALUES (102, 'Engineering');
INSERT INTO employee VALUES (1, 'Ravi', 55000, 102);
```

**Reading data — the `SELECT` statement:**
```sql
SELECT * FROM employee;
```
```
emp_id | emp_name | salary | dept_id
-------+----------+--------+--------
     1 | Ravi     |  55000 |     102
     2 | Priya    |  62000 |     102
     3 | Kiran    |  48000 |     101
     4 | Anjali   |  51000 |     103
```

**Filtering with `WHERE`:**
```sql
SELECT emp_name, salary FROM employee WHERE salary > 50000;
```
```
emp_name | salary
---------+-------
Ravi     |  55000
Priya    |  62000
Anjali   |  51000
```

**Sorting with `ORDER BY`:**
```sql
SELECT student_name, age FROM student ORDER BY age DESC;
```

**Updating a row:**
```sql
UPDATE employee SET salary = 60000 WHERE emp_id = 1;
```
Only Ravi's row (`emp_id = 1`) changes — every other row is untouched. **Always include a `WHERE` clause on an `UPDATE`** — without one, it updates **every single row** in the table.

**Deleting a row:**
```sql
DELETE FROM student WHERE student_id = 3;
```
Same warning applies — a `DELETE` with no `WHERE` clause deletes the **entire table's data**.

**Joining two related tables — `JOIN`:**
```sql
SELECT employee.emp_name, department.dept_name
FROM employee
JOIN department ON employee.dept_id = department.dept_id;
```
```
emp_name | dept_name
---------+-----------
Ravi     | Engineering
Priya    | Engineering
Kiran    | HR
Anjali   | Sales
```
This is exactly what "relationships using foreign keys" is for — pulling the department **name** for each employee, even though the `employee` table itself only stores a `dept_id` number.

**Easy memory trick:** `SELECT` = read, `INSERT` = create, `UPDATE` = update, `DELETE` = delete — literally CRUD, mapped one-to-one onto SQL keywords.

---

## 2. Semi-structured databases (NoSQL — flexible schema)

- **Do not require a fixed schema** — the structure of the data can vary between records.
- Often stored as **JSON**, key-value pairs, or wide-column format.

**Key characteristics:**
- Flexible schema.
- Horizontally scalable.
- High availability.
- Suitable for large-scale, distributed systems.

**Examples:**
- **MongoDB** — document database, storing JSON-like documents.
- **Apache Cassandra** — distributed, wide-column database, built for high scalability.
- **Amazon DynamoDB** — AWS's own fully managed NoSQL key-value database.
- **Google Cloud Datastore** — a document-based NoSQL database.
- **OrientDB** — a multi-model database (graph + document).

**AWS's NoSQL services:**
- **DynamoDB**.
- **DocumentDB** (MongoDB-compatible).

---

## 3. Unstructured data (not a database type)

⚠️ **Important distinction:** unstructured data is **not** the same thing as a NoSQL database — don't conflate the two. Unstructured data simply means data with **no fixed format or schema at all**.

**Examples of unstructured data:** images, videos, audio, log files, PDFs, backups.

**Tools used to store unstructured data:**
- **Amazon S3** — object storage for essentially unlimited unstructured data (see `21September_S3.md`).
- **Azure Blob Storage** — object storage for binary data.
- **Hadoop (HDFS)** — distributed file system, built for big data.
- **Elasticsearch** — a search engine for logs and text indexing.
- **Apache Solr** — a text search engine, built on Lucene.
- **Cassandra (with blobs)** — can technically store binary data, though it's not ideal for large files.

⚠️ **Important:** object storage like S3 is **not a database** — it's a storage service. Don't call it a database in an interview.

---

## 4. Simple comparison

| | Structured | Semi-structured (NoSQL) | Unstructured |
|---|---|---|---|
| Schema | Fixed | Flexible | None |
| Format | SQL, tables | JSON / key-value | Raw files |
| Consistency | Strong | Highly scalable | N/A — just storage |
| Example | MySQL, PostgreSQL | MongoDB, DynamoDB | Images in S3 |

---

## 5. When to use what?

**Use a relational database when:**
- Banking systems, ERP systems.
- Transactions matter.
- Strong consistency is required.

**Use NoSQL when:**
- Large-scale web apps, real-time apps.
- IoT data.
- High-traffic applications.

**Use object storage (S3) when:**
- Media storage, backups, logs, data lakes.

---

## 6. AWS database summary

| Category | Service(s) |
|---|---|
| Relational | Amazon RDS, Amazon Aurora |
| NoSQL | DynamoDB, DocumentDB |
| In-memory | ElastiCache (Redis, Memcached) |
| Search | OpenSearch (the managed Elasticsearch service) |
| Object storage | Amazon S3 |

**A brief word on the two you haven't seen named before:**
- **ElastiCache** — a fully managed **in-memory** data store (Redis or Memcached), used to cache frequently-read data so an application doesn't have to hit the main database for every request — dramatically faster, but data isn't meant to be the permanent source of truth.
- **OpenSearch** — AWS's managed version of Elasticsearch, used for full-text search and log analytics (e.g. searching through application logs, or powering a search bar on a website).

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Structured / relational | Fixed schema, SQL, ACID transactions | A banking application's account balances |
| SQL | The language used to query/manage a relational database | `SELECT`, `INSERT`, `UPDATE`, `DELETE` — CRUD as actual keywords |
| ACID | Atomicity, Consistency, Isolation, Durability | A bank transfer that's all-or-nothing, never half-completed |
| `FOREIGN KEY` / `JOIN` | Links two tables together, pulls related data | Getting an employee's department name from a `dept_id` |
| Semi-structured / NoSQL | Flexible schema, horizontally scalable | A product catalog with wildly different fields per item |
| Unstructured data | No fixed format at all — not a database type | Images, videos, and logs, stored in S3 |
| RDS | AWS's fully managed relational database service | MySQL/PostgreSQL without managing the server yourself |
| Aurora | AWS's own high-performance relational engine | Higher throughput than stock MySQL/PostgreSQL |
| Multi-AZ vs Read Replica | High availability (sync) vs read scaling (async) | Failover on primary loss vs offloading read traffic |
| DynamoDB | AWS's managed NoSQL key-value database | A high-traffic app needing single-digit-millisecond reads |
| ElastiCache | In-memory cache in front of a database | Avoiding a database hit on every single page load |
