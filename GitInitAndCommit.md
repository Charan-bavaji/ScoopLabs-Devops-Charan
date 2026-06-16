# Git — Tracking Local File Changes (L1 Assignment)

---

## Concept Task: The Three States in Git

### 1. Working Directory
- Where you actively create, edit, or delete files.
- Git sees these changes but does **not** track them yet.
- Files here are either **untracked** (new) or **modified** (changed).

### 2. Staging Area
- A preparation zone before committing.
- You explicitly tell Git which changes to include using `git add`.
- Think of it as a "ready to commit" checklist.

### 3. Local Repository
- Where Git permanently saves your snapshots via `git commit`.
- Every commit is a point-in-time record of your staged changes.
- Stored in the hidden `.git` folder inside your project.

---

### Flow Diagram

```
Working Directory  →  Staging Area  →  Local Repository
   (edit files)       (git add)          (git commit)
```

---

## Hands-on Task: Git Commands Sequence

### Step 1 — Initialize a new Git repository
```bash
git init
```
- Creates a hidden `.git` folder — this is your local repository.

### Step 2 — Create a README file
```bash
touch README.md
```
- File exists in the **Working Directory**, not yet tracked by Git.

### Step 3 — Check status
```bash
git status
```
- Shows `README.md` as an **untracked file**.

### Step 4 — Stage the file
```bash
git add README.md
```
- Moves `README.md` from Working Directory → **Staging Area**.

### Step 5 — Make the first commit
```bash
git commit -m "Initial commit: Add README"
```
- Saves the staged snapshot permanently into the **Local Repository**.

### Step 6 — Verify with git log
```bash
git log --oneline
```
**Output:**
```
009387d File System Navigation — L1
a5d80cf Package Management L1
...
```
- Each line is a commit — a saved snapshot in the local repository ✅

---

## Summary of Commands Used

| Purpose | Command |
|---|---|
| Initialize repo | `git init` |
| Create file | `touch README.md` |
| Check status | `git status` |
| Stage file | `git add README.md` |
| Commit with message | `git commit -m "Initial commit: Add README"` |
| View commit history | `git log --oneline` |
