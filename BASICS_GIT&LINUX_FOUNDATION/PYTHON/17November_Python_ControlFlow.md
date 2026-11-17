# Batch 18 — Running Notes: 17 November 2026

**Topic: Conditionals, Loops, and Lambda Functions**

Friends, this is the third 17 November file — conditionals, both kinds of loops with `break`/`continue`, and lambda functions, again compared against the Shell equivalents you already know.

---

## 1. Conditional expressions — the general shape

```python
if condition1:
    # Block of code to execute if condition1 is True
elif condition2:
    # Block of code to execute if condition1 is False and condition2 is True
elif condition3:
    # Block of code to execute if previous conditions are False and condition3 is True
elif condition4:
    # Block of code to execute if previous conditions are False and condition4 is True
else:
    # Block of code to execute if all previous conditions are False
```
- Python checks each `elif` **in order**, top to bottom, and runs the **first** one that's `True` — it never checks the rest after that.
- `else` only runs if every single condition above it was `False`.

**The class notes' version compares one number against a fixed threshold of 10 — shown here just for the pattern:**
```bash
#!/bin/bash

read -p "Enter a number: " NUMBER

if [ $NUMBER -gt 10 ]; then
    echo "$NUMBER is greater than 10"

elif [ $NUMBER -lt 10 ]; then
    echo "$NUMBER is less than 10"

else
    echo "$NUMBER is equal to 10"

fi
```

**What was actually practiced (`if.py`) compares two numbers against each other instead, not against a fixed 10:**
```python
num1 = int(input("Enter the first number: "))
num2 = int(input("Enter the second number: "))

if num1 > num2:
    print(f"{num1} is greater than {num2}")

elif num1 < num2:
    print(f"{num1} is less than {num2}")

else:
    print(f"{num1} is equal to {num2}")
```
**Sample output** (user enters `15` then `10`):
```
Enter the first number: 15
Enter the second number: 10
15 is greater than 10
```
- Same three-way `if`/`elif`/`else` shape either way — Shell's `-gt`/`-lt` test flags (`13November_Python.md` §6) become Python's plain `>`/`<`. The matching `if.sh` for this two-number version exists as a file but was left **empty** — only the Python side actually got written this time.

---

## 2. While loops

**Shell (`while.sh`):**
```bash
#!/bin/bash

i=0

while [ "$i" -lt 101 ]; do
    echo "Iteration number: $i"
    ((i++))
done

echo "Loop finished!"
```

**Python (`while.py`):**
```python
i = 0

while i < 101:
    print("Iteration number:", i)
    i = i + 1

print("Loop finished!")
```
**Sample output** (both versions — truncated, since this runs 101 times, `i = 0` through `i = 100`):
```
Iteration number: 0
Iteration number: 1
...
Iteration number: 100
Loop finished!
```

---

## 3. `break` and `continue`

- **`break`** — exits the loop immediately, for good. Nothing after it in the loop runs again.
- **`continue`** — skips just the **rest of the current iteration**, then goes straight back to re-checking the loop's condition for the next one.

**`break` example:**
```python
i = 0

while i < 101:
    print("Iteration number:", i)

    if i == 5:
        print("Reached 5, breaking the loop.")
        break

    i = i + 1

print("Loop finished!")
```
**Sample output:**
```
Iteration number: 0
Iteration number: 1
Iteration number: 2
Iteration number: 3
Iteration number: 4
Iteration number: 5
Reached 5, breaking the loop.
Loop finished!
```
- The loop never reaches `i = 100` at all — `break` stops it dead at `i = 5`.

**`continue` example:**
```python
i = 0

while i < 101:

    if i == 5:
        i += 1
        continue

    print("Iteration number:", i)

    i = i + 1

print("Loop finished!")
```
**Sample output** (truncated — the loop still runs all the way to `i = 100`, it just never prints `5`):
```
Iteration number: 0
Iteration number: 1
Iteration number: 2
Iteration number: 3
Iteration number: 4
Iteration number: 6
Iteration number: 7
...
Iteration number: 100
Loop finished!
```
- ⚠️ The key difference from `break`: **`continue` doesn't stop the loop** — it only skips printing on the one iteration where `i == 5`, then keeps going all the way to 100 like normal.

**Easy memory trick:** `break` = **leave the building**. `continue` = **skip this one step, keep walking**.

---

## 4. For loops

- A `for` loop walks through every item in a list (or any other iterable), one at a time.

```python
for variable in iterable:
    # Block of code to execute
```

**Looping over a list directly:**
```python
mc_list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

for mc in mc_list:
    print(f"Processing mc value: {mc}")
```
**Sample output:**
```
Processing mc value: 1
Processing mc value: 2
Processing mc value: 3
Processing mc value: 4
Processing mc value: 5
Processing mc value: 6
Processing mc value: 7
Processing mc value: 8
Processing mc value: 9
Processing mc value: 10
```

**Looping over a `range()` instead of a real list:**
```python
for i in range(50, 101):
    print("Iteration number:", i)
```
- Runs for `i = 50` through `i = 100` (51 iterations) — output truncated here for space.

```python
for i in range(5):     # range(n) → 0 up to (but not including) n
    print(i)
```
**Sample output:**
```
0
1
2
3
4
```

```python
for number in range(1, 11):   # range(k, n) → k up to (but not including) n
    print(number)
```
**Sample output:**
```
1
2
3
4
5
6
7
8
9
10
```
- ⚠️ **`range(n)` stops one short of `n`.** `range(5)` gives `0,1,2,3,4` — five numbers, not six. This trips up almost everyone the first time.

**Looping over a list of strings:**
```python
fruits = ["apple", "banana", "cherry"]

for fruit in fruits:
    print(fruit)
```
**Sample output:**
```
apple
banana
cherry
```

**A plain function, for comparison:**
```python
def add(a, b):
    return a + b

result = add(3, 5)
print(result)
```
**Sample output:**
```
8
```

---

## 5. Lambda functions

- A **lambda** is a small, **anonymous** function — defined in one line with the `lambda` keyword, with no `def` and no name of its own (though you can still assign it to a variable, as below).

```
lambda arguments: expression
```
- `lambda` — the keyword that starts it.
- `arguments` — the input parameters, same idea as a normal function's parameters.
- `expression` — a single expression, whose result is automatically returned (no `return` keyword needed).

```python
sum = lambda a, b: a + b

print("Sum of 5 and 3 is:", sum(5, 3))
print("Sum of 10 and 20 is:", sum(10, 20))
```
**Sample output:**
```
Sum of 5 and 3 is: 8
Sum of 10 and 20 is: 30
```
- ⚠️ Same gotcha as `17November_Python_Collections_Methods.md`'s `4-sum.py`: naming this `sum` **shadows** Python's built-in `sum()` function for the rest of this script. Fine here, since nothing else needs the real `sum()`, but worth being deliberate about.
- A lambda is best for a short, throwaway expression used once (e.g. as a `sort()` key) — anything longer or reused in several places is clearer as a normal `def` function.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `if`/`elif`/`else` | Checks conditions top to bottom, runs the first match | Branching a deploy script based on environment name |
| `while` loop | Repeats while a condition stays `True` | Polling a service's health check until it's ready |
| `break` | Exits the loop immediately | Stop retrying once a connection succeeds |
| `continue` | Skips just this iteration, keeps looping | Skip a malformed log line, keep processing the rest |
| `for x in list` | Walks through every item once | Running the same check against every server in a list |
| `range(n)` | Stops **before** `n` — `range(5)` is `0`–`4` | `range(len(my_list))` for index-based looping |
| `lambda` | A one-line, unnamed function | A quick `sort(key=lambda x: x[1])`-style helper |
