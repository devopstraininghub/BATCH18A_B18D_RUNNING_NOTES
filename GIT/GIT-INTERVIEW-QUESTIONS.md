# Git Interview Questions

## Table of Contents

1. [Git vs GitHub](#q1)
2. [Difference between DVCS and CVCS](#q2)
3. [Basic Git commands used frequently](#q3)
4. [Difference between Git Clone and Fork](#q4)
5. [Can I use both SSH and HTTPS for Git?](#q5)
6. [How to migrate code from one Git repository to another](#q6)
7. [Difference between Git Pull and Git Fetch](#q7)
8. [Difference between git clone and git pull](#q8)
9. [Git Merge vs Rebase](#q9)
10. [Git Merge vs Git Rebase (summary)](#q10)
11. [GitHub repository size limits](#q11)
12. [What is Git Stash?](#q12)
13. [What is Git Cherry-Pick?](#q13)
14. [Use of `git log --oneline` and other filtration commands](#q14)
15. [What is Git Reset? Hard, Soft, and Mixed reset](#q15)
16. [What is Git Revert?](#q16)
17. [Difference between Git Reset and Git Revert](#q17)
18. [Git Branching, Pushing, and Deletion commands](#q18)
19. [What is Git Tag and its real-time usage?](#q19)
20. [How PR works in GitHub and branching policies](#q20)
21. [Branching strategies in Git](#q21)
22. [Branching strategy in Kubernetes, Jenkins, and enterprise projects](#q22)
23. [What is Git Hooks?](#q23)
24. [How do you deal with merge conflicts in Git?](#q24)
25. [Working with large files in Git — What is Git LFS?](#q25)
26. [How to delete a specific commit from Git history](#q26)
27. [What is Git Squash?](#q27)
28. [What are verified commits in GitHub?](#q28)
29. [What is Git Submodule?](#q29)
30. [Difference between Monorepo and Multirepo](#q30)
31. [What is a Git bare repository and its real-time use case?](#q31)
32. [What is Git Bisect and how is it used to find a bug?](#q32)

---

<a id="q1"></a>
## Q. Git vs GitHub

Git is a version control tool that tracks changes in your code.
It enables multiple developers to collaborate on the same codebase efficiently.

GitHub (along with GitLab, Bitbucket, and Azure Repos) is a platform that hosts Git repositories remotely and adds collaboration features like pull requests, issues, and code reviews.

---

<a id="q2"></a>
## Q: What is the difference between Distributed Version Control System (DVCS) and Centralized Version Control System (CVCS)?

**A:**
A Version Control System helps track changes in source code and enables collaboration among developers.

**Centralized Version Control System (CVCS):**
- There is a single central repository.
- Developers must connect to the central server to commit or update code.
- If the central server goes down, collaboration is blocked.
- Offline work is very limited.
- Examples: SVN, CVS, Perforce.

**Distributed Version Control System (DVCS):**
- Every developer has a full copy of the repository, including history.
- Developers can commit, branch, and view history locally without internet access.
- Better performance and reliability.
- No single point of failure.
- Examples: Git

**Key Differences:**

CVCS:
- Single central repository
- Requires constant network access (INTERNET ACCESS)
- Limited offline capabilities
- Slower operations

DVCS:
- Multiple complete repositories
- Supports offline work
- Faster operations
- More reliable and scalable

**Conclusion:**
DVCS (like Git) is more flexible, faster, and widely used in modern software development compared to CVCS.

---

<a id="q3"></a>
## Q: What are the basic Git commands you use frequently or on a daily basis?

**A:**

```
git add .                                                             – to stage all modified files
git commit -m "demo"                                                  – to commit changes with a message
git push origin <branch>                                              – to push commits to the remote branch
git pull origin <branch>                                              – to fetch and merge the latest changes from the remote branch
git clone https://github.com/devopstraininghub/b18projectrepo.git     – to create a local copy of a remote repository
```

---

<a id="q4"></a>
## Q: What is the difference between Git Clone and Fork?

**A:**

**Git Clone:** Creates a copy of the repository on your local machine. You can pull and push changes to the remote repository if you have the required access.

**Fork:** Creates a copy of the repository in your own remote account (for example, on GitHub). It is commonly used when you do not have direct write access to the original repository, and changes are contributed back using a pull request — for open source contribution.

Fork is useful when you want to contribute to the original repository. Fork creates a copy of the repository in your GitHub account. You can make changes and raise a pull request to the original repository. This is helpful when you are working on open-source projects. Example if you want to build some new app over kubernetes, you can fork the kubernetes repository and make changes to the code and raise a pull request.

---

<a id="q5"></a>
## Q: Can I use both SSH and HTTPS for Git?

```
git clone https://github.com/devopstraininghub/b18projectrepo.git
git push https://github.com/devopstraininghub/b18projectrepo.git main
```

**A:**
Yes, you can use both SSH and HTTPS with Git.
SSH is generally more secure and convenient because it does not require entering credentials repeatedly, while HTTPS uses a username and password or token.

When working with multiple GitHub accounts using SSH, you need to configure multiple SSH keys in the `.ssh/config` file. This allows Git to identify which SSH key to use for each account.

Example of adding multiple remotes:

```
git remote add origin2 git@github.com:devopstraininghub/b18projectrepo.git
git remote add origin3 <another-repo-url>
```

---

<a id="q6"></a>
## Q: How can I migrate code from one Git repository to another?

```
git clone https://github.com/devopstraininghub/b18projectrepo.git
cd b18projectrepo
git remote -v
git remote add new-origin <destination-repo-url>
git push new-origin --all
git push new-origin --tags
```

**A:**
You can migrate code from one repository to another by:

1. Cloning the source repository using `git clone <source-repo-url>`
2. Adding the destination repository as a new remote using `git remote add new-origin <destination-repo-url>`
3. Pushing all branches to the new repository using `git push new-origin --all`
4. Pushing all tags (if required) using `git push new-origin --tags`

This process migrates the complete codebase along with the commit history to the new repository.

---

<a id="q7"></a>
## Q: What is the difference between Git Pull and Git Fetch?

**A:**

**Git Fetch:**
Git Fetch downloads the latest changes from the remote repository to your local repository but does not merge them into your current branch. You must manually merge the changes using `git merge origin/<branch>`.

**Git Pull:**
Git Pull is a combination of Git Fetch + Git Merge. It fetches the changes from the remote repository and automatically merges them into your current branch.

> Git Pull --- Git Fetch + Git Merge origin

---

<a id="q8"></a>
## Q: What is the difference between git clone and git pull?

**A:**
`git clone` is used to create a local copy of a remote repository for the first time.
It downloads the complete repository with full history.

`git pull` is used to update an existing local repository. It is basically to bring incremental changes / latest updates from central repo.
It fetches and merges the latest changes from the remote branch.

**Summary:**
- `git clone`: First-time setup
- `git pull`: Update existing repo

---

<a id="q9"></a>
## Git Merge vs Rebase

**MERGE:**
- Combines two branches together.
- Creates a new merge commit to join the histories.
- Does NOT modify existing history (safe operation / NON DESTRUCTIVE ACTION)
- History shows when and where branches are merged.
- But the commit graph can become cluttered (more branches and merge commits).

**REBASE:**
- Moves your branch's commits on top of another branch's latest commit.
- Rewrites history by changing commit parents.
- Produces a clean, linear history
- Best for personal feature branches before pushing.
- Very clean, straight (linear) commit history.
- But rewriting history can be dangerous if used on shared branches.

> The MAIN GOLDEN RULE of rebase is **"NEVER REBASE A PUBLIC REPO USED BY MULTIPLE PEOPLE"**.

---

<a id="q10"></a>
## Q. Git Merge vs Git Rebase?

Both achieve the same goal of merging the changes from one branch to another branch. But Git Merge will not alter the commit history. But Git Rebase will alter the commit history. Git Rebase is used to make the commit history linear. But if you perform too many rebases, it will create a lot of conflicts which will make the commit history complex.

---

<a id="q11"></a>
## What are the GitHub repository size limits?

**A:**
GitHub enforces the following repository size limits and recommendations:

**Maximum file size:**
A single file cannot be larger than 100 MB.

**Recommended repository size:**
GitHub recommends keeping repositories under 1 GB for optimal performance.

**Hard repository size limit:**
Repositories larger than 5 GB may face performance issues, and GitHub may restrict operations on excessively large repositories.

**Large files:**
For files larger than 100 MB, GitHub requires the use of Git LFS (Large File Storage).

---

<a id="q12"></a>
## Q: What is Git Stash?

**A:**
Git Stash is used to temporarily save changes in your working directory without committing them.
It allows you to revert your working directory back to the last commit.
You can later apply the stashed changes back to the same branch or to a different branch.

**Commonly used Git Stash commands:**

1. Save changes to stash
   ```
   git stash
   ```
2. List all stashed changes
   ```
   git stash list
   ```
3. Apply the latest stash and remove it from stash list
   ```
   git stash pop / apply / drop
   ```
4. Apply a specific stash entry
   ```
   git stash pop stash@{0}
   ```
5. Remove all stashed changes
   ```
   git stash clear
   ```

---

<a id="q13"></a>
## Q: What is Git Cherry-Pick?

**A:**
Git Cherry-Pick is used to apply the changes from a specific commit to the current branch.
It is commonly used when you want to apply a particular commit, such as a hotfix, without merging the entire branch.

**Command:**
```
git cherry-pick <commit-hash>
```

---

<a id="q14"></a>
## Q: What is the use of `git log --oneline`? Other filtration commands?

**A:**
The `git log --oneline` command displays the commit history in a compact, one-line format.
The `git log --oneline --graph` command shows the commit history in one line along with a visual representation of branch and merge history.

```
git log -n
git log --oneline
git log --oneline -n
git log --author kiran
git log --since="YYYY-MM-DD"  or  git log --since="December 6 2025"
```

---

<a id="q15"></a>
## Q: What is Git Reset? Explain Hard, Soft, and Mixed reset.

**A:**
Git Reset is used to move the current branch (HEAD) to a specific commit.
Depending on the reset type, it can affect the commit history, staging area, and working directory.

**1. Git Reset --hard**
This resets the commit history, staging area, and working directory.
All changes and commits after the specified commit are permanently deleted (destructive and causes data loss).

```
git reset --hard c224fd2
git reset --hard HEAD~5
```

**2. Git Reset --soft**
This resets only the commit history.
Changes from the removed commits are kept in the staging area.

```
git reset --soft 662bfbd
git reset --soft HEAD~5
```

**3. Git Reset --mixed (default)**
This resets the commit history and staging area.
Changes from the removed commits are kept in the working directory but unstaged.

```
git reset --mixed 662bfbd
git reset --mixed HEAD~5
```

---

<a id="q16"></a>
## Q: What is Git Revert?

**A:**
Git Revert is used to undo the changes introduced by a specific commit without deleting the commit history.
It creates a new commit that reverses the changes of the specified commit.

```
git revert 662bfbd
git revert HEAD~5
```

In the above commands:
- The changes made in the specified commit or commits are reverted.
- The original commit history is preserved.

**Best Practice:**
It is recommended to use `git revert` when working with a public or shared repository.
For personal or private repositories, `git reset` can be used if rewriting history is acceptable.

---

<a id="q17"></a>
## Q: What is the difference between Git Reset and Git Revert?

**A:**
Git Reset moves the HEAD and branch pointer to a previous commit.
It can modify or delete commit history and may also affect the staging area and working directory.
Git Reset is destructive and can cause data loss, so it is mainly used in personal or private repositories.

Git Revert creates a new commit that reverses the changes made by a specific commit.
It does not delete or rewrite commit history.
Git Revert is safe to use in public or shared repositories.

**Summary:**
- Git Reset rewrites history (destructive).
- Git Revert preserves history (non-destructive).
- Use Reset for personal repositories.
- Use Revert for shared or public repositories.

---

<a id="q18"></a>
## Questions Related to Git Branching, Pushing, and Deletion

```
git branch
git branch <br.name>
git checkout <br.name>
git checkout -b <br.name>
git merge <br.name>
git branch -d <br.name>
git branch -D <br.name>
git push origin <br.name>
git push -d origin <br.name>
git remote -v
git rename -m <old-branch-name> <new-branch-name>
```

---

<a id="q19"></a>
## Q: What is Git Tag and its real-time usage?

**A:**
Git Tag is used to mark a specific commit in the repository with a meaningful name.
Tags are commonly used to identify release points such as versions.

**Types of Git Tags:**

1. **Lightweight Tag:**
   - Just a pointer to a commit
   - Used for simple labeling

2. **Annotated Tag:**
   - Stores tag message, author, and date
   - Recommended for releases

**Common Commands:**

Create a tag:
```
git tag v1.0.0
```

Create an annotated tag:
```
git tag -a v1.0.0 -m "Release version 1.0.0"
```

Push tags to remote:
```
git push origin v1.0.0
git push origin --tags
```

**Real-Time Usage:**
- Mark production releases (v1.0, v2.0)
- Roll back to a stable version if needed
- Track deployments and release history
- Used in CI/CD pipelines for version-based deployments

---

<a id="q20"></a>
## Q. How PR works in GitHub and use branching policies?

**A:**

### What is a Pull Request (PR)?

A Pull Request is simply a formal request you raise on GitHub, asking the team/maintainer: "please review my changes, and if okay, merge them into the main branch." It is not a Git command — it is a GitHub feature, built on top of Git, mainly used for code review and safe collaboration.

**Real-time example:** Think of it exactly like submitting your answer sheet to an examiner. You (the developer) don't directly write your marks into the final result — you first submit your paper (raise a PR), the examiner (reviewer) checks it, points out mistakes if any, and only after approval, your answer goes into the "final result" (the main branch).

### How the PR flow works, step by step

1. Create a new branch from `main` for your feature/fix.
   ```
   git checkout -b feature-login
   ```
2. Make your changes, commit, and push that branch to GitHub.
   ```
   git add .
   git commit -m "Added login feature"
   git push origin feature-login
   ```
3. On GitHub, click **"Compare & pull request"** — this opens a PR comparing your branch against `main`, showing exactly what changed (the diff).
4. Reviewers (your teammates) go through the code, leave comments, and can request changes if something is wrong.
5. Automated checks / CI pipelines (build, tests, linting) run automatically in the background, and GitHub shows a pass ✅ or fail ❌ status right inside the PR.
6. Once all checks pass and required reviewers approve, the **Merge** button becomes clickable, and the PR gets merged into `main`.
7. The feature branch is usually deleted after merging, since its job is done.

### Branching Policies — rules to protect important branches like `main`

These are settings a repo admin configures on GitHub (**Settings → Branches → Branch protection rules**), so that nobody can carelessly break an important branch. Think of these as "security guards" standing in front of `main`.

1. **Branch Protection**
   The umbrella rule that locks down a branch (usually `main`/`production`) so that nobody can push directly to it. Every change must go through a Pull Request.
   **Real-time example:** Like a bank locker — nobody, not even a bank employee, can just open it directly. It must go through the proper process every single time.

2. **Required Reviewers**
   At least one (or a specific number, say 2) teammates must review and approve the PR before it is allowed to merge.
   **Real-time example:** Like a cheque above a certain amount needing two signatures before the bank processes it — one person's okay alone is not considered enough.

3. **Required Checks**
   Certain automated checks — build must succeed, unit tests must pass, code style/lint must pass — must all complete successfully before the merge option is even available.
   **Real-time example:** Like a vehicle not getting its fitness certificate until it clears the pollution test and brake test first — the machine checks it before any human even signs off.

4. **Required Status Checks**
   Very close to "Required Checks," but specifically about the CI/CD pipeline (Jenkins, GitHub Actions, etc.) reporting a status back to GitHub — "success" or "failure" — against that exact commit. Until that pipeline shows a green tick, GitHub blocks the merge button, no matter how good the reviewer's comments are.
   **Real-time example:** Like your online exam result showing "pending" — you simply cannot download your certificate until that status changes to "pass."

5. **Required Pull Request Reviews**
   This is the exact GitHub setting name — "Require pull request reviews before merging" — which enforces point 2 above at the platform level. It usually also has an extra option: "Dismiss stale approvals when new commits are pushed," meaning if someone pushes a new commit *after* getting approval, that old approval is cancelled automatically, and the reviewer must check again.
   **Real-time example:** Like a manager approving your leave request, but if you edit the dates *after* getting the approval, the request goes back for re-approval — the old "okay" no longer counts.

### Why all these policies matter — real-time example

Imagine a live production e-commerce application. If any developer could push directly to `main` without review or tests, one small careless mistake (say, a wrong database query) could bring down checkout for lakhs of users, instantly. Branch protection, required reviewers, and required checks together act like multiple safety nets stacked one behind another — even if one net misses the mistake, another one is likely to catch it. This is exactly why almost every serious company enforces these policies on their `main`/`production` branch.

---

<a id="q21"></a>
## Q: What are the branching strategies in Git?

Reference: https://www.gitkraken.com/learn/git/best-practices/git-branch-strategy

**A:**
Branching strategies define how branches are used and managed in a Git repository to support development, releases, and production fixes.

### 1. Git Flow
Git Flow uses multiple long-lived branches.

Branches:
- Production (main/master) branch
- Development (develop) branch
- Feature branches
- Release branches
- Hotfix branches

Hotfix Flow:
- Create a hotfix branch from the Production branch
- Fix the issue in the hotfix branch
- Merge the hotfix branch back into the Production branch
- Also merge the hotfix branch into the Development branch

### 2. GitHub Flow
GitHub Flow is a simple and lightweight branching strategy.
It is suitable for small teams or applications that do not need to maintain multiple versions.

Branches:
- Main branch
- Feature branches

Workflow:
- Create a feature branch from the Main branch
- Complete development and testing
- Merge the feature branch back into the Main branch

### 3. GitLab Flow
GitLab Flow is a combination of Git Flow and GitHub Flow.
It focuses on environment-based branching.

Branches:
- Production branch
- Pre-production (staging) branch

Changes flow from development to pre-production and then to production.

### 4. Trunk-Based Development
Trunk-Based Development focuses on frequent integration into a single main branch.

a. Web application without mobile versions:
- One Production branch
- One Development branch

b. Web application with mobile versions:
- One Production branch
- One Development branch
- One Release branch

The latest Release branch is merged into the Production branch.

---

<a id="q22"></a>
## Q: Which branching strategy is followed by open-source projects like Kubernetes or Jenkins? Which branching strategy do most enterprise production projects follow? What is the branching strategy in your current project?

**A:**
Most large open-source projects such as Kubernetes and Jenkins follow a Trunk-Based Development–style branching strategy with release branches.

**Open-Source Projects (Kubernetes, Jenkins, etc.):**
- A single main (trunk) branch is used for continuous development.
- Short-lived feature branches are created and merged frequently.
- Separate release branches are created for stable versions (for example: release-1.28).
- Bug fixes are cherry-picked from the main branch into release branches when required.

This approach supports:
- Continuous integration
- Multiple supported versions
- Faster and safer releases

**Enterprise Production Projects:**
Most enterprise production projects follow one of the following strategies, depending on team size, release frequency, and product type:

1. **Trunk-Based Development (Most Common in Modern Enterprises)**
   - Main (trunk) branch for continuous integration
   - Short-lived feature branches
   - Release branches for versioned releases
   - Hotfixes are merged back to main

   Used by:
   - Large-scale enterprises
   - Microservices-based applications
   - DevOps and CI/CD-driven environments

2. **Git Flow (Used in Traditional Enterprises)**
   - Separate Development and Production branches
   - Feature, Release, and Hotfix branches
   - Suitable for projects with scheduled releases and strict version control

**Summary:**
- Open-source projects like Kubernetes and Jenkins: Trunk-Based Development with release branches
- Modern enterprises: Trunk-Based Development
- Traditional enterprises with slower release cycles: Git Flow

---

<a id="q23"></a>
## Q. What is Git Hooks?

Git hooks are scripts that Git executes before or after events such as: commit, push, and receive. Git hooks are a built-in feature - no need to download anything. Git hooks are run locally.

---

<a id="q24"></a>
## Q. How do you deal with merge conflicts in Git?

When you have a merge conflict, Git will mark the conflicted area in the file. You need to resolve the conflict manually. You can use `git status` to check the conflicted files. You can use `git diff` to check the changes in the conflicted files. You can use `git add <file>` to stage the changes. You can use `git commit` to commit the changes.

---

<a id="q25"></a>
## Q: How can we work with large files in Git? What is Git LFS?

**A:**
Most Git hosting platforms such as GitHub, GitLab, Bitbucket, and Azure Repos have a maximum file size limit of 100 MB per file. To handle files larger than this limit, we use Git LFS (Large File Storage).

Git LFS stores large files in a separate storage system and keeps only lightweight reference pointers in the Git repository. This helps reduce repository size and improves performance while still allowing version control of large files.

**Steps to use Git LFS:**

1. Install and initialize Git LFS on your local machine
   ```
   git lfs install
   ```
2. Configure Git LFS to track large file types
   ```
   git lfs track "*.iso"
   ```
3. Add the Git LFS tracking configuration
   ```
   git add .gitattributes
   ```
4. Add and commit the large file
   ```
   git add <large-file>
   git commit -m "Added large file using Git LFS"
   ```
5. Push the changes to the remote repository
   ```
   git push origin <branch>
   ```

Using Git LFS ensures large files are managed efficiently without exceeding repository size limits.

---

<a id="q26"></a>
## Q: How can you delete a specific commit in Git from git commit history?

**A:**
You can delete a specific commit using interactive rebase.
Interactive rebase allows you to modify, reorder, or remove commits from the commit history.

**Steps:**

1. Start interactive rebase for the last 5 commits
   ```
   git rebase -i HEAD~5
   ```
2. In the editor, change the word "pick" to "drop" (or delete the line) for the commit you want to remove, then save and exit.

**Alternative:**
You can also start rebase from a specific commit hash (usually the parent of the commit to delete):
```
git rebase -i aaac44b
```

This will remove the selected commit from history.

**Note:**
Rewriting history using rebase should be avoided on public/shared branches.
Use this method mainly for personal or private repositories.

---

<a id="q27"></a>
## Q: What is Git Squash?

**A:**
Git Squash is used to combine multiple commits into a single commit.
It is commonly used to clean up commit history before creating a pull request.

For example, you can squash the last 3 commits into one commit to make the history more readable.
Git Squash is performed using interactive rebase.

**Command:**
```
git rebase -i aaac44b
```

During the interactive rebase:
- Keep "pick" for the first commit.
- Change "pick" to "squash" (or "s") for the commits you want to combine.
- Save and exit, then update the commit message if prompted.

**Note:**
Git Squash rewrites commit history, so it should be used mainly on personal branches or before merging into shared branches.

---

<a id="q28"></a>
## Q. What are verified commits in GitHub?

**A:**

### Why verified commits are needed in the first place

Here is the key problem — Git itself never checks who you really are. Your commit's author name and email come only from `git config user.name` / `git config user.email`, which anyone can type in as whatever they like. So technically, anybody could set `user.name = "Linus Torvalds"` on their own laptop and push a commit that *looks* like it came from him, when it actually didn't.

**Real-time example:** This is exactly like writing someone else's name on a cheque or a signed document by hand — just writing the name doesn't prove it was really them. GitHub's "Verified" badge is the equivalent of a **notarized signature** — cryptographic proof that the commit truly came from the key-holder, and was not tampered with afterward.

### How a commit becomes "Verified"

GitHub checks the commit against a cryptographic signature, using one of three methods:

1. **GPG (GNU Privacy Guard)** — the most common method, you generate a GPG key pair, upload the *public* key to your GitHub account, and sign your commits locally with your *private* key.
2. **SSH** — GitHub also allows using your existing SSH key (the same one used for `git push`/`git clone` over SSH) as a signing key.
3. **S/MIME** — an X.509 certificate-based method, mostly used inside big enterprises that already run their own internal certificate authority.

When you push a signed commit, GitHub matches the signature against the public key registered on your account. If it matches, you get a green **"Verified"** badge next to that commit. If the signature doesn't match, or there's no signature at all, GitHub shows **"Unverified"** (or nothing).

### Setting up GPG signing — step by step

```
gpg --full-generate-key                    # generate a new GPG key pair
gpg --list-secret-keys --keyid-format=long # note down your key ID

gpg --armor --export <key-id>              # print your PUBLIC key
```
Copy that public key and add it under **GitHub → Settings → SSH and GPG keys → New GPG key**.

Then tell Git to use it and sign automatically:
```
git config --global user.signingkey <key-id>
git config --global commit.gpgsign true

git commit -m "my signed commit"           # now this gets signed automatically
```

**Note:** If you commit directly through the GitHub website (editing a file in the browser, merging a PR via the "Merge" button, etc.), GitHub automatically signs that commit on your behalf using its own key — that's why such commits also show "Verified" without you configuring anything.

### Real-time use case

Suppose your company's production deployment pipeline only allows commits with a "Verified" badge to be merged into `main`. Even if an attacker somehow gets hold of a stolen laptop or a leaked GitHub session, they still cannot push a "Verified" commit unless they also have the actual private GPG/SSH key — which typically sits securely on the real developer's machine, often protected by a passphrase. This gives teams a strong guarantee that every change in production history genuinely came from who it claims to have come from, not just from whoever happened to type in a matching name and email.

---

<a id="q29"></a>
## Q: What is Git Submodule?

**A:**
Git Submodule allows you to include one Git repository inside another Git repository.
It is used when your project depends on an external repository but you want to track it at a specific commit.

The main repository stores only a reference (commit ID) of the submodule, not the entire code.

**Common Use Cases:**
- Sharing common libraries across multiple projects
- Managing third-party dependencies
- Keeping independent repositories linked together

**Common Commands:**

Add a submodule:
```
git submodule add https://github.com/devopstraininghub/b18projectrepo.git shared/b18projectrepo
```

Initialize and update submodules after clone:
```
git submodule init
git submodule update
```

Clone repository with submodules:
```
git clone --recurse-submodules https://github.com/devopstraininghub/b18projectrepo.git
```

**Real-Time Example:**
A microservices project using a common configuration or utility repository (like `b18projectrepo`) as a submodule.

---

<a id="q30"></a>
## Q: What is the difference between Monorepo and Multirepo?

**A:**

**Monorepo:**
A Monorepo stores multiple projects or services in a single Git repository.

Advantages:
- Single source of truth
- Easier code sharing and refactoring
- Unified CI/CD pipeline
- Consistent tooling and standards

Disadvantages:
- Large repository size
- Complex access control
- CI/CD can become slower if not optimized

Examples: Google, Facebook, Uber

**Multirepo:**
A Multirepo uses separate Git repositories for each project or service.

Advantages:
- Clear ownership per repository
- Smaller repositories
- Independent release cycles
- Better access control

Disadvantages:
- Harder to share code
- Dependency version management is complex
- Multiple CI/CD pipelines to manage

Examples: Most traditional enterprise projects, microservices-based architectures

**Summary:**
- Monorepo: One repository for many projects
- Multirepo: One repository per project
- Monorepo suits tightly coupled systems
- Multirepo suits loosely coupled services

---

<a id="q31"></a>
## Q: What is a Git bare repository and its real-time use case?

**A:**
A Git bare repository is a repository that does not have a working directory.
It contains only the Git metadata (commits, branches, tags, and objects).

In a bare repository:
- There are no source files to edit
- You cannot run `git status`, edit code, or commit changes directly
- It is used only as a central repository

**How to create a bare repository:**
```
git init --bare project.git
```

**Real-Time Use Cases:**
- Used as a central remote repository on a server
- Acts as a shared repository for team collaboration
- Commonly used in Git servers, CI/CD systems, and deployment pipelines
- Used for mirroring repositories or backup purposes

**Examples:**
- GitHub, GitLab, Bitbucket repositories are bare repositories internally
- On-prem Git servers hosting central repos

---

<a id="q32"></a>
## Q: What is Git Bisect and how is it used to find a bug?

**A:**

### The problem it solves

Suppose your application is working fine, but suddenly somebody finds a bug — and there have been 200 commits since the last time it was known to be working. Manually opening each commit one by one and testing it would take forever. `git bisect` solves exactly this — it finds the **exact commit that introduced a bug**, using a fast **binary search** through your commit history, instead of checking commits one by one from start to end.

**Real-time example:** This is exactly like the "guess the number between 1 and 100" game — instead of guessing 1, 2, 3, 4... one by one, you guess 50 first. If the answer is higher, you jump to 75; if lower, you jump to 25. Each guess cuts the remaining possibilities in half. `git bisect` does the same thing to your commit history — instead of checking 200 commits one at a time, it typically finds the guilty commit in about 7-8 checks (since 2^8 is already more than 200).

### How it works, step by step

1. Start the bisect session:
   ```
   git bisect start
   ```
2. Tell Git a commit where the bug is definitely present (usually the latest/current commit):
   ```
   git bisect bad
   ```
3. Tell Git a commit where things were definitely working fine (an older, known-good commit or tag):
   ```
   git bisect good v1.0
   ```
4. Git now automatically checks out a commit exactly in the middle of that range. You test your application at this point (run it, run your test suite, whatever proves the bug exists or not), and tell Git the result:
   ```
   git bisect good     # if the bug is NOT present here
   git bisect bad       # if the bug IS present here
   ```
5. Git keeps narrowing the range in half, checking out a new "middle" commit each time, until only one commit is left. Git will then report:
   ```
   <commit-hash> is the first bad commit
   ```
6. Once you're done, exit bisect mode and return to your original branch:
   ```
   git bisect reset
   ```

### Automating it (no manual testing needed)

If you already have a script or test command that returns exit code `0` for "good" and non-zero for "bad" (for example, a test suite), you can automate the entire process in one line:
```
git bisect start HEAD v1.0
git bisect run npm test
```
Git will automatically checkout each middle commit, run `npm test`, read the exit code, and keep narrowing down — completely hands-free — until it prints the exact commit that broke things.

### Real-time use case

Say a production application was working fine last Friday (tagged `v2.3`), but today, after 150 commits from 5 different developers, QA reports that "login is broken." Instead of asking every developer "did you touch the login code?" one by one, you simply run:
```
git bisect start
git bisect bad HEAD
git bisect good v2.3
git bisect run ./run-login-test.sh
```
Within about 8 test runs, Git tells you the exact commit (and therefore the exact developer and exact change) that introduced the bug — turning a painful, hours-long manual hunt into a few minutes of automated searching.
