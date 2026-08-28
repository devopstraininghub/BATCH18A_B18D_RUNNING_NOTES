# Batch 18 — Linux Running Notes: 28 August 2026

**Topic: Shell Scripting Continued — Conditionals (`if`/`elif`/`else`), Loops (`for`/`while`/`until`), `break`/`continue`, Bash Operators, Functions, Production Best Practices, Real-Time One-Liners**

Friends, yesterday we covered the building blocks — variables, arguments, debugging. Today we make scripts actually **think and repeat**: conditionals to make decisions, loops to repeat work, operators to compare/calculate, functions to reuse logic, and the production habits that separate a "college script" from one companies actually trust in production.

---

## 1. Conditionals — `if` / `elif` / `else`

A conditional lets a script **make a decision** — run one block of commands if something is true, and a completely different block if it isn't. Exactly the "if this, then that" logic you already use in everyday life, nothing new conceptually.

**The general shape:**
```bash
if [ condition1 ]; then
    echo "Condition is true"
elif [ condition2 ]; then
    echo "Condition is true"
elif [ condition3 ]; then
    echo "Condition is true"
else
    echo "Condition is false"
fi
```
- `if [ condition ]; then` — checks the condition; if true, runs the lines below it.
- `elif` (short for "else if") — if the first condition was false, check this next one instead. You can chain as many `elif`s as you need, no limit.
- `else` — a catch-all: if none of the above conditions turned out true, run this block instead.
- `fi` — this is just `if` spelled backwards, and it's how Bash knows the `if` block has properly ended. Every `if` must be closed with a matching `fi`, or you'll get an error.

**Example — checking a person's age, using a command-line argument:**
```bash
#!/bin/bash
age=$1

if [ "$age" -gt 18 ]; then
    echo "The person is a Major"
elif [ "$age" -lt 18 ]; then
    echo "The person is Minor"
else
    echo "The person's age is exactly 18, person is a Major"
fi
```
- `age=$1` — instead of asking interactively with `read`, the age is taken directly as the first command-line argument.
- `-gt` means "greater than," `-lt` means "less than" — this is how Bash compares **numbers** inside `[ ]`. You cannot use plain `>`/`<` for numbers here the way you would in normal maths — a common beginner mistake.
- If age is above 18 → "Major". If below 18 → "Minor". If neither (meaning exactly 18) → falls through to the `else` block.

**Sample output:**
```
$ ./person.sh 25
The person is a Major
```

**Example — same logic, but with user input via `read` instead of an argument:**
```bash
#!/bin/bash
echo "enter number"
read num1

if [ "$num1" -gt 10 ]; then
    echo "$num1 is greater than 10"
elif [ "$num1" -lt 10 ]; then
    echo "$num1 is less than 10"
else
    echo "$num1 is 10"
fi
```

**Example — comparing a fixed number, using `-eq`:**
```bash
#!/bin/bash
number=7

if [ "$number" -gt 10 ]; then
    echo "The number is greater than 10."
elif [ "$number" -eq 10 ]; then
    echo "The number is exactly 10."
else
    echo "The number is less than 10."
fi
```
This introduces **`-eq`** — "equal to." So the full family of number-comparison operators is: `-gt` (greater than), `-lt` (less than), `-eq` (equal to), `-ge` (greater than or equal), `-le` (less than or equal). Worth remembering all five, they come up everywhere.

**Easy memory trick:** `fi` = `if` backwards, closes the block.

---

## 2. Loops — `for`, `while`, `until`

A loop repeats a block of commands automatically, so you don't have to write (or copy-paste) the same line 100 times by hand. Bash has three types:

- **`for` loop** — repeat once for each item in a known list (say, "for every number from 1 to 100").
- **`while` loop** — keep repeating **as long as** a condition stays true.
- **`until` loop** — keep repeating **until** a condition finally turns true (exact opposite of `while`).

**`for` loop:**
```bash
for i in {100..1}
do
     echo "The number is $i"
done
```
- `{100..1}` is Bash's shorthand for "every number from 100 down to 1."
- For each number in that range, `i` gets set to it, and the loop body (`echo "The number is $i"`) runs once for that value.
- `done` closes the loop, the same way `fi` closes an `if`.

**Output (first few lines):**
```
The number is 100
The number is 99
The number is 98
...
The number is 1
```

**`while` loop — counting up:**
```bash
i=1
while [ "$i" -le 100 ]; do
    echo "the number is: $i"
    i=$((i + 1))
done
```
- `i=1` — start a counter at 1.
- `while [ "$i" -le 100 ]` — keep looping **as long as** `i` is less than or equal to 100.
- `i=$((i + 1))` — this is how you do maths in Bash: `$(( ... ))` evaluates an arithmetic expression. Here it adds 1 to `i` on every pass, so the loop eventually reaches 100 and stops. Without this line, the loop would never end (see "Infinite Loops" below — this is exactly how that mistake happens).

**`while` loop — counting down instead:**
```bash
i=100
while [ "$i" -ge 1 ]; do
    echo "the number is: $i"
    i=$((i - 1))
done
```
Same idea, just flipped: start at 100, keep going **while `i` is greater than or equal to 1**, and *subtract* 1 each time instead of adding.

**`until` loop — counting up:**
```bash
i=1
until [ "$i" -gt 100 ]; do
        echo "the number is : $i"
        i=$((i + 1))
done
```
`until` is simply `while`'s mirror image: instead of "keep going *while* true," it means "keep going *until* this becomes true." Here it counts from 1 to 100, and stops the moment `i` becomes greater than 100.

**`until` loop — counting down instead:**
```bash
i=10
until [ "$i" -lt 1 ]; do
        echo "the number is : $i"
        i=$((i - 1))
done
```
Counts down from 10, and stops once `i` drops below 1.

**Easy memory trick:** `for` → known list. `while` → keep going while true. `until` → keep going till it's true.

---

## 3. Infinite loops

```bash
i=1
while [ "$i" -gt 0 ]; do
   echo "the number is : $i"
   i=$((i + 1))
done
```
`i` only ever grows, so `"$i" -gt 0` is *always* true — the loop never stops on its own; you'd kill it with `Ctrl+C`.

**Real-time example:** Usually a bug (forgot to update the counter) — but sometimes written on purpose, e.g. a monitoring script that checks a service's health forever, every few seconds, until someone deliberately stops it.

---

## 4. `break` and `continue`

- **`break`** — stop the loop immediately, completely, no matter how many repeats were left.
- **`continue`** — skip just this one pass, jump to the next repeat; the loop itself keeps running.

```bash
if [ "$i" -eq 6 ]; then
    break        # stops the loop entirely at 6
fi
```
```bash
if [ "$i" -eq 6 ]; then
    i=$((i + 1))
    continue     # skips only 6, keeps counting after
fi
```
⚠️ With `continue`, increment `i` **before** calling it — otherwise the loop gets stuck re-checking the same value forever.

**Real-time example:** Looping through a list of servers doing health checks:
```bash
if service_down; then
   continue   # skip this one, check the next service
fi
if critical_service_down; then
   break      # stop the whole pipeline immediately
fi
```
A non-critical service down → skip and keep checking others. A critical service down → stop everything right now, no point checking further.

---

## 5. Bash operators

Operators are the symbols Bash uses to do maths, compare values, and check conditions. Let's go through each family one by one.

### Arithmetic operators (for numbers)

```
+   Addition
-   Subtraction
*   Multiplication
/   Division
%   Modulus (remainder after division)
**  Power
```
```bash
a=10
b=3

echo $((a + b))     # 13
echo $((a - b))     # 7
echo $((a * b))     # 30
echo $((a / b))     # 3   (integer division — Bash drops the decimal part)
echo $((a % b))     # 1   (remainder of 10 divided by 3)
echo $((a ** 2))    # 100 (10 raised to power 2)
```
`$(( ... ))` is the standard way of doing arithmetic in Bash — anything inside these double parentheses is treated as a maths expression, not as text.

### Relational operators (numeric comparison)

Used inside `[ ]`, for comparing two numbers:
```
-eq  Equal
-ne  Not equal
-gt  Greater than
-lt  Less than
-ge  Greater or equal
-le  Less or equal
```
```bash
if [ "$a" -gt "$b" ]; then
    echo "a is greater than b"
fi
```
Remember — for numbers, use these word-style operators (`-gt`, `-lt`, etc.) inside `[ ]`, not the maths symbols `>`/`<`, which mean something totally different in Bash (file redirection).

### String operators

```
=    Equal
!=   Not equal
-z   String is empty
-n   String is not empty
```
```bash
name="linux"

if [ "$name" = "linux" ]; then
    echo "Correct string"
fi
```
```bash
if [ -z "$var" ]; then
    echo "Variable is empty"
fi
```
`-z` is extremely useful for checking "did the user actually provide a value, or did they leave it blank?" — a very common check in real scripts before proceeding further.

### Boolean / logical operators

```
&&   Logical AND
||   Logical OR
!    Logical NOT
```
```bash
if [ "$a" -gt 5 ] && [ "$b" -lt 10 ]; then
    echo "Both conditions are true"
fi

if [ "$a" -lt 5 ] || [ "$b" -lt 5 ]; then
    echo "At least one condition is true"
fi
```
`&&` means "both sides must be true," `||` means "at least one side must be true" — same logic as everyday English "AND" and "OR."

### File test operators (very important, commonly used)

```
-f  File exists
-d  Directory exists
-e  File or directory exists
-r  Readable
-w  Writable
-x  Executable
-s  File not empty
```
```bash
if [ -f "/etc/passwd" ]; then
    echo "File exists"
fi
```
**Real-time example:** Before a script reads a config file or runs another script, always check `-f` (does it exist?) and `-x` (is it executable?) first — otherwise the script crashes halfway through with a confusing error, instead of failing gracefully with a clear message.

### Increment / decrement operators

```bash
i=1

i=$((i + 1))
((i++))   # Post-increment
((++i))   # Pre-increment
((i--))   # Decrement

echo "i value: $i"
```
`((i++))` is just a shorter way of writing `i=$((i + 1))` — does the exact same job, less typing.

### Assignment operators

```bash
x=10

((x+=5))    # x = x + 5
((x-=2))    # x = x - 2
((x*=2))    # x = x * 2
((x/=2))    # x = x / 2

echo "x value: $x"
```
These are simply shortcuts — `x+=5` means "take x, add 5 to it, and store the result back into x." Saves you from writing the full `x=$((x + 5))` every time.

### Bitwise operators

```
&   AND
|   OR
^   XOR
~   NOT
<<  Left shift
>>  Right shift
```
```bash
echo $((5 & 3))     # 1
echo $((5 | 3))     # 7
```
These work directly on the binary (0s and 1s) form of numbers. Not used very often in everyday scripts, but good to know they exist — they sometimes come up in networking/permission-related scripts.

### Command logical operators

```
&&  Run next command only if the previous one succeeded
||  Run next command only if the previous one failed
;   Run next command regardless, no matter what happened
```
```bash
mkdir test_dir && cd test_dir
ls /not_exist || echo "Command failed"

ll; ls; pwd
```
**Real-time example:** `mkdir test_dir && cd test_dir` — this only tries to `cd` into the folder **if** `mkdir` actually succeeded. If folder creation failed for some reason (say, permission denied), there's no point trying to `cd` into a folder that was never created — `&&` protects you from exactly that situation.

---

## 6. Production best practices

1. **Always quote your variables.**
   ```bash
   file="Madhu kiran"
   rm "$file"   # correct — one filename
   rm $file     # WRONG — Bash splits this into two words
   ```
   A value with a space, unquoted, silently breaks into multiple words.

2. **Prefer `[[ ]]` over `[ ]`** — more modern, handles empty variables/pattern matching more safely.

3. **Prefer `(( ))` for arithmetic comparisons** — cleaner, no `-gt` needed:
   ```bash
   if (( count > 3 )); then echo "Greater"; fi
   ((count++))
   ```

4. **Use `set -euo pipefail`** — the standard "safety belt" line, right after the shebang:
   - `-e` — exit immediately if any command fails
   - `-u` — fail if you reference a variable that was never set (catches typos)
   - `-o pipefail` — makes a whole pipeline fail if **any** command in it fails, not just the last one

**Real-time example (`-u`):** `echo "Deploying to $ENV"` with a typo like `$ENVV` would silently deploy to a blank environment without `-u`; with it, the script errors out immediately instead.

**Real-time example (`pipefail`):** `cat file.txt | grep error` — if `file.txt` doesn't exist, `cat` fails silently but `grep` still "succeeds" on empty input, hiding the real failure. `pipefail` catches this correctly.

**Easy memory trick:** `set -euo pipefail` → the one line every real production script starts with.

---

## 7. Checking whether a command succeeded

```bash
docker ps >/dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Docker not running"
  exit 1
fi
```
- `>/dev/null 2>&1` — discard both normal and error output, we only care whether it worked.
- `$?` — exit status of the last command; `-ne 0` = "it failed."
- `exit 1` — stop the script and report failure (useful for CI/CD watching for success/failure).

**Real-time example:** Before a deployment script tries to build/run a container, checking "is Docker even running?" first saves a confusing failure five steps later.

---

## 8. Looping over real data — `/etc/passwd`

```bash
for user in $(cut -d: -f1 /etc/passwd); do
  echo "THE USER NAME IS: $user"
done
```
`cut -d: -f1 /etc/passwd` pulls out just the username column; the loop then prints each one.

**Real-time example:** This is exactly how a sysadmin audits "who has an account on this server" — instead of reading the file line by line by eye.

---

## 9. The `PATH` variable

`PATH` tells Linux **where to search** for a program when you type a command without its full path.

```
PATH=/usr/local/bin:/usr/bin:/bin
```
Each folder is checked left to right, in order, until a match is found.

**Real-time example:** `command not found` often just means the program exists on disk, but its folder isn't listed in `PATH` — fixed by running it with its full path, or adding the folder to `PATH`.

---

## 10. Functions — reusing a block of commands

A **shell function** is a way to group a bunch of commands together, under one name, so you can reuse that whole group again and again — very similar to functions in any other programming language.

```bash
function_name () {
    command1
    command2
}
```
or the same thing, written slightly differently:
```bash
function function_name {
    command1
    command2
}
```
Both forms do exactly the same job — pick whichever style you prefer, no real difference between them.

**Example — `greet.sh`:**
```bash
#!/bin/bash
greet()
{
  echo "Hello $1, Welcome to AWS DevOps Training, Bright future is assured provided you workhard"
}

greet Madhu
greet Ramni
greet Suma
greet Aditya
```
Here, `greet` is a function which takes one argument (`$1`), and prints a welcome message using it. Notice it's called four separate times, each time with a different name — this is the whole point of a function: write the logic once, reuse it as many times as you like, without repeating the `echo` line four separate times.

**Output:**
```
Hello Madhu, Welcome to AWS DevOps Training, Bright future is assured provided you workhard
Hello Ramni, Welcome to AWS DevOps Training, Bright future is assured provided you workhard
Hello Suma, Welcome to AWS DevOps Training, Bright future is assured provided you workhard
Hello Aditya, Welcome to AWS DevOps Training, Bright future is assured provided you workhard
```

**Example — `sum.sh`:**
```bash
#!/bin/bash
add_numbers()
{
num1=$1
num2=$2

sum=$(( num1 + num2 ))
echo "THE SUM OF TWO $1 & $2 NUMBERS = $sum"
}

add_numbers 5 10
add_numbers 10 15
add_numbers 30 40
```
Here, `add_numbers` is a function taking **two** arguments (`$1` and `$2`), storing them into named variables, doing arithmetic on them, and printing the result. Called three times, each with a different pair of numbers.

**Example — `sum2.sh`, a shorter version:**
```bash
#!/bin/bash
add_numbers()
{
sum=$(( $1 + $2 ))
echo "THE SUM OF TWO $1 & $2 NUMBERS = $sum"
}

add_numbers 5 10
add_numbers 10 15
```
Same job as `sum.sh` — this version just skips storing `$1`/`$2` into named variables first, and uses `$1`/`$2` directly inside the arithmetic. A shortcut once you're comfortable with the basics.

---

## 11. Real-time one-liners used on real servers

**CPU usage:**
```bash
top -bn1 | grep "Cpu(s)" | awk -F" " '{print $2 + $3 + $4}'
```

**Memory usage:**
```bash
free | grep Mem | awk -F" " '{print $3/$2 * 100.0}'
```

**Disk usage:**
```bash
df -h / | tail -1 | awk -F" " '{print $5}' | sed 's/%//'
```

**Real-time example:** Monitoring/alerting scripts that page someone at 2 AM for "disk 90% full" are built on exactly these one-liners, wrapped in a script that runs on a schedule and checks the number against a threshold.

---

## 12. `find` for log rotation

```bash
find /var/log/app/ -name "*.log" -mtime +7 -exec gzip {} \;
```
`-mtime +7` = modified more than 7 days ago. `-exec gzip {} \;` runs `gzip` on every match (`{}` = the filename).

**Real-time example:** This exact command is how real log-rotation scripts compress old logs automatically, so disk doesn't fill up with logs nobody's reading, while still keeping history around (compressed).

---

## 13. Deployment basics — `systemctl`

```
CODE (git) → deploy onto the server → service (re)start
```

| Command | Does |
|---|---|
| `systemctl start servicename` | start the service if not running |
| `systemctl restart servicename` | stop + start — used after deploying new code |
| `systemctl status servicename` | check if running, see recent logs |
| `systemctl stop servicename` | stop it completely |

---

## A couple of handy one-liners

```bash
echo "myname is madhu" > madhu.txt      # write (overwrite)
tail -100f /app/xyz.log                 # show last 100 lines, then follow live
```
`tail -f` keeps the terminal open and streams new lines as they're added — the standard way to watch a live application log while debugging.

---

## Quick Recap Table

| Command / Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `if`/`elif`/`else`/`fi` | Make a decision in a script | Branching logic based on an argument or a check |
| `for` / `while` / `until` | Repeat a block of commands | Looping through servers, numbers, or file lines |
| `break` / `continue` | Stop a loop / skip one pass | Stopping a health-check pipeline on a critical failure |
| `-gt`/`-eq`/`-z`/`-f` etc. | Numeric / string / file test operators | Checking a config file exists and is executable before using it |
| `&&` / `\|\|` | Run next command only if previous succeeded/failed | `mkdir dir && cd dir` |
| `set -euo pipefail` | Safety belt for production scripts | Standard first line after the shebang in real scripts |
| `$?` | Exit status of the last command | Checking Docker is running before deploying |
| `function_name() { ... }` | Reuse a block of commands | A `greet()`/`add_numbers()` style helper called many times |
| `find ... -mtime +7 -exec gzip {} \;` | Bulk-process old files | Automated log rotation |
| `systemctl restart servicename` | Apply newly deployed code | Final step of most deployment scripts |
