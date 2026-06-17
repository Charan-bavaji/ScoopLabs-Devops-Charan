# Linux Automation Scripting - (L2)

## Scenario

As a Junior DevOps Engineer, the task was to build an automated daily backup system: compress a target directory, stamp the archive with the current date so old backups are never overwritten, save it to a dedicated backup location, and schedule it to run automatically every midnight via `cron`.

## Environment Setup

```bash
mkdir -p /home/devuser/app_data
touch /home/devuser/app_data/log1.txt /home/devuser/app_data/log2.txt /home/devuser/app_data/config.yaml
mkdir -p /home/devuser/backups
```

A dummy source directory (`app_data`) with sample files, and a destination directory (`backups`) to receive the compressed archives.

## The Script — `daily_backup.sh`

```bash
#!/bin/bash
SOURCE_DIR=/home/devuser/app_data
DEST_DIR=/home/devuser/backups
DATE=$(date +%Y-%m-%d)
BACKUP_FILENAME="backup_${DATE}.tar.gz"

if [ -d "$SOURCE_DIR" ]; then
    echo "Directory exists, proceeding ..."
else
    echo "Error: $SOURCE_DIR not found!"
    exit 1
fi

tar -czvf ${DEST_DIR}/${BACKUP_FILENAME} ${SOURCE_DIR}
echo "Backup completed successfully"
```

### How it works

- **Variables** (`SOURCE_DIR`, `DEST_DIR`, `DATE`, `BACKUP_FILENAME`) keep paths and filenames out of hardcoded values, so the script is portable to other folders/servers.
- **`DATE=$(date +%Y-%m-%d)`** uses command substitution to capture today's date in `YYYY-MM-DD` format, guaranteeing every backup file is uniquely named and sortable.
- **The `if [ -d "$SOURCE_DIR" ]` check** is a guard clause — it tests whether the source directory actually exists before doing any work. If it doesn't, the script prints a clear error and exits with `exit 1` (a non-zero exit code signaling failure), instead of silently producing a broken or empty archive.
- **`tar -czvf`** creates (`-c`), gzip-compresses (`-z`), and verbosely lists (`-v`) the files being archived into the file (`-f`) specified right after the flag.

## Making It Executable

```bash
chmod +x daily_backup.sh
./daily_backup.sh
```

## Test Results

**Normal run** (source directory exists):
```
Directory exists, proceeding ...
tar: Removing leading `/' from member names
home/devuser/app_data/
home/devuser/app_data/log1.txt
home/devuser/app_data/log2.txt
home/devuser/app_data/log3.txt
home/devuser/app_data/config.yaml
Backup completed successfully
```
*(Note: "Removing leading `/`" is expected tar behavior — it stores archive paths as relative rather than absolute, so extraction elsewhere won't forcibly overwrite system paths.)*

Verified with:
```bash
ls -l /home/devuser/backups
```
→ confirmed `backup_2026-06-17.tar.gz` present with correct date stamp.

**Failure run** (source directory missing): script printed the error message and exited immediately via `exit 1`, with no archive created.

## Automation — Cron

```bash
crontab -e
```

Added the following line:

```
0 0 * * * /home/devuser/daily_backup.sh
```

**Schedule breakdown:** minute `0`, hour `0`, every day, every month, every weekday — runs once daily at exactly midnight.

Verified with:
```bash
crontab -l
```
→ confirmed the job is registered.

**Note:** cron jobs must always reference the script by its full absolute path (`/home/devuser/daily_backup.sh`), since cron doesn't run with the same shell environment or working directory as an interactive session — relative paths fail silently.

## Key Concepts Learned

| Concept | Command/Syntax |
|---|---|
| Shebang | `#!/bin/bash` |
| Variable assignment | `name=value` (no spaces around `=`) |
| Command substitution | `$(command)` |
| Date formatting | `date +%Y-%m-%d` |
| Directory existence test | `[ -d "$DIR" ]` (note: spaces required inside brackets) |
| Conditional | `if ... then ... else ... fi` |
| Exit codes | `exit 1` signals failure |
| Compress + archive | `tar -czvf destination.tar.gz source/` |
| Make executable | `chmod +x script.sh` |
| Schedule automation | `crontab -e` / `0 0 * * * /path/to/script.sh` |

<img width="957" height="1016" alt="image" src="https://github.com/user-attachments/assets/23077d31-f495-4b75-a6a0-0bf2d29f8279" />
<img width="957" height="1012" alt="image" src="https://github.com/user-attachments/assets/2ed4a256-0c66-45ba-a7d8-95d1d4f05bee" />
<img width="960" height="302" alt="image" src="https://github.com/user-attachments/assets/2664b13a-2d08-4836-8200-2cf52542f248" />



## Submission Checklist

- [x] `daily_backup.sh` pushed to `devops-learning-journey` repo
- [x] README documents purpose, executable command, cron expression
- [ ] Screenshot of terminal output showing `.tar.gz` creation (add to repo)
