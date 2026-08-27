# Batch 18 — Linux Running Notes: 28 August 2026

**Topic: Shell Scripting Continued — Conditionals (`if`/`elif`/`else`), Loops (`for`/`while`/`until`), `break`/`continue`, Bash Operators, Functions, Production Best Practices, Real-Time One-Liners**

Friends, yesterday we covered the building blocks — variables, arguments, debugging. Today we make scripts actually **think and repeat**: conditionals to make decisions, loops to repeat work, operators to compare/calculate, functions to reuse logic, and the production habits that separate a "college script" from one companies actually trust in production.

---

## 1. Conditionals — `if` / `elif` / `else`

Lets a script make a decision — run one block if something is true, a different block if not.

```bash
if [ condition1 ]; then
    echo "..."
elif [ condition2 ]; then
    echo "..."
else
    echo "..."
fi
```
`elif` = "else if," chain as many as needed. `fi` closes the `if` (it's `if` spelled backwards) — every `if` needs one.

**Example — checking age via argument:**
```bash
#!/bin/bash
age=$1

if [ "$age" -gt 18 ]; then
    echo "The person is a Major"
elif [ "$age" -lt 18 ]; then
    echo "The person is Minor"
else
    echo "Exactly 18, still a Major"
fi
```
`-gt`/`-lt` compare **numbers** inside `[ ]` — plain `>`/`<` don't work here the way they do in normal maths (common beginner mistake).

**Sample output:**
```
$ ./person.sh 25
The person is a Major
```

**Easy memory trick:** `fi` = `if` backwards, closes the block.

---

## 2. Loops — `for`, `while`, `until`

| Loop | Repeats... |
|---|---|
| `for` | once per item in a known list |
| `while` | as long as a condition stays true |
| `until` | until a condition finally turns true (opposite of `while`) |

**`for` loop:**
```bash
for i in {100..1}
do
     echo "The number is $i"
done
```
`{100..1}` = every number from 100 down to 1. `done` closes the loop, same idea as `fi`.

**`while` loop:**
```bash
i=1
while [ "$i" -le 100 ]; do
    echo "the number is: $i"
    i=$((i + 1))
done
```
`$(( ... ))` does arithmetic in Bash. Without the `i=$((i + 1))` line, this loop would never end.

**`until` loop:**
```bash
i=1
until [ "$i" -gt 100 ]; do
        echo "the number is : $i"
        i=$((i + 1))
done
```
`until` is `while`'s mirror image — "keep going *until* this becomes true" instead of "*while* true."

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

**Arithmetic** (`$(( ... ))`):
```bash
a=10; b=3
echo $((a + b))   # 13
echo $((a % b))   # 1  (remainder)
echo $((a ** 2))  # 100 (power)
```

**Relational** (numbers, inside `[ ]`):

| `-eq` | `-ne` | `-gt` | `-lt` | `-ge` | `-le` |
|---|---|---|---|---|---|
| equal | not equal | greater than | less than | ≥ | ≤ |

**String:**

| `=` | `!=` | `-z` | `-n` |
|---|---|---|---|
| equal | not equal | string is empty | string is not empty |

`-z "$var"` is the standard way to check "did the user actually pass a value, or leave it blank?"

**Boolean/logical:** `&&` (AND — both true), `\|\|` (OR — at least one true), `!` (NOT).

**File test** (very commonly used):

| `-f` | `-d` | `-e` | `-r` | `-w` | `-x` | `-s` |
|---|---|---|---|---|---|---|
| file exists | dir exists | file/dir exists | readable | writable | executable | not empty |

```bash
if [ -f "/etc/passwd" ]; then
    echo "File exists"
fi
```
**Real-time example:** Before a script reads a config file or runs another script, check `-f` (exists?) and `-x` (executable?) first — otherwise it crashes mid-way with a confusing error instead of failing with a clear message.

**Increment/assignment shortcuts:**
```bash
((i++))     # same as i=$((i + 1))
((x+=5))    # same as x=$((x + 5))
```

**Command logical operators:**
```bash
mkdir test_dir && cd test_dir     # cd only runs if mkdir succeeded
ls /not_exist || echo "failed"    # echo only runs if ls failed
ll; ls; pwd                       # all three run regardless
```
**Real-time example:** `mkdir test_dir && cd test_dir` — no point trying to `cd` into a folder that failed to get created; `&&` protects against that.

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

```bash
function_name () {
    command1
    command2
}
```

**Example — `greet.sh`:**
```bash
#!/bin/bash
greet() {
  echo "Hello $1, welcome to AWS DevOps Training"
}
greet Madhu
greet Ramni
```
**Sample output:**
```
Hello Madhu, welcome to AWS DevOps Training
Hello Ramni, welcome to AWS DevOps Training
```
`greet` takes one argument (`$1`) and is called multiple times — write the logic once, reuse it as many times as needed.

**Example — `sum.sh`:**
```bash
#!/bin/bash
add_numbers() {
  sum=$(( $1 + $2 ))
  echo "SUM of $1 & $2 = $sum"
}
add_numbers 5 10
add_numbers 30 40
```

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
