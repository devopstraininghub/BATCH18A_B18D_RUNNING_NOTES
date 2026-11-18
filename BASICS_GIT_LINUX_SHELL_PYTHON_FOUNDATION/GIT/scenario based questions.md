# Real-World / Scenario-Based Git Interview Questions

These are experience-based questions, usually asked as "Tell me about a time..." or "How did you handle...". Each answer below is written as a sample response you can adapt to your own project — describing the situation, what was actually done (commands/approach), and why.

## Table of Contents

1. [How did you set up version control when starting a new project in your organization?](#s1)
2. [Describe a situation where you had to resolve a Git conflict during a merge](#s2)
3. [How did you generate and use SSH keys to connect to GitHub securely in production systems?](#s3)
4. [Describe a situation where you used a feature branch and raised a pull request](#s4)
5. [Explain a time you needed to roll back a faulty commit in Git](#s5)
6. [How did you manage team access securely when using GitHub repositories?](#s6)
7. [Explain a situation where you used Git tags in production releases](#s7)
8. [Share your experience of forking a public repository and customizing it for internal use](#s8)
9. [Describe a situation where you used GitHub Issues for project tracking](#s9)
10. [Tell me about a time you used git log and git blame for debugging production issues](#s10)
11. [How did you create a README file that helped onboard new developers?](#s11)
12. [Describe how you handled a hotfix in production using Git](#s12)
13. [How did you automate GitHub access using Personal Access Tokens (PAT) for shell scripts?](#s13)
14. [Tell me about a situation where multiple developers committed to the same branch. How did you manage?](#s14)
15. [Share a time when you used .gitignore to avoid committing sensitive or large files](#s15)
16. [How did you handle switching between multiple Git branches during parallel development?](#s16)
17. [Describe how you implemented Git Flow strategy in a real project](#s17)
18. [How did you deal with accidental commits to the main branch?](#s18)
19. [Explain how you performed a rollback using Git in a production deployment](#s19)
20. [How did you use GitHub Actions or CI/CD with Git branches?](#s20)
21. [How did you rename a Git branch that was incorrectly named?](#s21)
22. [Share an experience where you recovered deleted Git commits](#s22)
23. [How did you resolve the 'detached HEAD' state during testing?](#s23)
24. [Describe a time when you cleaned up unnecessary local Git branches](#s24)
25. [How did you enforce branch protection rules in GitHub?](#s25)
26. [How did you handle a situation where a Git clone operation was failing due to authentication issues?](#s26)
27. [Explain how you verified Git remote URL misconfiguration in a live CI/CD pipeline](#s27)
28. [How did you use git cherry-pick to backport a fix to multiple branches?](#s28)
29. [How did you clean up a large .git history that was bloated due to committed binaries?](#s29)
30. [Explain how you monitored contributors and PR activity in a GitHub organization](#s30)
31. [How did you use environment-specific branches like dev, qa, stage, and prod?](#s31)
32. [How did you enforce standard commit messages across teams?](#s32)
33. [Share a situation where you used GitHub CLI or API from a shell script](#s33)
34. [How did you use GitHub Actions to restrict production deployment only from the prod branch?](#s34)
35. [How did you manage changelogs during a large release using Git commit history?](#s35)

---

<a id="s1"></a>
## Q1. How did you set up version control when starting a new project in your organization?

**A (Sample Answer):**
When starting a fresh project, I don't just run `git init` and start committing — I set up a proper baseline first:

1. Create the repository on GitHub (or `git init` locally, then add a remote).
2. Add a `.gitignore` matching the tech stack (Node, Java, Python, etc.) so build output and secrets never get tracked.
3. Add a `README.md` with setup steps, and a `LICENSE` if needed.
4. Make the first commit ("initial commit") and push to `main`.
5. Immediately turn on branch protection on `main` (no direct push, PR + review required) before anyone else starts committing.
6. Agree with the team on a branching strategy (trunk-based or Git Flow, depending on release frequency) and document it in the README.
7. Add collaborators/teams with correct access levels (see [Q6](#s6)).

**Real-time example:** On one project, we skipped step 5 initially, and within the first week someone accidentally pushed a half-working config file straight to `main`, which broke the deploy. After that, branch protection was made a day-1 checklist item for every new repo.

---

<a id="s2"></a>
## Q2. Describe a situation where you had to resolve a Git conflict during a merge.

**A (Sample Answer):**
While merging my feature branch into `develop`, both my teammate and I had modified the same section of a config file — he had updated the DB port, and I had updated a timeout value on the same line block. Git couldn't auto-merge it and stopped with conflict markers:
```
<<<<<<< HEAD
timeout=30
=======
port=9090
>>>>>>> teammate-branch
```
I ran `git status` to see which files were conflicted, opened the file, discussed with my teammate over a quick call to confirm both values were still needed, manually edited the file to keep both changes correctly, removed the `<<<<<<<`/`=======`/`>>>>>>>` markers, then ran `git add config.yml` and `git commit` to complete the merge. I always test the app locally after resolving a conflict, since a conflict resolved "cleanly" in text can still be logically wrong.

---

<a id="s3"></a>
## Q3. How did you generate and use SSH keys to connect to GitHub securely in production systems?

**A (Sample Answer):**
For our CI/CD server and production deployment boxes, I avoided using personal passwords/tokens and set up SSH-based access instead:
```
ssh-keygen -t ed25519 -C "deploy-server@prod" -f ~/.ssh/deploy_key
```
The public key (`deploy_key.pub`) was added as a **Deploy Key** on the specific GitHub repo (read-only, since production servers only need to `pull`, never `push`), rather than as a personal SSH key tied to one person's account. The private key was stored securely on the server (correct file permissions, `chmod 600`), and never committed to the repo. This way, even if that server is compromised, the blast radius is limited to just that one repo with read-only access, instead of a full personal GitHub account.

---

<a id="s4"></a>
## Q4. Describe a situation where you used a feature branch and raised a pull request.

**A (Sample Answer):**
When asked to add a "forgot password" feature, I didn't touch `main` directly:
```
git checkout main
git pull
git checkout -b feature/forgot-password
```
I built and tested the feature on that branch, committing in small logical steps, then pushed it:
```
git push origin feature/forgot-password
```
On GitHub, I opened a Pull Request against `main`, added a clear description of what changed and how I tested it, and tagged two teammates as reviewers. CI ran automatically and showed all checks green. After their approval, I merged via "Squash and Merge" to keep `main`'s history clean, then deleted the feature branch.

---

<a id="s5"></a>
## Q5. Explain a time you needed to roll back a faulty commit in Git.

**A (Sample Answer):**
A commit that went live introduced a bug in the checkout flow. Since `main` was already shared and other commits had been built on top of it, I did **not** use `git reset --hard` (that would rewrite shared history and break everyone else's local copies). Instead, I used:
```
git revert <faulty-commit-hash>
```
This created a new commit that undid exactly the bad changes, while keeping full history intact — anyone looking at the log later can clearly see both the mistake and the fix. I pushed this revert commit through a fast-tracked PR, and the CI/CD pipeline redeployed automatically, restoring checkout within minutes.

---

<a id="s6"></a>
## Q6. How did you manage team access securely when using GitHub repositories?

**A (Sample Answer):**
Instead of adding individuals directly to each repo, I used **GitHub Teams** at the organization level — e.g., `backend-devs`, `qa-team`, `release-managers` — and gave each team the minimum access level it actually needed (Read, Triage, Write, Maintain, or Admin). New joiners were simply added to the relevant team, and access was removed automatically the moment they were removed from the team, instead of hunting through every repo individually. I also enforced **2FA (two-factor authentication)** at the org level, and reviewed **Personal Access Token** scopes periodically so nobody was carrying a token with more permission than their actual job needed.

---

<a id="s7"></a>
## Q7. Explain a situation where you used Git tags in production releases.

**A (Sample Answer):**
Before every production release, once the release branch was fully tested, I created an **annotated tag**:
```
git tag -a v2.4.0 -m "Release 2.4.0 - added payment retry logic"
git push origin v2.4.0
```
Our CI/CD pipeline was configured to trigger a production deployment only when a new tag matching `v*` was pushed — so tagging itself acted as the "go live" trigger. Later, when a customer reported an issue "in version 2.4.0," I simply ran `git checkout v2.4.0` to see the exact code that had shipped, instead of guessing which commit that was.

---

<a id="s8"></a>
## Q8. Share your experience of forking a public repository and customizing it for internal use.

**A (Sample Answer):**
We needed an internal monitoring dashboard, and rather than building from scratch, we forked an open-source project on GitHub into our organization's account. After forking, I added the original project as an `upstream` remote so we could keep pulling in their improvements:
```
git remote add upstream https://github.com/original-owner/dashboard.git
git fetch upstream
git merge upstream/main
```
We then made our internal customizations (custom branding, internal auth integration) on top, on our own branches, and periodically merged in `upstream` updates to stay current with upstream bug fixes, while keeping our internal changes separate and easy to re-apply.

---

<a id="s9"></a>
## Q9. Describe a situation where you used GitHub Issues for project tracking.

**A (Sample Answer):**
For a mid-sized feature rollout, we tracked every task, bug, and enhancement as a GitHub Issue, using labels (`bug`, `enhancement`, `priority-high`) and assigning them to team members, grouped under a Milestone for that release. When raising a PR for a fix, I referenced the issue directly in the commit/PR description, e.g. `Fixes #142` — GitHub then automatically closed that issue the moment the PR was merged. We also used a **GitHub Project board** (Kanban view: To Do / In Progress / Done) built directly from these issues, so the whole team's status was visible at a glance without a separate tracking tool.

---

<a id="s10"></a>
## Q10. Tell me about a time you used git log and git blame for debugging production issues.

**A (Sample Answer):**
A calculation in the billing module suddenly started giving wrong results. I first narrowed down which file was responsible, then ran:
```
git log --oneline -- billing/calculate.js
```
to see recent commits touching that file, and:
```
git blame billing/calculate.js
```
to see exactly which commit (and which developer) had last changed the specific suspicious line. That immediately pointed me to a commit from two days earlier where a rounding logic change had been made. I then used `git show <that-commit>` to see the full diff and context, confirmed it was the cause, and worked with that developer to fix it correctly rather than guessing blindly across the whole file.

---

<a id="s11"></a>
## Q11. How did you create a README file that helped onboard new developers?

**A (Sample Answer):**
I structured the `README.md` so a brand-new developer could get the project running without asking anyone a single question:
- **Project overview** — what the app does, in 2-3 lines.
- **Tech stack** — languages, frameworks, database.
- **Setup steps** — exact commands to clone, install dependencies, set up `.env`, and run locally.
- **Branching strategy** — which branch to branch off from, naming convention for feature branches.
- **How to run tests** and **how to raise a PR** (checklist: tests passing, linked issue, reviewer assigned).

After introducing this, new joiners were able to get their local environment running and submit their first PR within a day, instead of the 2-3 days it used to take with tribal, undocumented knowledge.

---

<a id="s12"></a>
## Q12. Describe how you handled a hotfix in production using Git.

**A (Sample Answer):**
A critical bug was found in production outside our normal sprint cycle. I branched directly off the current production tag/branch (not off `develop`, which had newer, untested changes):
```
git checkout main
git checkout -b hotfix/payment-crash
```
Fixed the issue, wrote a quick test to confirm it, and raised a PR straight to `main` marked urgent, got an expedited review, merged, tagged a new patch version (`v2.4.1`), and deployed. Immediately after, I merged the same `hotfix` branch into `develop` too, so the fix wasn't accidentally lost or reverted by the next regular release.

---

<a id="s13"></a>
## Q13. How did you automate GitHub access using Personal Access Tokens (PAT) for shell scripts?

**A (Sample Answer):**
For an internal deployment script that needed to clone a private repo non-interactively, I generated a **fine-grained PAT** scoped only to that specific repo with read-only access, stored it as a CI/CD secret (never hardcoded in the script itself), and referenced it via an environment variable:
```
git clone https://${GH_PAT}@github.com/org/repo.git
```
The token had an expiry date set, and I documented a rotation process so it got renewed before expiring — avoiding the classic "the deployment suddenly stopped working because the token silently expired" incident.

---

<a id="s14"></a>
## Q14. Tell me about a situation where multiple developers committed to the same branch. How did you manage?

**A (Sample Answer):**
On a small, fast-moving branch, 3 of us were committing directly to the same feature branch in parallel. To avoid stepping on each other, we followed a simple rule: always `git pull --rebase` before pushing, so nobody's push would silently overwrite the others.
```
git pull --rebase origin feature/checkout
git push origin feature/checkout
```
We also kept commits small and pushed frequently (instead of holding large changes locally for a full day), which kept the chances of conflicts low, and when a conflict did happen, it was small and easy to resolve rather than a huge tangled mess.

---

<a id="s15"></a>
## Q15. Share a time when you used .gitignore to avoid committing sensitive or large files.

**A (Sample Answer):**
Early in a project, a `.env` file with database credentials almost got committed. I immediately added a `.gitignore`:
```
.env
node_modules/
*.log
build/
```
Since the `.env` file was, luckily, still only staged and not yet pushed, `git rm --cached .env` removed it from staging before commit. On another occasion, a large `.zip` build artifact *had* already been committed and pushed before we noticed — for that, we had to use the BFG Repo-Cleaner (see [Q29](#s29)) to strip it out of history completely, since `.gitignore` alone doesn't remove things that are already committed.

---

<a id="s16"></a>
## Q16. How did you handle switching between multiple Git branches during parallel development?

**A (Sample Answer):**
When I had to quickly switch between a feature branch and an urgent bug investigation without losing half-finished work, I used `git stash`:
```
git stash save "wip: signup form"
git checkout main
git checkout -b bugfix/urgent-issue
```
For situations where I needed *both* branches checked out and usable **at the same time** (e.g., comparing behaviour side-by-side), I used `git worktree` instead of stashing, which gives you a second working folder pointing at a different branch, without needing two separate clones:
```
git worktree add ../repo-bugfix bugfix/urgent-issue
```

---

<a id="s17"></a>
## Q17. Describe how you implemented Git Flow strategy in a real project.

**A (Sample Answer):**
On a product with scheduled, versioned releases, we adopted Git Flow:
- `main` — always reflects the latest production release.
- `develop` — integration branch where all finished features land first.
- `feature/*` — branched from `develop`, merged back into `develop` via PR.
- `release/*` — cut from `develop` when preparing a release, used for final QA/bug-fixing only.
- `hotfix/*` — branched from `main` for urgent production fixes, merged into both `main` and `develop`.

This structure suited us because we shipped on a fixed monthly schedule and needed to support an older version in parallel — Git Flow's separation of `develop` (in-progress) from `main` (released) made that clean.

---

<a id="s18"></a>
## Q18. How did you deal with accidental commits to the main branch?

**A (Sample Answer):**
Before we enabled branch protection, someone once committed directly to `main` by mistake. Since it hadn't been pushed yet, the easy fix was to move that commit onto a proper branch:
```
git branch feature/oops-fix     # create a branch pointing at the current (bad) commit
git reset --hard HEAD~1         # move main back one commit, removing it from main locally
git checkout feature/oops-fix   # continue work properly here, then raise a PR
```
If it had already been pushed to a shared `main`, I would have used `git revert` instead of `reset --hard`, to avoid rewriting shared history. After this incident, we enabled branch protection so direct pushes to `main` are no longer possible for anyone, closing the gap for good.

---

<a id="s19"></a>
## Q19. Explain how you performed a rollback using Git in a production deployment.

**A (Sample Answer):**
When a release caused errors in production, our rollback process was tag-based rather than commit-guessing: our CI/CD pipeline deploys whatever tag/branch you point it at, so I simply re-triggered a deployment pointing at the previous known-good tag (`v2.3.0`), which restored production immediately. In parallel, I raised a proper `git revert` PR against `main` for the actual faulty commit, so the next real release wouldn't reintroduce the same bug — the tag-based redeploy was for speed, the revert PR was for a permanent, tracked fix.

---

<a id="s20"></a>
## Q20. How did you use GitHub Actions or CI/CD with Git branches?

**A (Sample Answer):**
We set up separate GitHub Actions workflows triggered by branch:
```yaml
on:
  push:
    branches: [ "develop" ]   # runs tests + deploys to QA
  pull_request:
    branches: [ "main" ]      # runs tests + lint on every PR to main
```
Merging into `main` triggered a production build-and-deploy workflow (guarded by required status checks), while pushes to `develop` deployed automatically to a QA environment. This meant nobody had to manually trigger deployments — the branch itself decided what environment got updated, keeping the process consistent and repeatable.

---

<a id="s21"></a>
## Q21. How did you rename a Git branch that was incorrectly named?

**A (Sample Answer):**
A branch was pushed as `feature/loginn` (typo). I renamed it locally, then updated the remote:
```
git branch -m feature/loginn feature/login     # rename locally
git push origin feature/login                  # push the correctly named branch
git push origin --delete feature/loginn         # remove the old, wrongly named branch
```
I also let the teammates who had it checked out know, so they could re-fetch and switch to the corrected branch name instead of continuing to work off the old one.

---

<a id="s22"></a>
## Q22. Share an experience where you recovered deleted Git commits.

**A (Sample Answer):**
A teammate accidentally ran `git reset --hard` too far back and "lost" 3 commits of work. Since Git doesn't actually delete commit objects immediately, I used the reflog to find them:
```
git reflog
```
This showed the commit hashes from before the reset. I then recovered the work with:
```
git checkout -b recovered-work <commit-hash-before-reset>
```
which brought back all 3 "lost" commits onto a new branch, and the teammate was able to continue from there — nothing was actually lost, just temporarily hidden from the normal `git log` view.

---

<a id="s23"></a>
## Q23. How did you resolve the 'detached HEAD' state during testing?

**A (Sample Answer):**
While testing an old release, I had checked out a specific tag directly:
```
git checkout v1.9.0
```
Git warned about entering a "detached HEAD" state — meaning I wasn't on any branch, and any commits made here could easily get lost since no branch pointer was tracking them. Since I only needed to *look* at that version, I made no commits and simply switched back:
```
git checkout main
```
On another occasion, I actually needed to make a small fix while in that state — there, I first created a branch from the detached HEAD before committing anything, so the work wouldn't be orphaned:
```
git checkout -b fix/old-release-patch
```

---

<a id="s24"></a>
## Q24. Describe a time when you cleaned up unnecessary local Git branches.

**A (Sample Answer):**
After a few months, my local repo had accumulated 40+ old feature branches that had already been merged and deleted on GitHub, but were still sitting locally. I first checked which local branches were already fully merged into `main`:
```
git branch --merged main
```
and safely deleted them in bulk:
```
git branch --merged main | grep -v "main" | xargs git branch -d
```
I also ran `git fetch --prune` regularly, which automatically removes local references to remote branches that no longer exist on GitHub, keeping `git branch -a` output clean and easy to scan.

---

<a id="s25"></a>
## Q25. How did you enforce branch protection rules in GitHub?

**A (Sample Answer):**
On the `main` branch, under **Settings → Branches → Branch protection rules**, I configured: require a pull request before merging, require at least 1-2 approving reviews, require status checks (CI build + tests) to pass, dismiss stale approvals on new commits, and include administrators in the restriction (so even repo admins can't bypass it accidentally). This meant the only way any code reached `main` was through a reviewed, tested Pull Request — no exceptions, no "just this once" direct pushes.

---

<a id="s26"></a>
## Q26. How did you handle a situation where a Git clone operation was failing due to authentication issues?

**A (Sample Answer):**
A `git clone` on a new server kept failing with a `403`/authentication error. I checked a few things in order: whether we were using HTTPS with an old/expired Personal Access Token (GitHub no longer accepts plain passwords), whether the token actually had the `repo` scope enabled, and whether the SSH key (if using SSH) was actually added to the correct GitHub account and loaded into `ssh-agent`. In this case, the PAT had expired the previous week — generating a fresh token with the correct scope and updating it in the deployment secret resolved it immediately.

---

<a id="s27"></a>
## Q27. Explain how you verified Git remote URL misconfiguration in a live CI/CD pipeline.

**A (Sample Answer):**
A CI/CD job was mysteriously pushing tags to the wrong repository (a fork instead of the main org repo). I checked the configured remotes directly on the runner:
```
git remote -v
```
This revealed `origin` was still pointing at a personal fork URL from an earlier debugging session, instead of the organization's repo. I corrected it with:
```
git remote set-url origin https://github.com/org/actual-repo.git
```
and updated the pipeline configuration so the remote URL was always set explicitly at the start of the job, rather than relying on whatever was left over from a previous run.

---

<a id="s28"></a>
## Q28. How did you use git cherry-pick to backport a fix to multiple branches?

**A (Sample Answer):**
A critical security fix was merged into `main`, but we also had two older release branches (`release-1.x`, `release-2.x`) still supported in production, which needed the same fix without pulling in all the newer, unrelated changes from `main`. I cherry-picked just that one commit into each:
```
git checkout release-1.x
git cherry-pick <fix-commit-hash>

git checkout release-2.x
git cherry-pick <fix-commit-hash>
```
This applied only that specific fix to each older branch, keeping them otherwise untouched, and each branch was then tagged and redeployed independently.

---

<a id="s29"></a>
## Q29. How did you clean up a large .git history that was bloated due to committed binaries?

**A (Sample Answer):**
Our repo had ballooned to over 2 GB because someone had committed several large `.zip` and `.mp4` files early on, and even after deleting those files later, the old versions still lived in history, bloating every future clone. I used **BFG Repo-Cleaner** (faster and simpler than `git filter-branch`) to strip them out completely:
```
bfg --delete-files "*.zip" my-repo.git
bfg --strip-blobs-bigger-than 50M my-repo.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```
After force-pushing the cleaned history (with the whole team informed in advance to re-clone), the repo size dropped drastically. For any large files still genuinely needed going forward, we moved to **Git LFS** instead of committing them directly.

---

<a id="s30"></a>
## Q30. Explain how you monitored contributors and PR activity in a GitHub organization.

**A (Sample Answer):**
For visibility across multiple repos in our GitHub org, I used the built-in **Insights → Pulse/Contributors** graphs on each repo for a quick view of recent activity, and for org-wide reporting, used the **GitHub GraphQL/REST API** to pull PR counts, review turnaround time, and open/stale PR lists into a simple internal dashboard. This helped us spot issues early — for example, PRs sitting unreviewed for more than 2 days, or one team consistently having slower review turnaround than others — and address it in retros, instead of only noticing it anecdotally.

---

<a id="s31"></a>
## Q31. How did you use environment-specific branches like dev, qa, stage, and prod?

**A (Sample Answer):**
We mapped each long-lived branch to a real deployed environment: `dev` auto-deployed on every push (for developers to see changes instantly), `qa` was updated by merging `dev` into it once a feature was ready for formal testing, `stage` mirrored production configuration for final sign-off, and `prod` (or `main`) only received merges from `stage` after sign-off, and deployed to actual production. Promotion always flowed one direction — `dev → qa → stage → prod` — never backward, and each merge was itself a mini "release gate" with its own checks.

---

<a id="s32"></a>
## Q32. How did you enforce standard commit messages across teams?

**A (Sample Answer):**
We adopted the **Conventional Commits** format (`feat: add login retry`, `fix: correct rounding in billing`, `chore: update dependencies`), and enforced it automatically using a `commit-msg` Git hook powered by **commitlint**, wired up through **Husky**, so a badly formatted commit message would fail locally before it could even be pushed:
```
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit "$1"'
```
This wasn't just for tidiness — since messages followed a fixed format, we could later auto-generate changelogs (see [Q35](#s35)) directly from commit history, with zero manual changelog writing.

---

<a id="s33"></a>
## Q33. Share a situation where you used GitHub CLI or API from a shell script.

**A (Sample Answer):**
For a release automation script, instead of manually creating a GitHub Release every time, I used the **GitHub CLI (`gh`)** directly inside our deployment shell script:
```
gh release create v2.5.0 --title "v2.5.0" --notes-file CHANGELOG.md
gh pr list --state open --json number,title
```
This let the script create releases, list open PRs, and even auto-merge PRs that met certain label conditions, all authenticated using a token already configured for `gh`, without writing raw `curl` calls against the REST API for every single operation.

---

<a id="s34"></a>
## Q34. How did you use GitHub Actions to restrict production deployment only from the prod branch?

**A (Sample Answer):**
To make sure production deploys could never accidentally run from a feature branch or `develop`, the workflow itself checked the branch explicitly:
```yaml
jobs:
  deploy-prod:
    if: github.ref == 'refs/heads/prod'
    runs-on: ubuntu-latest
    ...
```
On top of that, we used a GitHub **Environment** named `production` with "required reviewers" and "deployment branch policy" set to only allow `prod` — so even if someone tried to manually trigger the workflow from another branch, GitHub itself would block the deployment step before it ran.

---

<a id="s35"></a>
## Q35. How did you manage changelogs during a large release using Git commit history?

**A (Sample Answer):**
Since our commits already followed the Conventional Commits format (see [Q32](#s32)), we didn't write changelogs by hand — we generated them directly from git history between the last two tags:
```
git log v2.4.0..v2.5.0 --oneline
```
and used a tool like **git-cliff** (or `standard-version`) to automatically group commits into "Features," "Fixes," and "Chores" sections and produce a clean `CHANGELOG.md` for the release notes, based purely on the commit messages. This guaranteed the changelog was always accurate and up to date, since it came straight from the actual commits, rather than someone trying to remember everything that changed right before a release.
