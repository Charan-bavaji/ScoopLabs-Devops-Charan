# Linux Automation Scripting - Text Processing (grep, awk, sed)

## Concept: Primary Use Cases

| Tool | Primary Use Case |
|---|---|
| **grep** | Searching — scans text and prints lines matching a given pattern. Used for finding specific entries in logs, configs, or any text (e.g. all lines containing "ERROR", a username, an IP address). |
| **awk** | Column-based processing — treats each line as a row split into fields (by whitespace by default), letting you extract, reorder, or compute on specific columns. Useful for pulling out a single field from structured log lines or summing numeric data. |
| **sed** | Stream editing — performs find-and-replace or other text transformations (substitution, deletion, insertion) as data flows through, without manually opening a file in an editor. |

**Mental model:** grep *finds*, awk *extracts/computes*, sed *transforms*.

## Hands-on Task

### 1. Dummy Log File — `server.log`

Created using a heredoc (writes multiple lines to a file in one command):

```bash
cat <<EOF > server.log
2026-06-17 10:00:01 INFO Server started successfully
2026-06-17 10:01:15 INFO User login: charan
2026-06-17 10:02:30 ERROR Database connection failed
2026-06-17 10:03:45 INFO Cache refreshed
2026-06-17 10:04:10 WARNING Disk usage at 80%
2026-06-17 10:05:22 ERROR Timeout while connecting to API
2026-06-17 10:06:33 INFO Backup completed
2026-06-17 10:07:48 ERROR Null pointer exception in payment module
2026-06-17 10:08:59 INFO User logout: charan
2026-06-17 10:09:05 INFO Health check passed
EOF
```

### 2. grep Command Used

```bash
grep "ERROR" server.log
```

### 3. Output

```
2026-06-17 10:02:30 ERROR Database connection failed
2026-06-17 10:05:22 ERROR Timeout while connecting to API
2026-06-17 10:07:48 ERROR Null pointer exception in payment module
```

<img width="947" height="1021" alt="image" src="https://github.com/user-attachments/assets/9ffe5474-5f6f-40a9-9dd8-0aaae52d1026" />


All 3 lines containing "ERROR" were correctly extracted from the 10-line log file, with no false matches.

## Submission Checklist

- [x] Dummy log file (`server.log`) created with 10 lines
- [x] `grep "ERROR" server.log` command documented
- [x] Output captured above
