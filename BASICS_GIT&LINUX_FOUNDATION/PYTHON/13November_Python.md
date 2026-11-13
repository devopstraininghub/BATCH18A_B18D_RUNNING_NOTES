# Batch 18 — Running Notes: 13 November 2026

**Topic: Why Python for DevOps? + Python Basics**

Friends, you already know Shell Scripting (`BASICS_GIT&LINUX_FOUNDATION/AWS-LINUX-SHELL/27August.md`/`28August.md`) — so today starts with the obvious question: if Shell can already automate things, why learn an entire second language? Then we get into Python's actual basics — variables, data types, input/output, and operators — building toward real DevOps scripting over the next few classes.

---

## 1. If Shell Scripting already exists, why Python?

### Shell Scripting — what it's good at
- A command-line interpreter and scripting language, built into Unix/Linux systems.
- Mainly automates **Linux commands and OS-level tasks.**
- Ideal for: file operations, system administration, package installation, cron jobs, service management.
- Not designed for complex programming (no real data structures, weak math, clunky string handling).
- Works best only on Unix-like systems (Linux, macOS).
- Windows doesn't run Bash natively — it uses PowerShell instead (Git Bash/WSL exist, but that's a workaround, not Windows' native shell).

### Why Python is needed anyway
- Python is a **full programming language**, not just a command automator.
- Handles complex automation that Shell genuinely can't (real data structures, proper error handling, math).
- Required for modern DevOps automation:
  - AWS / Azure / GCP automation (via SDKs like `boto3`)
  - CI/CD integrations
  - API-based automation
  - CloudOps scripting
- **Cross-platform** — the same script runs on Linux, Windows, and macOS unchanged.
- Clean, easy-to-read syntax — faster automation with fewer lines of code than an equivalent Shell script.

**Easy memory trick:** **Shell = OS-level automation** (low-level, Linux-only). **Python = high-level automation + APIs + DevOps tools** (cross-platform).

| | Shell Scripting | Python |
|---|---|---|
| Runs natively on | Linux/macOS only | Linux, Windows, macOS |
| Best for | OS-level tasks, cron jobs, quick file ops | APIs, cloud SDKs, CI/CD, complex logic |
| Data structures | Very limited | Lists, tuples, sets, dictionaries, classes |
| In this course | Already covered | Starting today — scripting + API automation |

---

## 2. What is Python?

- A **high-level, general-purpose** programming language.
- Clean, readable syntax.
- Supports multiple paradigms:
  - **Object-Oriented** — code organized around classes/objects.
  - **Functional** — code organized around functions.
  - **Procedural** — code organized around step-by-step instructions (what most of our DevOps scripts will look like).
- Real-world uses: web development, data analysis, machine learning, scientific computing, and — **the actual scope of this course** — **DevOps automation.**
- **Our scope specifically:** Python scripting + API automation only — not web dev, not ML.

**OOP concepts Python supports** (we'll come back to these in a later class, just know the names for now):
- Classes
- Objects
- Inheritance
- Encapsulation
- Polymorphism
- Abstraction

---

## 3. What is a program, and what is a variable?

- A **program** is a collection of instructions written in code.
- Those instructions get passed to the computer → the **CPU/Processor** actually executes them.
- Programs exist to **manipulate data** — and that data has to be stored somewhere while the program runs.
- A **variable** is a container used to store that data.

**Example — the same variable, holding different kinds of values over time:**
```python
x = "madhu"    # text
x = 10         # whole number
x = 10.3       # decimal number
x = 3 + 4j     # complex number (rare in DevOps scripting, but Python supports it natively)
```
- Unlike some languages, Python doesn't make you declare a variable's type upfront — `x` can hold a string, then later hold a number, with no extra syntax.

---

## 4. What is a data type?

- A data type defines **what kind of value** a variable is actually storing.

| Category | Python type(s) |
|---|---|
| Text | `str` |
| Numeric | `int`, `float`, `complex` |
| Boolean | `bool` (`True`/`False`) |

**Collection types — one variable, multiple values:**

| Type | Holds |
|---|---|
| `list` | An ordered, changeable collection |
| `tuple` | An ordered, **unchangeable** collection |
| `set` | An unordered collection, no duplicates |
| `dict` (dictionary) | Key-value pairs |

**Example — a list holding mixed data types at once:**
```python
X = [10, 9.8, "KIRAN", True]
```
- Notice `X` holds a number, a decimal, a string, **and** a boolean, all in the same list — Python collections don't force every element to be the same type.

---

## 5. Reading input and printing output — Shell vs Python, side by side

**In Shell:**
```bash
echo "Enter your name"
read name
echo "Value of name is $name"
```

**In Python:**
```python
name = input("Enter your name: ")
print(f"Hello, {name}")
```

⚠️ **A genuinely common beginner mistake, worth seeing once so you don't make it:**
```python
print(f"Hello,", {name})   # ❌ wrong — don't do this
```
This looks like it should print `Hello, madhu` — but it doesn't work the way it looks. The `{name}` here is **outside** the f-string's quotes, so Python doesn't treat it as a placeholder at all — it treats `{name}` as a **set literal** containing the variable's value. If `name = "madhu"`, this actually prints `Hello, {'madhu'}` — with the curly braces and quotes showing up in your output. The placeholder has to live **inside** the f-string itself:
```python
print(f"Hello, {name}")    # ✅ correct — prints: Hello, madhu
```

**A full Shell-script version, for comparison:**
```bash
#!/bin/bash
read -p "Enter your name: " name
echo "Hello, $name"
```
- `read -p "prompt" name` does in **one line** what the earlier `echo` + `read` example did in two — `-p` lets you supply the prompt text directly to `read`.

**Easy memory trick:** Shell's `read` ↔ Python's `input()`. Shell's `$name` ↔ Python's `{name}` — but only **inside** an f-string's quotes, never outside them.

---

## 6. Operators

| Category | Operators | Notes |
|---|---|---|
| **Arithmetic** | `+` `-` `*` `/` `%` | `%` is modulo — the remainder after division |
| **Assignment** | `=` `+=` `-=` `*=` | `a += 2` means `a = a + 2` — a shorthand, not a new operator |
| **Comparison** | `<` `>` `<=` `>=` `==` `!=` | See Shell-equivalents table below |
| **Logical** | `and`, `or`, `not` | Python spells these out as words, not `&&`/`||` like many other languages |
| **Identity** | `is`, `is not` | Checks if two variables point to the **same object** in memory, not just equal values |
| **Membership** | `in`, `not in` | Checks if a value exists inside a list/string/dict |
| **Bitwise** | `&` `|` `^` `~` | Operates on the binary representation of numbers — rare in everyday DevOps scripting, but good to recognize |

**Assignment shorthand, worked out:**
```python
a = 10
a += 2      # same as: a = a + 2
print(a)    # 12
```

**Comparison operators — Python vs Shell's numeric test flags:**

| Python | Meaning | Shell equivalent |
|---|---|---|
| `==` | equal to | `-eq` |
| `!=` | not equal to | `-ne` |
| `<` | less than | `-lt` |
| `<=` | less than or equal to | `-le` |
| `>` | greater than | `-gt` |
| `>=` | greater than or equal to | `-ge` |

---

## 7. Worked example — adding two numbers, Python vs Shell

**Python:**
```python
num1 = float(input("Enter first number: "))
num2 = float(input("Enter second number: "))

sum = num1 + num2

print(f"The sum of {num1} and {num2} is: {sum}")
```
- `input()` **always** returns a `str`, even if the user types a number — that's why `float(...)` wraps around it here. Skip that conversion, and `num1 + num2` would try to *concatenate two strings* instead of adding two numbers (`"3" + "4"` gives `"34"`, not `7`).

**Sample output:**
```
Enter first number: 3
Enter second number: 4
The sum of 3.0 and 4.0 is: 7.0
```

**Shell equivalent:**
```bash
#!/bin/bash

echo "Enter number 1"
read num1

echo "Enter number 2"
read num2

sum=$((num1 + num2))
echo "Sum of 2 numbers: $sum"
```

**Sample output:**
```
Enter number 1
3
Enter number 2
4
Sum of 2 numbers: 7
```
- Shell's `$((...))` does integer arithmetic only — it has no real equivalent of Python's `float()`, so `3.5 + 4.5` simply won't work correctly in plain Bash arithmetic. This is a genuine example of exactly the kind of "Shell can't do it cleanly" gap §1 was talking about.

---

## 8. Common beginner mistakes — quick troubleshooting

| Mistake | What goes wrong | Fix |
|---|---|---|
| Forgetting `float()`/`int()` around `input()` | `num1 + num2` concatenates strings instead of adding numbers | Always wrap numeric input: `int(input(...))` or `float(input(...))` |
| `{name}` outside the f-string's quotes | Prints a literal set (`{'madhu'}`), not the value | Keep the placeholder **inside** the f-string: `f"Hello, {name}"` |
| Forgetting the `f` before the string | `{name}` prints literally as text, not substituted | Write `f"..."`, not just `"..."` |
| Mixing tabs and spaces in indentation | Python errors out (`IndentationError`) — unlike Shell, Python's blocks are defined by indentation itself | Stick to one or the other consistently (spaces are the common convention) |

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Shell vs Python | OS-level automation vs high-level automation + APIs | Shell for cron jobs, Python for AWS SDK (`boto3`) scripts |
| Variable | A container that stores data | `x = "madhu"` |
| Data types | `str`, `int`, `float`, `complex`, `bool` | `x = 10` is an `int` |
| Collection types | `list`, `tuple`, `set`, `dict` | `X = [10, 9.8, "KIRAN", True]` |
| `input()` | Always returns a string | Needs `int()`/`float()` to use as a number |
| f-string | `f"Hello, {name}"` — placeholder goes inside the quotes | `print(f"Hello, {name}")` |
| Comparison operators | `==`/`!=`/`<`/`<=`/`>`/`>=` | Shell equivalents: `-eq`/`-ne`/`-lt`/`-le`/`-gt`/`-ge` |
| OOP concepts (names only, for now) | Class, Object, Inheritance, Encapsulation, Polymorphism, Abstraction | Covered in depth in a later class |
