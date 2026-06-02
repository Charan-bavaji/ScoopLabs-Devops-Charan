# Linux File Permissions Assignment

## Problem Statement

Managing security and access to files in Linux using numeric (octal) permissions.

### Tasks

1. Explain what numeric permission **755** means for **Owner**, **Group**, and **Others**.
2. Create `script.sh` and set permissions so only the owner can execute it, but everyone can read it.

---

# Part 1: Understanding 755 Permissions

Each digit in **755** represents permissions for **Owner**, **Group**, and **Others** respectively.

| Category | Digit | Permissions |
|-----------|--------|-------------|
| Owner | 7 | Read + Write + Execute (**rwx**) |
| Group | 5 | Read + Execute (**r-x**) |
| Others | 5 | Read + Execute (**r-x**) |

### Symbolic Representation

```bash
-rwxr-xr-x
```

### Permission Values

| Permission | Value |
|------------|--------|
| Read (r) | 4 |
| Write (w) | 2 |
| Execute (x) | 1 |

### Calculation

```text
7 = 4 + 2 + 1 = rwx
5 = 4 + 0 + 1 = r-x
5 = 4 + 0 + 1 = r-x
```

### Meaning

- **Owner** can read, write, and execute the file.
- **Group** can read and execute the file but cannot modify it.
- **Others** can read and execute the file but cannot modify it.

---

# Part 2: Hands-on Task

## Goal

Create a file named `script.sh` and configure permissions so that:

| Category | Permissions |
|-----------|-------------|
| Owner | Read + Execute |
| Group | Read Only |
| Others | Read Only |

This corresponds to permission **544**:

```text
5 = 4 + 1 = r-x
4 = 4     = r--
4 = 4     = r--
```

### Symbolic Representation

```bash
-r-xr--r--
```

---

## Steps Followed

### Step 1: Create the File

```bash
touch script.sh
```

### Step 2: Verify Initial Permissions

```bash
ls -l script.sh
```

Example Output:

```bash
-rw-r--r-- 1 user user 0 Jun 2 2026 script.sh
```

### Step 3: Apply Required Permissions

```bash
chmod 544 script.sh
```

### Step 4: Verify the Changes

```bash
ls -l script.sh
```

Expected Output:

```bash
-r-xr--r-- 1 user user 0 Jun 2 2026 script.sh
```

---

## Commands Used

```bash
touch script.sh        # Create the file
chmod 544 script.sh    # Owner = read + execute, Group = read, Others = read
ls -l script.sh        # Verify permissions
```

---

## Output Verification

```bash
-r-xr--r-- 1 user user 0 Jun 2 2026 script.sh
```

### Permission Breakdown

| Symbol | Meaning |
|---------|---------|
| `-` | Regular file |
| `r-x` | Owner can read and execute |
| `r--` | Group can only read |
| `r--` | Others can only read |

---

# Conclusion

Permission **544** successfully allows:

- ✅ Owner to **read and execute** the file.
- ✅ Group to **read only**.
- ✅ Others to **read only**.
- ❌ No one can write to the file.

This ensures that only the owner can execute the script while everyone else can view its contents.
<img width="960" height="946" alt="image" src="https://github.com/user-attachments/assets/50c236f3-e9db-4d3b-8368-dd3ae3766960" />

