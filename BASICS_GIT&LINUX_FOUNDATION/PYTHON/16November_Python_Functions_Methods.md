# Batch 18 — Running Notes: 16 November 2026

**Topic: Python Functions, Debugging, and Built-In Methods vs Functions**

Friends, today's second half moves from data (`16November_Python_DataTypes.md`) to behavior — functions, how to debug both Shell and Python scripts, the actual built-in operations available on each collection type, and the genuinely important distinction between a **function** and a **method**.

---

## 1. Why functions?

- A function is a block of code written once, for repeated use.
- Groups a set of commands into a single, reusable unit.
- Breaks a script's total functionality into logical sub-sections.
- Encapsulates and reuses code, instead of copy-pasting it.
- Can be called whenever needed, as many times as needed.
- Makes scripts more organized, modular, and easier to maintain.

**Installing Python, for reference:**

| Platform | Command |
|---|---|
| Linux (yum-based) | `yum install python -y` |
| Linux (apt-based) | `apt install python -y` |
| Windows | Download the installer from python.org and run it |

---

## 2. Functions — Shell vs Python, side by side

**Shell (`1-greet.sh`):**
```bash
#!/bin/bash

greet() {
    echo "Hello, $1!"
}

greet "Madhu"
greet "Kiran"
greet "Anu"
greet "Ravi"
greet "Sita"
```
**Sample output:**
```
Hello, Madhu!
Hello, Kiran!
Hello, Anu!
Hello, Ravi!
Hello, Sita!
```

**Python (`2-greet.py`):**
```python
def greet(name):
    print(f"Hello, {name}!")

greet("Madhu")
greet("Kiran")
greet("Ravi")
greet("Anita")
greet("Sita")
greet("John")
```
**Sample output:**
```
Hello, Madhu!
Hello, Kiran!
Hello, Ravi!
Hello, Anita!
Hello, Sita!
Hello, John!
```
- `$1` in Shell ↔ `name` in Python — both are the **parameter** the function receives when called.

**A function that adds two numbers — Shell (`3-sum.sh`):**
```bash
#!/bin/bash

sum() {
    num1=$1
    num2=$2
    result=$(( $1 + $2 ))
    echo "The sum of $1 and $2 is: $result"
}

sum 5 10
sum 20 30
sum 7 3
```
**Sample output:**
```
The sum of 5 and 10 is: 15
The sum of 20 and 30 is: 50
The sum of 7 and 3 is: 10
```

**Same idea in Python (`4-sum.py`):**
```python
def sum_numbers(num1, num2):
    sum = num1 + num2
    print(f"The sum of {num1} and {num2}: {sum}")

sum_numbers(10, 20)
sum_numbers(5, 15)
sum_numbers(7, 8)
```
**Sample output:**
```
The sum of 10 and 20: 30
The sum of 5 and 15: 20
The sum of 7 and 8: 15
```
⚠️ Naming the local variable `sum` here **shadows** Python's own built-in `sum()` function — only *inside* this function's body, so it doesn't break anything in this script, but it's worth knowing the name exists. We'll meet the real `sum()` function again in §4 below.

**A function that *returns* a value instead of printing it directly (`5-sum_return.py`):**
```python
def sum_numbers(num1, num2):
    sum = num1 + num2
    return sum

num1 = float(input("Enter first number: "))
num2 = float(input("Enter second number: "))

output = sum_numbers(num1, num2)
print(f"The sum of {num1} and {num2}: {output}")
```
**Sample output** (user enters `10` and `20`):
```
Enter first number: 10
Enter second number: 20
The sum of 10.0 and 20.0: 30.0
```
- The difference from `4-sum.py`: that version **prints inside the function** and returns nothing useful; this version **returns the result** with `return sum`, so the caller decides what to do with it (here, printing it) — a function with `return` is reusable in more places, since the value can be stored, passed on, or used in a calculation, not just displayed.

**Easy memory trick:** Shell functions take arguments as `$1`, `$2`, ... Python functions take them as named parameters. A function that `print`s is a dead end; a function that `return`s hands the value back to whoever called it.

---

## 3. Debugging / tracing a script

| Language | Command | What it shows |
|---|---|---|
| Python | `python3 -m trace --trace script.py` | Prints every line as it executes |
| Shell | `set -x` (inside the script) | Prints every command as it runs, with its expanded variable values |

**Shell debugging example (`set -x`):**
```bash
#!/bin/bash

set -x
sum() {
    result=$(( $1 + $2 ))
    echo "The sum of $1 and $2 is $result"
}

sum 5 10
sum 20 30
sum 100 250
```
**Sample output** (note the `+` lines — that's `set -x` showing each command before it runs):
```
+ sum 5 10
+ result=15
+ echo 'The sum of 5 and 10 is 15'
The sum of 5 and 10 is 15
+ sum 20 30
+ result=50
+ echo 'The sum of 20 and 30 is 50'
The sum of 20 and 30 is 50
+ sum 100 250
+ result=350
+ echo 'The sum of 100 and 250 is 350'
The sum of 100 and 250 is 350
```

---

## 4. Built-in operations — List, Tuple, Set, Dictionary

### List operations (`6-list_ops.py`)
```python
my_list = [1, 2, 3, 1, 4, 5]
```

| Operation | Code | Result after running it |
|---|---|---|
| Add one item to the end | `my_list.append(4)` | `[1, 2, 3, 1, 4, 5, 4]` |
| Add several items to the end | `my_list.extend([8, 9, 7])` | `[1, 2, 3, 1, 4, 5, 4, 8, 9, 7]` |
| Insert at a specific position | `my_list.insert(0, 10)` | `[10, 1, 2, 3, 1, 4, 5, 4, 8, 9, 7]` |
| Remove the **first** matching value | `my_list.remove(1)` | `[10, 2, 3, 1, 4, 5, 4, 8, 9, 7]` |
| Remove and **return** the last item | `popped_element = my_list.pop()` | returns `7`; list becomes `[10, 2, 3, 1, 4, 5, 4, 8, 9]` |
| Find a value's position | `my_list.index(9)` | `8` |
| Count how many times a value appears | `my_list.count(1)` | `1` |
| Sort in place | `my_list.sort()` | `[1, 2, 3, 4, 4, 5, 8, 9, 10]` |
| Reverse in place | `my_list.reverse()` | `[10, 9, 8, 5, 4, 4, 3, 2, 1]` |
| Make an independent copy | `copied_list = my_list.copy()` | `[10, 9, 8, 5, 4, 4, 3, 2, 1]` |
| Empty the list | `my_list.clear()` | `[]` |

**After `clear()`, using built-in functions on the untouched `copied_list`:**
```python
print("Length of copied list:", len(copied_list))   # 9
print("Maximum:", max(copied_list))                  # 10
print("Minimum:", min(copied_list))                  # 1
print("Sum:", sum(copied_list))                      # 46
```
- `len()`/`max()`/`min()`/`sum()` are **functions**, not methods — see §5 for exactly why that distinction matters.

---

### Tuple operations (`7-tuple_ops.py`) — immutable, so far fewer methods exist
```python
my_tuple = (3, 1, 4, 1, 5, 9, 2, 6, 5)
```

| Operation | Code | Result |
|---|---|---|
| Count occurrences | `my_tuple.count(1)` | `2` |
| Find a value's position | `my_tuple.index(9)` | `5` |
| Length | `len(my_tuple)` | `9` |
| Maximum | `max(my_tuple)` | `9` |
| Minimum | `min(my_tuple)` | `1` |
| Sum | `sum(my_tuple)` | `36` |
| Sort (returns a new **list**, doesn't touch the tuple) | `sorted_list = sorted(my_tuple)` | `[1, 1, 2, 3, 4, 5, 5, 6, 9]` |

- `sorted_list.append(4)` **works fine** here — `sorted()` handed back a plain `list`, and lists are mutable. Result: `[1, 1, 2, 3, 4, 5, 5, 6, 9, 4]`.
- `my_tuple.append(4)` **crashes the script**, because tuples have no `.append()` method at all:
```
AttributeError: 'tuple' object has no attribute 'append'
```
- ⚠️ **Tuples simply don't have `append()`/`remove()`/`pop()`/etc.** — not because they're blocked, but because those methods were never defined for the tuple type in the first place, since a tuple is meant to never change after creation.

---

### Set operations (`8-set_ops.py`)
```python
my_set = {1, 2, 1, 3, 4, 5}   # duplicates auto-removed on creation
```

| Operation | Code | Result |
|---|---|---|
| Add one element | `my_set.add(6)` | now contains `6` too |
| Remove a specific element | `my_set.remove(4)` | `4` is gone |
| Remove and return an arbitrary element | `popped = my_set.pop()` | removes *some* element — sets have no order, so you can't predict which one |
| Empty the set | `my_set.clear()` | `set()` (empty) |

**Set math, between two separate sets:**
```python
set_a = {1, 2, 3}
set_b = {3, 4, 5}

print("Union:", set_a.union(set_b))               # {1, 2, 3, 4, 5}
print("Intersection:", set_a.intersection(set_b)) # {3}
print("Difference:", set_a.difference(set_b))     # {1, 2}
```
- ⚠️ **A set's printed order is never guaranteed** — don't rely on the order you happen to see in one run; two runs (or two machines) can legitimately print the same set's contents in a different order.

---

### Dictionary operations (`9-dict-ops.py`)
```python
my_dict = {
    "name": "Madhu",
    "phone": "7396627149",
    "city": "Hyderabad"
}
```

| Operation | Code | Result |
|---|---|---|
| Read a value by key | `my_dict['name']` | `'Madhu'` |
| Read a value, safely (no crash if key is missing) | `my_dict.get('phone')` | `'7396627149'` |
| Read a missing key, with a fallback | `my_dict.get('salary', 'Not Available')` | `'Not Available'` |
| Add/update a key | `my_dict['occupation'] = 'DevOps Engineer'` | key added |
| Remove a key, and get its value back | `popped_value = my_dict.pop('phone')` | returns `'7396627149'` |
| List all keys | `list(my_dict.keys())` | `['name', 'city', 'occupation']` |
| List all values | `list(my_dict.values())` | `['Madhu', 'Hyderabad', 'DevOps Engineer']` |
| List all key-value pairs | `list(my_dict.items())` | `[('name', 'Madhu'), ('city', 'Hyderabad'), ('occupation', 'DevOps Engineer')]` |
| Empty the dict | `my_dict.clear()` | `{}` |

**Making an independent copy — a fresh, separate dict:**
```python
new_dict = {'a': 1, 'b': 2}
copied_dict = new_dict.copy()
print("Copied:", copied_dict)   # Copied: {'a': 1, 'b': 2}
```

- ⚠️ `my_dict['salary']` (square-bracket access on a missing key) would **crash** with `KeyError: 'salary'` — that's exactly why `.get('salary', 'Not Available')` is the safer way to read a key that might not exist.
- Unlike a set, a **dict's order is reliable** — Python guarantees (since 3.7) that a dict remembers the order keys were inserted in.

---

## 5. Functions vs Methods — the distinction that actually matters

### What is a function?
- A standalone block of code, **not tied to any object.**
- Takes data as an argument.
- Returns a result.
- Called like: `function_name(data)`.
- Examples already used above: `len(my_list)`, `max(copied_list)`, `sum(copied_list)`.

### What is a method?
- A function that **belongs to an object.**
- Defined inside that object's class.
- Called like: `object.method(arguments)` — the object comes first, joined with a dot.
- Examples already used above: `my_list.append(4)`, `my_list.sort()`, `my_dict.get('phone')`.

### Why `append()` is not a function
```python
append(my_list, 4)   # ❌ invalid — Python has no standalone append() function
```
`append` only exists as a **method defined inside the list class** — there's no free-floating `append()` function to call it as. The only correct form is:
```python
my_list.append(4)    # ✅ correct
```

### Why `len()` is not a method
```python
my_list.len()   # ❌ invalid — lists don't have a .len() method
```
`len()` is a **built-in function**, not something that belongs to the list object. The only correct form is:
```python
len(my_list)    # ✅ correct
```

### Side by side

| Feature | Function | Method |
|---|---|---|
| Belongs to an object | No | Yes |
| Called as | `function(x)` | `x.method()` |
| Defined in | Global scope / a module | Inside a class |
| Needs the object | Passed in as an argument | Implicit (it's the thing before the dot) |
| Example | `len(x)` | `x.append(4)` |

**Easy memory trick:** `object.something()` → it's a **method**. `something(object)` → it's a **function**.

### Why Python has both
- **Functions** are generic — they work across many different data types (`len()` works on a list, a string, a dict, a tuple — anything with a length).
- **Methods** are specific to one particular data type, and know how to modify or act on that exact kind of object (`list.append()` only makes sense for a list; `str.upper()` only makes sense for a string).

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Function with `print` vs `return` | `print` is a dead end; `return` hands the value back to the caller | `5-sum_return.py` reuses the returned sum in another `print` |
| `python3 -m trace --trace script.py` | Prints every line as it executes | Debugging a misbehaving Python automation script |
| Shell `set -x` | Prints every command (with expanded values) as it runs | Debugging a misbehaving Shell script |
| List methods | `append`/`extend`/`insert`/`remove`/`pop`/`sort`/`reverse`/`copy`/`clear` | Managing a list of server IPs as the cluster changes |
| Tuple | Has `count()`/`index()` only — no methods that modify it | Crashes with `AttributeError` if you try `.append()` |
| Set | `add`/`remove`/`pop`/`clear`, plus `union`/`intersection`/`difference` | Order is never guaranteed — don't rely on it |
| Dict | `.get(key, default)` avoids a `KeyError` on a missing key | Reading an optional config value with a sane fallback |
| Function vs Method | `object.something()` = method; `something(object)` = function | `my_list.append(4)` vs `len(my_list)` |
