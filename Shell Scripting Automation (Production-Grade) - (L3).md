# Shell Scripting Automation (Production-Grade) - (L3)

## Problem Statement

Onboarding 50 new developers manually onto Linux jump servers is slow and error-prone — typos in `useradd`, weak or reused passwords, and inconsistent audit trails are exactly the kind of small mistakes that turn into real security incidents. A production-grade onboarding script removes the human error factor by enforcing four non-negotiable security practices automatically:

1. **Privilege enforcement** — only root/sudo can create system accounts, so the script can't be run accidentally (or maliciously) by a regular user.
2. **Safe input handling** — the script validates the username argument and refuses to silently overwrite an existing account.
3. **No hardcoded credentials** — every new account gets a unique, randomly generated temporary password instead of a predictable default like `Welcome123`, which would be a shared secret across all 50 new hires if reused.
4. **Forced password rotation + audit logging** — the temp password is known to the admin, so compliance requires the user be forced to set their own password on first login, and every onboarding action is logged with a timestamp for traceability.

## The Script — `onboard_user.sh`

```bash
#!/bin/bash

# Step 1: Root privilege check
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Please run this script as root or using sudo"
    exit 1
fi

# Step 2: Input validation
USERNAME="$1"

if [ -z "$USERNAME" ]; then
    echo "Usage: ./onboard_user.sh <username>"
    exit 1
fi

if id "$USERNAME" &>/dev/null; then
    echo "Error: User $USERNAME already exists."
    exit 1
fi

# Step 3: User creation and password generation
useradd -m "$USERNAME"

TEMP_PASS=$(date +%s | sha256sum | base64 | head -c 12)
echo "$USERNAME:$TEMP_PASS" | chpasswd

# Step 4: Force password change on first login + logging
chage -d 0 "$USERNAME"

LOG_FILE="/var/log/user_onboarding.log"
echo "$(date '+%Y-%m-%d %H:%M:%S') - User '$USERNAME' onboarded successfully." >> "$LOG_FILE"

echo "Success: User '$USERNAME' created."
echo "Temporary Password: $TEMP_PASS"
echo "User must change password on first login."
```

## Steps Followed

### Random password generation logic

Instead of hardcoding a temp password, the script generates a unique one per run:

```bash
TEMP_PASS=$(date +%s | sha256sum | base64 | head -c 12)
```

This pipes the current Unix timestamp (`date +%s`) through a SHA-256 hash, base64-encodes the result, and truncates it to 12 characters. Since `date +%s` changes every second, every script execution produces a different, unpredictable password — no two new hires ever get the same temporary credential, and the password can't be guessed from the script's source code.

### Forced password change

```bash
chage -d 0 "$USERNAME"
```

Setting the "last password change" date to day 0 (the Unix epoch) tells the system the password is immediately expired, regardless of any password-aging policy. This forces a password reset on the account's next authenticated login.

### Audit logging

```bash
echo "$(date '+%Y-%m-%d %H:%M:%S') - User '$USERNAME' onboarded successfully." >> "$LOG_FILE"
```

Every successful onboarding appends a timestamped line to `/var/log/user_onboarding.log` using `>>` (append, not overwrite), so the log accumulates a permanent audit trail across all 50 onboardings without ever losing prior entries.

## Testing — Edge Cases

### Test 1: Run without root privileges

```
[ec2-user@ip-172-31-31-228 ~]$ ./onboard_user.sh
Error: Please run this script as root or using sudo
```

Fails gracefully with a clean custom error instead of a permission-denied stack trace from `useradd`.

### Test 2: Run as root with no arguments

```
[ec2-user@ip-172-31-31-228 ~]$ sudo ./onboard_user.sh
Usage: ./onboard_user.sh <username>
```

### Test 3: Attempt to onboard an existing user

```
[ec2-user@ip-172-31-31-228 ~]$ sudo ./onboard_user.sh root
Error: User root already exists.
```

### Test 4: Successful onboarding

```
[ec2-user@ip-172-31-31-228 ~]$ sudo ./onboard_user.sh jdoe
Success: User 'jdoe' created.
Temporary Password: Mzc5OTg3OTAx
User must change password on first login.
```

### Test 5: Verify forced password expiry

```
[ec2-user@ip-172-31-31-228 ~]$ sudo chage -l jdoe
Last password change                                    : password must be changed
Password expires                                         : password must be changed
Password inactive                                        : password must be changed
Account expires                                          : never
Minimum number of days between password change           : 0
Maximum number of days between password change           : 99999
Number of days of warning before password expires        : 7

[ec2-user@ip-172-31-31-228 ~]$ sudo passwd -S jdoe
jdoe PS 1970-01-01 0 99999 7 -1 (Password set, unknown crypt variant.)
```

Both outputs confirm the password is correctly flagged as expired (`1970-01-01` is the epoch marker `chage -d 0` produces). The account is locked into "must change password" state before any authenticated session can proceed.

**Note on `su` vs. real login:** Running `sudo su - jdoe` directly from root does *not* trigger the interactive "change your password" prompt, because `su` invoked by root doesn't go through PAM's authentication step for jdoe — root is implicitly trusted, so the password-expiry check that fires on a real login is bypassed. This is expected Linux behavior, not a flaw in the script. The expiry itself, verified above via `chage -l` and `passwd -S`, is the authoritative proof that the policy is enforced; it would correctly block a real SSH login or a `su` performed by a non-root user who has to authenticate with jdoe's password.

## Logs

Contents of `/var/log/user_onboarding.log` after the test run:

```
2026-06-19 00:58:36 - User 'jdoe' onboarded successfully.
```

## Summary

The script meets all production requirements: it refuses to run without root, validates and sanity-checks its input, never hardcodes a password, generates a unique temporary credential per execution, enforces a mandatory password change before the account can be used, and writes a timestamped audit entry for every onboarding — ready to scale to all 50 new hires without manual intervention.

<img width="737" height="363" alt="image" src="https://github.com/user-attachments/assets/0847b53b-a6bf-4084-9f5c-1782de440cd8" />
<img width="935" height="307" alt="image" src="https://github.com/user-attachments/assets/f85dd563-a763-4649-b38d-f3ca03e86a11" />


