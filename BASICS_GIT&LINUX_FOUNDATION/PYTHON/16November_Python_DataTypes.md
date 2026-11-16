# Batch 18 — Running Notes: 16 November 2026

**Topic: Python Collection Types — Deep Dive + Real DevOps Examples**

Friends, `13November_Python.md` §4 introduced `list`/`tuple`/`set`/`dict` by name only. Today we go deeper into each one — their actual properties, where a DevOps engineer would really use each one, and we close with static vs dynamic typing.

---

## 1. The four collection types, properties

**List:**
- Ordered.
- Mutable (can be changed after creation).
- Allows duplicates.
```python
list_example = [1, 2, 3, 1]
```

**Tuple:**
- Ordered.
- Immutable (cannot be changed after creation).
- Allows duplicates.
```python
tuple_example = (1, 2, 3, 1)
```

**Set:**
- Unordered.
- No duplicates — automatically removes repeated values.
- No index — you can't do `my_set[0]`.
```python
set_example = {1, 2, 3}
```

**Dictionary:**
- Unordered (insertion order is preserved for display purposes, since Python 3.7+, but a dict is still conceptually a key→value lookup, not a sequence).
- Mutable.
- Stores key-value pairs.
```python
dict_example = {
    "name": "Madhu",
    "age": 30,
    "address": "xyz",
    "prof": "abc"
}
```

⚠️ **The raw class example for a mixed-type list had two real bugs, worth seeing once:**
```python
x = [10, madhu, 5.3, 4+3i]   # ❌ wrong
```
- `madhu` with no quotes — Python reads this as a **variable name**, not text. Since no variable called `madhu` exists, this crashes with `NameError: name 'madhu' is not defined`.
- `4+3i` — Python's complex-number suffix is **`j`**, not `i` (unlike the math/engineering convention). This is a `SyntaxError`.

**Correct version:**
```python
x = [10, "madhu", 5.3, 4 + 3j]   # ✅ works — int, str, float, complex, all in one list
```

**Easy memory trick:** **List** = ordered + changeable. **Tuple** = ordered + locked. **Set** = no duplicates, no order. **Dict** = named slots (keys), not numbered ones.

---

## 2. Real DevOps use cases for each type

| Type | Real DevOps use case | Example |
|---|---|---|
| **List** | Server IPs in a cluster — the list changes as servers are added/removed | `server_ips = ["192.168.1.1", "192.168.1.2", "10.81.0.3"]` |
| **Tuple** | Fixed server configuration (IP, OS, version) — once set, these shouldn't change | `server_config = ("192.168.1.1", "Ubuntu", "18.04")` |
| **Tuple** | Immutable system settings — region, AZ, instance type stay constant for a deployment | `system_settings = ("US-East", "us-east-1a", "m5.large")` |
| **Set** | Active services running on a server — uniqueness matters, you don't want "nginx" listed twice | `active_services = {"nginx", "redis", "mysql", "jenkins"}` |
| **Set** | Unique error codes seen during an incident — useful for alerting/monitoring | `error_codes = {404, 500, 502}` |
| **Dict** | Environment variables for an app — keys are unique, values vary | `env_vars = {"DB_HOST": "mcdb.example.com", "DB_USER": "admin"}` |
| **Dict** | App configuration — timeout/retry settings, keyed by setting name | `config = {"timeout": 30, "retries": 3}` |

---

## 3. Practical examples

**Remove duplicates from a list:**
```python
usernames = ["madhu", "kiran", "madhu", "raja"]
unique = list(set(usernames))
print(unique)
```
- `set(usernames)` drops the duplicate `"madhu"`, then `list(...)` converts it back to a list, since `set` has no guaranteed order and no indexing.
- **Sample output** (exact order isn't guaranteed — sets don't preserve insertion order):
```
['raja', 'kiran', 'madhu']
```

**A contact book — a list of dictionaries:**
```python
contact_book = [
    {"name": "Madhu", "phone": "7396627149", "email": "madhu@example.com"},
    {"name": "Kiran", "phone": "9000000000", "email": "kiran@example.com"},
]
```
- Each contact is its own `dict` (named fields); the whole book is a `list` (ordered, can grow) — this combination, a **list of dicts**, is one of the most common real data shapes you'll build in DevOps scripting (think: a list of servers, each described by its own dict of properties).

---

## 4. Static typing vs dynamic typing

- **Dynamic typing** (what Python uses): a variable's type is decided **at runtime**, not in advance. You never declare a type before assigning.
- **Static typing**: a variable's type is fixed **at compile time** — you must declare it up front, and it can't change afterward. C, C++, Go, and Java are statically typed.

```python
x = 10        # int
x = "madhu"   # now a string — perfectly legal in Python
x = 10.2      # now a float
x = 4 + 3j    # now a complex number
```
- This is the exact same behavior already shown in `13November_Python.md` §3 — today just gives it its proper name: **dynamic typing.**

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| List | Ordered, mutable, allows duplicates | A cluster's changing list of server IPs |
| Tuple | Ordered, immutable, allows duplicates | Fixed server config: `(IP, OS, version)` |
| Set | Unordered, no duplicates, no index | Active services on a server |
| Dict | Key-value pairs | Environment variables for an app |
| List of dicts | A list where each element is its own structured dict | A contact book, or a list of servers each with their own properties |
| `list(set(x))` | A quick way to remove duplicates from a list | `list(set(["a", "b", "a"]))` |
| Dynamic typing | Python decides a variable's type at runtime | `x = 10` then `x = "madhu"` — both legal |
| Static typing | Type fixed at compile time, declared upfront | C, C++, Go, Java |
