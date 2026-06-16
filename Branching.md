# Git Branching — L1 Assignment

---

## Concept Task: Why is Branching a Best Practice?

- **Isolation** — Each feature or fix is developed in its own branch, so it doesn't break the main codebase.
- **Parallel work** — Multiple developers can work on different features simultaneously without conflicts.
- **Safe experimentation** — You can try new ideas in a branch; if it fails, just delete the branch — main is untouched.
- **Clean history** — Each branch represents one unit of work, making commit history easy to read and review.
- **Code review** — Changes are merged into main only after review (via Pull Request), maintaining code quality.

> **Bottom line:** Branching keeps the `main` branch always stable and production-ready while development happens safely in isolation.

---

## Hands-on Task: Git Commands Sequence

### Step 1 — Navigate to the repository
```bash
cd /d/ScoopLabs/GitHubActionsPrac
```

### Step 2 — Create a new branch
```bash
git branch feature-update
```
- Creates a new branch called `feature-update` from the current `main`.

### Step 3 — Verify both branches exist
```bash
git branch
  feature-update
* main
```
- `*` indicates the currently active branch is `main`.

### Step 4 — Switch to the new branch
```bash
git checkout feature-update
Switched to branch 'feature-update'
```

### Step 5 — Modify README.md
```bash
vi README.md
```
- Edited the file directly in the `feature-update` branch.

### Step 6 — Check status
```bash
git status
On branch feature-update
Changes not staged for commit:
        modified:   README.md
```
- Git detects the modification in the Working Directory.

### Step 7 — Stage and commit the changes
```bash
git add .
git commit -m "updated read me file"
[feature-update 563cc5b] updated read me file
 1 file changed, 1 insertion(+)
```

### Step 8 — Verify active branch
```bash
git branch
* feature-update
  main
```
- `*` is now on `feature-update` — confirming we are on the correct branch ✅
- Changes are committed to `feature-update` only — `main` is untouched ✅

---

## Summary of Commands Used

| Purpose | Command |
|---|---|
| Create branch | `git branch feature-update` |
| List branches | `git branch` |
| Switch branch | `git checkout feature-update` |
| Check status | `git status` |
| Stage changes | `git add .` |
| Commit changes | `git commit -m "updated read me file"` |


<img width="946" height="820" alt="image" src="https://github.com/user-attachments/assets/5d3bb05b-bfd5-48f3-a209-3673b3de0374" />
