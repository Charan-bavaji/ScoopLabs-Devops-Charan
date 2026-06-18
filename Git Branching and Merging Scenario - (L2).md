# Git Branching and Merging Scenario — L2

---

## Problem Statement

While working on a software project, `main` represents the stable, production-ready codebase. To build a new "login feature" without risking breaking production code, an isolated `dev` branch was created. The feature was developed and committed inside `dev`, verified to be completely isolated from `main`, and then merged back cleanly once finished.

**Why a branch was used:**
- Keeps `main` always stable and deployable.
- Allows safe experimentation — if the feature broke something, only `dev` would be affected.
- Enables clean, traceable history through isolated commits before merging.

---

## Step-by-Step Git Command Log

### Step 1 — Confirm starting point on main
```bash
$ git switch main
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
```

### Step 2 — Create and switch to dev branch
```bash
$ git checkout -b dev
Switched to a new branch 'dev'

$ git status
On branch dev
nothing to commit, working tree clean
```
- `dev` is now an isolated copy of `main`, ready for feature work.

### Step 3 — Build the feature in dev
```bash
$ echo "Version 1.1 Added experimental login feature" >> app.txt

$ git diff
(shows new file content as a change)

$ git add app.txt
$ git commit -m "Add Login feature to dev branch"
[dev d4da5a3] Add Login feature to dev branch
 1 file changed, 1 insertion(+)
 create mode 100644 app.txt
```

### Step 4 — Verify isolation, then merge into main
```bash
$ git checkout main
Switched to branch 'main'

$ cat app.txt
cat: app.txt: No such file or directory
```
- **Proof of isolation:** `app.txt` does not even exist on `main` — confirming the feature work was completely contained inside `dev` and never touched the stable branch.

```bash
$ git merge dev
Updating 3d632a3..d4da5a3
Fast-forward
 app.txt | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 app.txt

$ cat app.txt
Version 1.1 Added experimental login feature
```
- After merging, the feature file now appears on `main` ✅

### Step 5 — Verify history and clean up
```bash
$ git log --graph --oneline --all
* d4da5a3 (HEAD -> main, dev) Add Login feature to dev branch
| * 563cc5b (origin/feature-update, feature-update) updated read me file
|/
* 3d632a3 (origin/main, origin/charan, origin/HEAD) created home2 folder and create file
* bf1894b first commit
```
- This is a **fast-forward merge** — `dev`'s commit was simply placed on top of `main` since `main` had no new commits in between.

```bash
$ git branch -d dev
Deleted branch dev (was d4da5a3).
```
- Feature is safely merged, so the stale `dev` branch is removed to keep the workspace clean.

### Step 6 — Push to remote
```bash
$ git push
To https://github.com/Charan-bavaji/GitHubActionsPrac.git
   3d632a3..d4da5a3  main -> main
```

## Summary of Commands Used

| Purpose | Command |
|---|---|
| Switch to main | `git switch main` |
| Create + switch to new branch | `git checkout -b dev` |
| Check branch status | `git status` |
| Modify file | `echo "..." >> app.txt` |
| View changes | `git diff` |
| Stage changes | `git add app.txt` |
| Commit changes | `git commit -m "..."` |
| Switch branch | `git checkout main` |
| Merge branch | `git merge dev` |
| View history graph | `git log --graph --oneline --all` |
| Delete merged branch | `git branch -d dev` |
| Push to remote | `git push` |


<img width="1918" height="1020" alt="image" src="https://github.com/user-attachments/assets/828acda7-d913-4a8a-bfd0-1cf3dff533a9" />

