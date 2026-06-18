# Git Conflict Resolution — L2

---

## Problem Statement: How Did the Conflict Happen?

Two developers pulled the same `main` branch and both edited the **same line** in `config.txt`, but with different values:

- **Developer B** (on `main`) changed the port to `Database_Port=3306`.
- **Developer A** (on `feature-db-update`) changed the same line to `database_port=9090`.

When Developer B's branch (`main`) tried to merge in Developer A's branch (`feature-db-update`), Git could not automatically decide which line to keep — both branches had modified the exact same line since their common ancestor commit. This triggered a **merge conflict**, halting the merge and requiring manual resolution.

---

## Step-by-Step Git Command Log

### Step 1 — Baseline on main
```bash
$ echo "Databas_Port=8080" > congig.txt
$ mv congig.txt config.txt
$ git add config.txt
$ git commit -m "Initial commit: Set base database port"
[main ff58b13] Initial commit: Set base database port
 1 file changed, 1 insertion(+)
 create mode 100644 config.txt
$ git push
```
- Base file `config.txt` created and pushed to `main` with the starting value.

### Step 2 — Developer A: feature branch change
```bash
$ git checkout -b feature-db-update
Switched to a new branch 'feature-db-update'

$ echo "database_port=9090" > config.txt
$ git commit -am "Feature: update port to 9000"
[feature-db-update c3d1754] Feature: update port to 9000
 1 file changed, 1 insertion(+), 1 deletion(-)
```

### Step 2 — Developer B: main branch change
```bash
$ git checkout main
Switched to branch 'main'

$ echo "Database_Port=3306" > config.txt
$ git commit -am "Main: Change port to default MySQL 3306"
[main 3371472] Main: Change port to default MySQL 3306
 1 file changed, 1 insertion(+), 1 deletion(-)
```
- Both branches now have **divergent commits** modifying the same line.

### Step 3 — Trigger the conflict
```bash
$ git branch
  feature-db-update
  feature-update
* main

$ git merge feature-db-update
Auto-merging config.txt
CONFLICT (content): Merge conflict in config.txt
Automatic merge failed; fix conflicts and then commit the result.

$ git status
On branch main
Your branch is ahead of 'origin/main' by 1 commit.

You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
        both modified:   config.txt
```
- Git confirms `config.txt` is **"both modified"** — it cannot auto-resolve and needs human intervention.

### Step 4 — Conflict Markers Inside config.txt

Before resolving, `config.txt` looked like this:

```
<<<<<<< HEAD
Database_Port=3306
=======
database_port=9090
>>>>>>> feature-db-update
```

**Reading the markers:**
- `<<<<<<< HEAD` → start of the version on the current branch (`main`)
- `Database_Port=3306` → main's version of the line
- `=======` → divider between the two competing versions
- `database_port=9090` → incoming version from `feature-db-update`
- `>>>>>>> feature-db-update` → end of the incoming branch's change

### Step 5 — Resolve and complete the merge
```bash
$ vi config.txt
```
- Removed all conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) and the `9090` line.
- Kept only: `Database_Port=3306` (business decision: MySQL default port is correct).

```bash
$ git add config.txt
$ git commit
[main cb54d88] Merge branch 'feature-db-update'
```
- Staging tells Git the conflict is resolved.
- Running `git commit` with no message lets Git auto-generate the merge commit message.

### Step 6 — Verify history and push
```bash
$ git log --graph --oneline --all
*   cb54d88 (HEAD -> main) Merge branch 'feature-db-update'
|\
| * c3d1754 (feature-db-update) Feature: update port to 9000
* | 3371472 Main: Change port to default MySQL 3306
|/
* ff58b13 (origin/main, origin/HEAD) Initial commit: Set base database port
```
- The graph clearly shows the **divergence** (two branches editing in parallel) and the **merge commit** bringing them back together.

```bash
$ git push
To https://github.com/Charan-bavaji/GitHubActionsPrac.git
   ff58b13..cb54d88  main -> main
```

---



---

## Summary of Commands Used

| Purpose | Command |
|---|---|
| Create base file | `echo "..." > config.txt` |
| Commit baseline | `git commit -m "Initial commit: Set base database port"` |
| Create feature branch | `git checkout -b feature-db-update` |
| Commit feature change | `git commit -am "Feature: update port to 9000"` |
| Switch back to main | `git checkout main` |
| Commit main change | `git commit -am "Main: Change port to default MySQL 3306"` |
| Attempt merge | `git merge feature-db-update` |
| Check conflict status | `git status` |
| Stage resolved file | `git add config.txt` |
| Complete merge commit | `git commit` |
| View history graph | `git log --graph --oneline --all` |
| Push to remote | `git push` |



<img width="618" height="380" alt="image" src="https://github.com/user-attachments/assets/a1d93fdb-7dd7-4eba-a16e-40cfc0d50c06" />
<img width="711" height="661" alt="image" src="https://github.com/user-attachments/assets/1a1b9754-17ac-41b6-8a5f-711112b65bcb" />
