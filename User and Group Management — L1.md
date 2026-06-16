# File System Navigation — L1 Assignment

---

## Concept Task: Absolute Path vs Relative Path

| | Absolute Path | Relative Path |
|---|---|---|
| **Starts with** | `/` (root) | Current directory (no `/`) |
| **Works from** | Anywhere in the system | Only from the correct current directory |
| **Example** | `cd /project/src/main` | `cd project/src/main` |
| **When to use** | When you want a guaranteed path | When you're already in the parent directory |

> **Simple rule:** Absolute path = full address from root. Relative path = directions from where you are right now.

---

## Hands-on Task

### Step 1 — Create nested directory structure
```bash
root@Ozoo:/# mkdir -p /project/src/main
```
- `-p` → creates all parent directories in one command (project → src → main).

---

### Step 2 — Navigate using Relative Path
```bash
root@Ozoo:/# cd project/src/main
root@Ozoo:/project/src/main#
```
- No `/` at the start → relative path.
- Works here because current directory is `/`, which contains `project`.

---

### Step 3 — Relative path fails from a different location
```bash
root@Ozoo:/project/src/main# cd /home/charan
root@Ozoo:/home/charan# cd project/src/main
-bash: cd: project/src/main: No such file or directory
```
- Same relative path **fails** because `/home/charan` does not contain a `project` folder.
- This proves relative paths depend on **where you currently are**.

---

### Step 4 — Navigate using Absolute Path
```bash
root@Ozoo:/home/charan# cd /project/src/main
root@Ozoo:/project/src/main#
```
- Starts with `/` → absolute path.
- Works from **anywhere** on the system regardless of current location.

---

### Step 5 — Create an empty file
```bash
root@Ozoo:/project/src/main# touch app.log
```
- `touch` creates an empty file if it doesn't exist.

---

### Step 6 — Verify the structure
```bash
root@Ozoo:/project/src/main# ls -R /project
/project:
src

/project/src:
main

/project/src/main:
app.log
```
- `-R` → lists all contents recursively.
- Full nested structure confirmed: `/project/src/main/app.log` ✅

---

## Summary of Commands Used

| Purpose | Command |
|---|---|
| Create nested directories | `mkdir -p /project/src/main` |
| Navigate with relative path | `cd project/src/main` |
| Navigate with absolute path | `cd /project/src/main` |
| Create empty file | `touch app.log` |
| Verify structure | `ls -R /project` |


<img width="960" height="702" alt="image" src="https://github.com/user-attachments/assets/d84e1524-9f08-411b-9785-28cdf655bae5" />
