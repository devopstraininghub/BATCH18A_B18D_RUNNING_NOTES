# Batch 18 — Running Notes: 16 November 2026

**Topic: Python Functions — Shell vs Python, and Debugging**

Friends, today's second half moves from data (`16November_Python_DataTypes.md`) to behavior — functions, and how to debug both Shell and Python scripts. The built-in operations per collection type, and functions vs methods, are big enough topics of their own that they get `17November_Python_Collections_Methods.md`.

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
⚠️ Naming the local variable `sum` here **shadows** Python's own built-in `sum()` function — only *inside* this function's body, so it doesn't break anything in this script, but it's worth knowing the name exists. We'll meet the real `sum()` function in `17November_Python_Collections_Methods.md`.

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

**A real `python3 -m trace --trace` run, against a version of `4-sum.py` with three different calls:**
```bash
$ python3 -m trace --trace 4-sum.py
```
**Actual output:**
```
 --- modulename: 4-sum, funcname: <module>
4-sum.py(3):  def sum_numbers(num1, num2):
4-sum.py(8):  sum_numbers(10,20)
 --- modulename: 4-sum, funcname: sum_numbers
4-sum.py(4):      sum = num1 + num2
4-sum.py(5):      print(f"The sum of {num1} & {num2} is {sum}" )
The sum of 10 & 20 is 30
4-sum.py(9):  sum_numbers(30,40)
 --- modulename: 4-sum, funcname: sum_numbers
4-sum.py(4):      sum = num1 + num2
4-sum.py(5):      print(f"The sum of {num1} & {num2} is {sum}" )
The sum of 30 & 40 is 70
4-sum.py(10):  sum_numbers(50,60)
 --- modulename: 4-sum, funcname: sum_numbers
4-sum.py(4):      sum = num1 + num2
4-sum.py(5):      print(f"The sum of {num1} & {num2} is {sum}" )
The sum of 50 & 60 is 110
```
- Notice `trace` prints the **file name + line number** before each line runs (`4-sum.py(4): ...`), and announces every time it enters a new function (`--- modulename: 4-sum, funcname: sum_numbers`) — this is exactly how you'd pinpoint which line in a misbehaving script actually ran, and in what order, when `print()` statements alone aren't giving you enough detail.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| Function with `print` vs `return` | `print` is a dead end; `return` hands the value back to the caller | `5-sum_return.py` reuses the returned sum in another `print` |
| `python3 -m trace --trace script.py` | Prints every line (and its file/line number) as it executes | Pinpointing exactly which line ran, in what order, in a misbehaving automation script |
| Shell `set -x` | Prints every command (with expanded values) as it runs | Debugging a misbehaving Shell script |
| `$1`/`$2` vs named parameters | Shell functions take positional args; Python functions take named parameters | `greet "Madhu"` vs `greet("Madhu")` |
| Variable shadowing a built-in | Naming a local variable `sum` hides the built-in `sum()` function, only inside that function | `4-sum.py`'s `sum = num1 + num2` |
