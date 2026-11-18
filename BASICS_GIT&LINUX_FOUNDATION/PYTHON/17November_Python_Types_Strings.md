# Batch 18 — Running Notes: 17 November 2026

**Topic: Dynamic vs Static Typing, String Methods, and Numeric Types**

Friends, this continues `17November_Python_Collections_Methods.md` — same date, a different thread: what Python's typing model is actually called, then the built-in methods for working with text and numbers.

---

## 1. Static typing vs dynamic typing

- **Dynamic typing** (what Python uses): a variable's type is decided **at runtime**, not in advance. You never declare a type before assigning.
- **Static typing**: a variable's type is fixed **at compile time** — you must declare it up front, and it can't change afterward. C, C++, Go, and Java are statically typed.

```python
x = 10        # int
x = "madhu"   # now a string — perfectly legal in Python
x = 10.2      # now a float
x = 4 + 3j    # now a complex number
```
- This is the exact same behavior already shown back in `13November_Python.md` §3 — today just gives it its proper name: **dynamic typing.**

**Easy memory trick:** **Dynamic** = decided **d**uring **d**oing (runtime). **Static** = decided **before** you start (compile time).

---

## 2. String manipulation — built-in methods and functions (`5-string-ops.py`)

**Complete script:**
```python
my_string = "Hello, Welcome to Aws Devops World"

# 1. Length of the string
print(f"Length of the string: {len(my_string)}")

# 2. Convert to uppercase and lowercase
print(f"Uppercase: {my_string.upper()}")
print(f"Lowercase: {my_string.lower()}")

# 3. Count occurrences of a substring
substring = "Welcome"
print(f"Occurrences of '{substring}': {my_string.count(substring)}")

# 4. Check if the string starts or ends with a particular substring
print(f"Starts with 'Hello': {my_string.startswith('Hello')}")
print(f"Ends with 'World': {my_string.endswith('World')}")

# 5. Find the index of a substring (first occurrence)
print(f"Index of 'World': {my_string.find('World')}")

# 6. Replace a substring with another substring
new_string = my_string.replace('Aws', 'Cloud')
print(f"Original string: {my_string}")
print(f"Modified string: {new_string}")

# 7. Split the string into a list based on a delimiter
words = my_string.split()
print(f"Split into words: {words}")

# 8. Check if all characters are alphanumeric
alphanumeric_string = "Python123$@"
print(f"Is Python alphanumeric? {alphanumeric_string.isalnum()}")

# 9. Convert string to title case
title_case_string = "python programming language"
print(f"Title case: {title_case_string.title()}")
```

**Sample output:**
```
Length of the string: 34
Uppercase: HELLO, WELCOME TO AWS DEVOPS WORLD
Lowercase: hello, welcome to aws devops world
Occurrences of 'Welcome': 1
Starts with 'Hello': True
Ends with 'World': True
Index of 'World': 29
Original string: Hello, Welcome to Aws Devops World
Modified string: Hello, Welcome to Cloud Devops World
Split into words: ['Hello,', 'Welcome', 'to', 'Aws', 'Devops', 'World']
Is Python alphanumeric? False
Title case: Python Programming Language
```

**What each method does:**

| Method | What it does | This example's result |
|---|---|---|
| `len(s)` | Counts the characters in the string | `34` |
| `s.upper()` / `s.lower()` | Changes the whole string's case | `HELLO, ...` / `hello, ...` |
| `s.count(sub)` | Counts how many times a substring appears | `1` occurrence of `"Welcome"` |
| `s.startswith(sub)` / `s.endswith(sub)` | Checks the start/end of the string | Both `True` here |
| `s.find(sub)` | Position of the first match (returns `-1` if not found) | `29` |
| `s.replace(old, new)` | Returns a **new** string with replacements made — the original is untouched | `Aws` → `Cloud` |
| `s.split()` | Breaks the string into a list, splitting on whitespace by default | `['Hello,', 'Welcome', ...]` |
| `s.isalnum()` | `True` only if **every** character is a letter or digit — no spaces, no punctuation | `False` for `"Python123$@"`, because of the `$` and `@` |
| `s.title()` | Capitalizes the first letter of every word | `"python programming language"` → `"Python Programming Language"` |

- ⚠️ `s.replace(...)` doesn't modify `my_string` itself — strings in Python are **immutable**, exactly like tuples (§2 of `17November_Python_Collections_Methods.md`). That's why the script prints both the untouched `Original string` and a separately-stored `Modified string`.

---

## 3. Numeric types and type conversion (`6-arth-ops.py`)

**Complete script:**
```python
# Integer examples
x = 10
y = 5
z = 0

# Floating-point examples
a = 3.14
b = -0.001

# Print examples
print(f"Integers: x = {x}, y = {y}, z = {z}")
print(f"Floating-point numbers: a = {a}, b = {b}")

# Arithmetic operations
print(f"\nArithmetic Operations:")
print(f"x + y = {x + y}")   # Addition
print(f"x - y = {x - y}")   # Subtraction
print(f"x * y = {x * y}")   # Multiplication
print(f"x / y = {x / y}")   # Division
print(f"x % y = {x % y}")   # Modulus

# Type conversions
print(f"\nType Conversions:")
f = float(x)
print(f"Convert int {x} to float: f = {f}")

g = int(a)
print(f"Convert float {a} to int: g = {g}")
```

⚠️ An earlier version of this class example used a floating-point `print` line that referenced a variable `c` which was never actually defined, which would have crashed with `NameError: name 'c' is not defined` — the real practice script above is already clean, only printing the two floats that actually exist, `a` and `b`.

**Sample output:**
```
Integers: x = 10, y = 5, z = 0
Floating-point numbers: a = 3.14, b = -0.001

Arithmetic Operations:
x + y = 15
x - y = 5
x * y = 50
x / y = 2.0
x % y = 0

Type Conversions:
Convert int 10 to float: f = 10.0
Convert float 3.14 to int: g = 3
```

**What's happening:**

| Operation | Code | Result | Why |
|---|---|---|---|
| Division | `x / y` | `2.0` | `/` always returns a `float` in Python, even when the result is a whole number |
| Modulus | `x % y` | `0` | `10 % 5` — `10` divides evenly by `5`, so the remainder is `0` |
| int → float | `float(x)` | `10.0` | Adds the decimal point, value unchanged |
| float → int | `int(a)` | `3` | **Truncates** toward zero — it does not round. `int(3.9)` still gives `3`, not `4` |

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Dynamic typing | Python decides a variable's type at runtime | `x = 10` then `x = "madhu"` — both legal |
| Static typing | Type fixed at compile time, declared upfront | C, C++, Go, Java |
| String methods | `upper`/`lower`/`count`/`startswith`/`endswith`/`find`/`replace`/`split`/`isalnum`/`title` | Parsing a log line, or cleaning a hostname before using it |
| Strings are immutable | `.replace()` returns a new string; the original never changes | Same category as tuples |
| `x / y` | Always returns a `float` in Python 3 | `10 / 5` → `2.0`, not `2` |
| `int(a)` | Truncates toward zero, doesn't round | `int(3.14)` → `3`, `int(3.9)` → `3` |
