# Batch 18 — Git Basics to Advanced

Friends, in this document we will understand everything we covered in Batch 18, in very simple language, with real-time examples for each and every concept. No need to mug up anything — just understand the logic, that's more than enough. See, Git is nothing but a **time machine for your code** — it will remember each and every version of your files, so that you can go back, compare, share, and combine work with your teammates without losing anything. Simple only.

---

## 1. What is Git, and why we need it?

See, suppose you are writing one project report in Word, and you keep on saving copies like `report_v1.docx`, `report_v2_final.docx`, `report_v2_final_FINAL.docx`. Within some time it will become total confusion, and even then you cannot tell exactly what changed between one version and another, or combine two people's edits properly. Same headache, no?

Git is solving this exact problem, but for code. What it does is:
- It takes a "snapshot" of your project, whenever you tell it to (this snapshot we call a **commit**).
- You can go back to any old snapshot, at any time, no issues.
- Multiple people can work on the same project together, without overwriting each other's work.

**Real-time example:** Suppose 3 developers — Madhu, Kiran, Adarsh — all are building features for the same app. Without Git, they will be sending zip files over email, WhatsApp, whatever — total mess. With Git, everyone works on their own copy, and Git will combine everyone's changes safely, no tension.

Git Bash is simply one terminal application, for Windows, which allows you to run Git commands in Linux style. That's all, nothing extra.

---

## 2. Git Basics: init, config, add, commit

### `git init` — start tracking your project
This command converts a normal folder into a Git-tracked project, which we call "repository" or short form "repo". Internally it will create one hidden `.git` folder, which stores all the history.
```
$ cd myproject
$ git init
Initialized empty Git repository in /myproject/.git/
```
**Real-time example:** Say you are starting a fresh folder for your college assignment. The moment you run `git init`, Git will start watching that folder for any changes — but as of now it has not saved anything, it is just "standby" mode only.

### `git config` — tell Git who you are
Every commit needs one author name and email, so that Git knows who exactly made that change. Otherwise how will it know, correct?
```
$ git config --global user.name "madhu"
$ git config --global user.email "madhu@gmail.com"
```
`--global` means this setting applies to *all* the repos on your machine, not only this one folder. If you skip this step, your commits will show as "unknown author" — not good practice.

**Real-time example:** In our class, Madhu and Kiran were using the same laptop, one after another. So before committing, each one had to run `git config` again with their own name — otherwise Kiran's commits would show up as Madhu's commits, and there will be confusion later on who did what.

### `git status` — what is the current situation of your files?
This command will show you current state of your files — what is new, what is modified, what is staged. Very useful command, you will type this 100 times a day, no exaggeration.
```
$ touch filename
$ git status
Untracked files:
  filename
```
File shown in **red colour** means — Git has seen the file, but is not tracking its history as of now ("untracked", sitting only in your **workspace**).

### `git add` — move file to "staging area"
Think of staging area like a **shopping cart** in Amazon. You are selecting which changes you want to include in your next "checkout" (which is nothing but the commit).
```
$ git add filename
$ git status
Changes to be committed:
  filename
```
File shown in **green colour** means — it is staged and ready to be committed. Green is good sign, remember that.

`git add .` will stage *everything* that changed in current folder, in one shot. This is used again and again in our notes, like `touch k1 k2 k3` followed by `git add .` — very common pattern.

### `git commit` — save the snapshot permanently
```
$ git commit -m "commit message" filename
```
This will take whatever is in staging area and save it permanently into project history, along with a message explaining *why* you made that change. Message is important — don't just write "update update" for every commit, be specific.

**Real-time example:** `git commit -m "first java commit" java` — here Madhu created one file called `java`, staged it, and committed with a clear message. So that after six months, if anybody opens the history, they will understand exactly what that snapshot was for, without asking Madhu directly.

### `git log` — see complete history
```
$ git log
commit 9d6a2f91715ddd5acbb407f0c8ece56694015140
Author: madhu <madhu@gmail.com>
Date:   Mon Jul 28 2026
    first java commit
```
Every commit gets one unique ID — that long string, we call it **commit hash** or short form **cid**. Think of it like a receipt number for that particular snapshot — unique, no two commits will ever have same ID.

### `git show <cid>` — see exactly what happened in one particular commit
```
$ git show 9d6a2f91715ddd5acbb407f0c8ece56694015140
```
This will show the commit message, plus the actual line-by-line changes (we call this "diff") made in that specific commit. Very useful when you want to check "what exactly did this commit change," instead of scrolling through whole log and getting confused.

---

## 3. Two people, one machine — Madhu vs Kiran

In our notes, Madhu and Kiran were taking turns on the same laptop, each one setting their own Git identity and making their own commits (`touch k1 k2 k3` → `git add .` → `git commit -m "Kiran commit"`).

**Real-time example:** This exact same thing happens on a shared build/CI server in companies, or when two students are sharing one lab PC. Git doesn't care *which machine* you are sitting on — it only cares *what identity* is set through `git config`, at the time of commit. That is why, even from the same folder, the history correctly shows some commits as "madhu" and some as "kiran" — no mix-up.

---

## 4. GitHub, Cloning, and Pushing

Understand this clearly — Git (the tool) works fully on your own laptop, offline also it will work. **GitHub** is a website which *hosts* your Git repository online, so that others can see it, download it, and collaborate with you. Simply put, GitHub is like "Google Drive, but for Git repos."

### Creating a repo and cloning it
In class we created one repo called `b18projectrepo` on GitHub, and then everybody downloaded their own copy using:
```
$ git clone https://github.com/devopstraininghub/b18projectrepo.git
$ cd b18projectrepo
```
`git clone` will copy the *entire* project **and** its full history onto your machine — not just the latest files, everything.

### Pushing your work back up
```
$ touch madhu
$ git status              # red — untracked
$ git add .
$ git status              # green — staged
$ git commit -m "msg"
$ git push
```
`git push` will upload your local commits to GitHub, so that everyone else on the team can also see it.

**Real-time example:** Madhu created a file, committed it locally on his machine, then ran `git push`. Immediately that file will appear on the GitHub website for the whole team to see — exactly like uploading your local save file to a shared cloud folder. Everyone can see it now, not just Madhu.

### Authentication — how to prove it is really you
GitHub these days does not accept plain password for pushing code — that facility is removed. Two methods are there:
1. **Email & password** — old method, mostly disabled now, don't bother about this.
2. **Personal Access Token (PAT)** — one long random string (like `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` from our notes) which works as a substitute password, with limited permissions attached to it.

**Real-time example:** Think of it exactly like using an app-specific password for your email account, instead of your actual Gmail password. If that token leaks somewhere by mistake, you can simply revoke that one token, no need to change your main GitHub password itself.

### Permission errors
```
error: permission to b18projectrepo repo denied to adarsh
```
**Real-time example:** Adarsh cloned the repo and tried to push, but he was never added as a "collaborator" on GitHub for that repo — so GitHub straightaway rejected his push. Same as trying to edit a Google Doc which is shared to you as "view only" — you can read, but can't touch anything. Solution is either the repo owner adds Adarsh as collaborator, or Adarsh raises a **Pull Request** instead (see Section 12 below, we will come to that).

### `git pull --rebase`
```
$ git pull --rebase
$ git push
```
This is used when somebody else has already pushed changes, and your local copy has fallen behind. It will fetch their commits, and replay *your* commits on top of that — keeping the history clean, instead of creating a messy extra merge commit. (Full merge vs rebase explanation is in Section 15, please refer that.)

---

## 5. Branches — working on features safely

A **branch** is nothing but a separate, parallel line of work — like a duplicate copy of your project, where you can freely experiment, without disturbing the main, working version.

**Real-time example:** Assume main branch is your "officially released app," the one which is live and working fine for users. Now you want to add a risky new login feature. Instead of directly touching the official code (which can break things for everybody, imagine the panic), you create a separate branch called `login-feature`, do all your experiments there peacefully, and only bring it into `main` once it is fully tested and working properly.

```
$ git branch                     # list branches, * marks current one
$ git branch madhu_br            # create a new branch
$ git checkout madhu_br          # switch to it
$ git branch                     # confirm you're now on madhu_br

$ touch madhufile
$ echo "This is Madhu, I am crazy to learn devops" > madhufile
$ git add .
$ git commit -m "Madhu branch commit"

$ git push origin madhu_br       # push THIS branch, not main
```

`git checkout -b mc_br` is a shortcut which will create **and** switch to that branch, in one single step — saves you one extra command (we used this later in the notes for `mc_br`).

### Merging a branch back into main
```
$ git checkout main
$ git merge madhu_br
```
This will bring all of `madhu_br`'s commits into `main`. Straightforward.

### Deleting a branch once its job is done
```
$ git branch -d madhu_br     # safe delete — refuses if not merged yet
$ git branch -D madhu_br     # force delete — deletes even if unmerged
$ git push origin -d mc_br   # delete the branch on GitHub too
```
**Real-time example:** Once the login feature is merged into `main` and everything is confirmed working fine, you delete `login-feature` locally (`-d`) and also on GitHub (`push origin -d`), so that the branch list stays tidy. Exactly like ticking off and clearing a finished to-do list — no point keeping it around.

### `git cherry-pick <cid>`
This will pick up *one specific commit* from another branch, and apply just that single commit onto your current branch — without merging the whole branch along with it.

**Real-time example:** Suppose Kiran fixed one critical typo bug on his `kiran_br` branch, but that branch also has a lot of unfinished, half-broken code sitting there. You don't want *all* of Kiran's branch on main right now — you only want that one bug-fix commit, nothing else. `git cherry-pick <that-commit-hash>` will grab exactly that commit alone, no extra baggage.

---

## 6. Text editors: vim/vi and nano

Since Git will need a text editor for typing longer commit messages, or while resolving conflicts, we also covered basic vim usage in class:
```
$ vim filename
i               # switch to Insert mode to type
Esc             # leave Insert mode back to Normal mode
:w              # write/save
:q              # quit
:wq             # save and quit in one step
```
**Real-time example:** Whenever you run `git commit` *without* `-m`, Git will automatically open vim (or nano), so that you can type a longer, multi-line commit message properly. Just knowing `i`, `Esc`, and `:wq` is more than enough for survival — no need to master full vim, don't worry.

---

## 7. Merge Conflicts

A **merge conflict** happens when Git is not able to automatically combine two changes, because both changes touched the *same line* of the *same file*, but in a different way. Git will get confused — "which one is correct?" — and it will ask you to decide.

**Real-time example:** Say you and Kiran, both branch off from `main` on Monday. You change line 10 of `config.txt` to `"port=8080"`. Kiran, on his branch, changes the same line 10 to `"port=9090"`. Now when you try to merge Kiran's branch into yours, Git sees two different answers for the same line, and it stops there itself, asking a human being to decide which is correct (or write a fresh combined answer). Git will mark the file like this:
```
<<<<<<< HEAD
port=8080
=======
port=9090
>>>>>>> kiran_br
```
You just edit the file, keep whichever version is correct, remove the `<<<<<<<` / `=======` / `>>>>>>>` marker lines, then do `git add` and `git commit` to close out the merge. Not a big deal once you understand it, just looks scary the first time.

---

## 8. `git commit --amend` — fixing your last commit

```
$ git commit --amend -m "corrected message"
```
This allows you to change the *most recent* commit's message (or even add some forgotten file into it), instead of creating a brand new, separate commit just for a tiny correction.

**Real-time example:** Suppose you committed with a spelling mistake: `"fisrt java commit"`. Instead of leaving that typo in history forever and feeling embarrassed later, `git commit --amend -m "first java commit"` will cleanly rewrite that last commit. ⚠️ One important point — only amend commits which are **not pushed yet**. If you amend a commit which others have already pulled, it will create confusing mismatches in their history, so be careful there.

---

## 9. Filtering `git log`

In real projects, there can be thousands of commits sitting in history — filtering is what makes it actually usable.
```
$ git log -n 5                              # show only last 5 commits
$ git log --oneline                         # one line per commit (compact)
$ git log --oneline -n 5                    # combine both
$ git log --author kiran                    # only Kiran's commits
$ git log --since="2026-08-01"              # only commits after this date
```
**Real-time example:** Suppose your team lead asks, "what exactly did Kiran commit last week?" Instead of scrolling through the whole project history one by one, `git log --author kiran --since="2026-08-01"` will filter it down instantly, no manual searching required.

---

## 10. Config list and Aliases

```
$ git config --list       # show every config setting currently active
```

**Aliases** allow you to create your own short nicknames for long commands — saves typing, saves time.
```
$ git config --global alias.s "status"
$ git s                              # now works exactly like "git status"

$ git config --global alias.l "log"
$ git l

$ git config --global alias.lo "log --oneline"
$ git lo

$ git config --global --unset alias.s   # remove an alias
```
**Real-time example:** If you are typing `git status` some 50 times a day, setting up `git s` as an alias will genuinely save your time — same as setting up a keyboard shortcut for something you use constantly. Small thing, but adds up.

### `git commit -am "message"`
This is a shortcut which combines `git add` (only for files Git is already tracking) and `git commit`, into a single step.
```
$ git commit -am "quick fix message"
```
**Real-time example:** You just fix a small typo in a file Git already knows about. Instead of writing `git add file` and then `git commit -m "..."` separately, `-am` does both in one line, saves one step. Just remember — this only works for files Git is *already tracking*. Brand new, untracked files still need an explicit `git add` first, no shortcut for that.

---

## 11. Tags — marking important milestones

A **tag** marks one specific commit as important — mostly used for release versions (`v1.0`, `v2.0`, and so on).
```
$ git tag                          # list existing tags
$ git tag v1.0 <cid>                # tag a specific commit
$ git checkout v1.0                 # view the project exactly as it was at that tag
$ git tag -d v1.0                   # delete a tag locally
$ git push origin v1.0              # push the tag to GitHub
$ git push origin -d v1.0           # delete the tag on GitHub too
```
**Real-time example:** Say your app reaches its first stable release. Instead of trying to remember "release 1.0 was that commit `9d6a2f9...`, or was it some other one," you simply tag it `v1.0`. Six months down the line, if someone reports a bug "in version 1.0," you `git checkout v1.0` and see exactly what was shipped at that point — no guesswork, no confusion.

---

## 12. Pull Requests, Forks, and Open Source Contribution

- **Pull Request (PR)** / **Merge Request (MR)** — this is a formal request to the repo owner, saying: "kindly review my branch and merge it into your main branch." This is how teams review code *before* it goes live officially, and this is also how outside contributors (who don't have direct push access) can still contribute to a project.
- **Fork** — this means making your *own personal copy* of somebody else's GitHub repo, under your own account, so that you can freely experiment on it, without needing any permission on the original repo.

**Real-time example (continuing from Adarsh's permission error above):** Adarsh was not a collaborator, so his direct `git push` got rejected. The correct open-source way of doing this is: **fork** the repo → clone *your own fork* → make your changes → push to *your fork* (which you fully own, so no permission issue there) → then raise a **Pull Request** back to the original repo → the maintainer reviews it and merges if it's good. This is exactly how contributions happen in big open-source projects like React or Kubernetes — thousands of outside developers contributing, zero direct push access, everything routed through PRs only.

### Branch Protection
Repo owners can set some rules on important branches (like `main`) — for example, "nobody is allowed to push directly, every change must go through a reviewed Pull Request," or "minimum 2 approvals needed before merging."

**Real-time example:** This will prevent a situation where somebody accidentally pushes broken, untested code straight into `main`, and takes down the live app for everyone. The protected branch forces a review step first, before anything gets in — like a security check at the gate.

---

## 13. `git reset` — undoing commits/staging

`git reset` will move you *backward* through the staging/commit process. There are three modes, each one undoing a different amount, so choose carefully:

```
$ git reset HEAD filename        # un-stage a file (staging → workspace, keeps the edits)

$ git reset --soft <cid>         # undo commit(s), keep changes STAGED (ready to re-commit)
$ git reset --mixed <cid>        # undo commit(s), keep changes in workspace (needs re-adding)
$ git reset --hard <cid>         # undo commit(s) AND permanently delete the changes
```

**Real-time example:**
- `--soft`: You committed a bit too early, and now want to add one more file into that same commit → soft-reset one commit back, add the missing file, re-commit. Nothing is lost, all safe.
- `--mixed`: You realise your last 2 commits should have been organised differently → mixed-reset, and now all those changes will sit unstaged in your workspace, ready for you to re-add and re-commit properly, this time in a better way.
- `--hard`: You experimented with a bad idea across 3 commits, and now want to throw the whole thing away completely, files and all → `--hard` will delete everything. ⚠️ This one is destructive, cannot be undone through normal means — use only when you are 100% sure, don't do this casually.

---

## 14. `git stash` — temporarily shelving your work

Sometimes you are halfway through editing something, but suddenly you need to switch to an urgent task (say, an emergency bug fix), without committing your half-finished work. `git stash` will put your current changes "in a drawer," and give you back a clean workspace to work on the urgent thing.

```
$ git stash save "task1"          # shelve current uncommitted work
                                   # ... now go fix the urgent bug, commit it ...
$ git stash list                  # see everything currently stashed
```

- **`git stash apply`** — brings the stashed changes back, but **keeps a copy in the stash** also. Exactly like **copy-paste** — original still remains there.
- **`git stash pop`** — brings the stashed changes back, **and removes it from the stash**. Exactly like **cut-paste** — nothing left behind.
- **`git stash drop`** — simply deletes a stashed entry, without ever bringing it back — for when you decide you don't need it anymore.

**Real-time example:** You are halfway through building a new signup form (`task1`), and suddenly your manager says, "production is down, fix it right now!" You do `git stash save "task1"` to safely park your half-done form aside, fix the emergency bug on a clean workspace, commit and push that fix, and then `git stash pop` to instantly get back your signup-form work exactly the way you left it. No work lost, no panic.

---

## 15. Git Merge vs Git Rebase

Both of these combine work from two branches, but they leave a very different footprint in your history. This confuses a lot of people, so pay attention here.

**`git merge`**
- Combines two branches by creating a brand-new **merge commit**, which has two parents.
- Never rewrites existing history — completely safe, even on shared/public branches, no risk at all.
- History clearly shows *when and where* the branches joined together.
- Downside: with too many branches, the commit graph becomes cluttered with lots of merge commits, a bit messy to look at.

**`git rebase`**
- Takes your branch's commits, and replays them *on top of* the latest commit of another branch — as if you had started your work only after theirs.
- Rewrites commit history (it changes the commit parents), giving you a **clean, straight, linear** history.
- Best used on your own personal/feature branch, *before* you push it or share it with anyone.
- Dangerous on branches which others have already pulled — rewriting shared history will badly conflict with their local copies, avoid doing this on shared branches.

**Real-time example:** Say you have a `feature/login` branch with 5 commits, and meanwhile `main` has also moved forward with 3 new commits from your teammates.
- If you do `git merge main` into your branch: you get your 5 commits + their 3 commits + 1 new merge commit = a "diamond" shape in the history.
- If instead you do `git rebase main`: Git pretends as if you started your 5 commits *after* their 3 commits, giving you one clean straight line — much easier to read later on, but this is only safe because nobody else has touched your feature branch yet.

---

## 16. Git Pull vs Git Fetch

```
git pull = git fetch + git merge origin
```

- **`git fetch`** — downloads new commits from GitHub onto your local machine, but does **not** touch your current working files. It just updates Git's internal knowledge of "what all is out there," nothing more.
- **`git pull`** — does a fetch, **and then immediately merges** those new commits into your current branch, actually updating your files.

**Real-time example:** `git fetch` is like checking your mailbox and seeing new mail has arrived, without opening any of the letters yet — you can look at what came in (`git log origin/main`) before deciding what to do next. `git pull` is like checking the mailbox **and** opening/filing every single letter immediately, no pause. Careful teams often `fetch` first to review what's coming in, and then merge deliberately, rather than blindly `pull`ing straight into their ongoing work.

---

## 17. `.gitignore` — telling Git what to ignore

A `.gitignore` file lists out file/folder patterns which Git should never track — even if those files are physically sitting inside the project folder.

**Real-time example:** Every project generates some files which don't belong in history at all — password/secret files (`.env`), compiled build output (`node_modules/`, `*.class`), or your personal editor settings (`.vscode/`). A `.gitignore` file containing:
```
.env
node_modules/
*.log
```
means these will never show up in `git status` as untracked, and can never get accidentally committed by mistake — protects your secrets, and keeps the repo neat and clean.

---

## 18. `git revert` — the safe way to undo a commit

```
$ git revert <cid>
```
Instead of deleting a commit from history (like `reset --hard` would do), `revert` creates a **brand-new commit** which does the exact opposite of the target commit — cancelling its effect, while keeping the full history intact and honest. Nothing is hidden or erased.

**Real-time example:** Say a commit which went live in production last week introduced a bug. You cannot simply erase that commit — other commits have been built on top of it since then, and erasing history on a shared branch is quite dangerous, can break a lot of things. `git revert <that-cid>` will add a new commit saying "undo commit X," which is completely safe to push to `main`, safe for CI/CD pipelines, and leaves a clear record of *both* the mistake and the fix, for anyone checking history later. This is exactly why `revert` (and not `reset --hard`) is the standard practice for production and team-based workflows.

---



## Quick Recap Table

| Concept | One-line meaning | Real-time analogy |
|---|---|---|
| `git init` | Start tracking a folder | Opening a new diary |
| `git add` | Choose what to save next | Adding items to a shopping cart |
| `git commit` | Save a permanent snapshot | Taking a save-game checkpoint |
| `git branch` | Parallel line of work | A "draft" copy of a document |
| `git merge` | Combine two branches, keep full history | Merging two people's edits into one doc |
| `git rebase` | Replay your commits on top, clean line | Rewriting your diary as if you'd started later |
| `git stash` | Temporarily shelve unfinished work | Putting a half-done task in a drawer |
| `git reset` | Undo commits/staging (soft→hard = more destructive) | Rewinding a save file |
| `git revert` | Safely undo a commit without erasing history | Writing a follow-up correction note |
| `git tag` | Mark a milestone commit | Bookmarking "Release 1.0" |
| `git cherry-pick` | Copy one specific commit elsewhere | Photocopying just one page from another notebook |
| Pull Request | Ask to merge your branch into someone else's | Submitting an edit for approval before publishing |
| Fork | Your own personal copy of someone else's repo | Cloning a recipe to experiment with your own twist |

That's it, friends — cover these points thoroughly, practice each command with your hands on the keyboard (not just reading), and Git will become second nature within a week or two. All the best!
