# Python Automation Task - L2: Disk Space Monitor

## Scenario
As a DevOps engineer, manually checking server health all day isn't
scalable. This script automatically monitors local disk space. If usage
exceeds 80%, it generates a critical alert — with an exact timestamp and
usage percentage — and appends it to a log file named `alerts.log`.

## Step-by-Step Breakdown

### Step 1: Environment Setup & the `shutil` Module
- Imported the built-in `shutil` module.
- Used `shutil.disk_usage("/")`, which returns a named tuple of
  `total`, `used`, and `free` space (in bytes) for the root filesystem.
- Unpacked the tuple into variables and printed the raw byte values to
  confirm the data was real before doing any math.

### Step 2: Math and Percentage Calculation
- Calculated used space as a percentage: `(used / total) * 100`.
- Stored the result in `used_percentage`.
- Rounded it to 2 decimal places with `round()` for readability
  (e.g. `74.52%`).
- Printed it to verify the math.

### Step 3: Adding Timestamps
- Imported the built-in `datetime` module.
- Captured the current moment with `datetime.datetime.now()`.
- Formatted it into a readable `YYYY-MM-DD HH:MM:SS` string using
  `strftime("%Y-%m-%d %H:%M:%S")`.

### Step 4: Conditionals & File Handling
- Wrote an `if used_percentage > THRESHOLD:` check (`THRESHOLD = 80`).
- On trigger, built a formatted alert string including the timestamp and
  usage percentage, e.g.:
  `[2026-08-11 03:45:08] CRITICAL: Disk space running low! Current usage is 85.20%.`
- Used `with open("alerts.log", "a") as file:` to append (not overwrite)
  the alert, adding a `\n` so each alert lands on its own line.

### Step 5: Testing with a Mock Threshold
- Temporarily lowered `THRESHOLD` below the machine's actual usage to
  force the alert branch to run.
- Ran the script, confirmed `alerts.log` was created, and verified the
  message/timestamp were formatted correctly with `cat alerts.log`.
- Reset `THRESHOLD` back to `80` afterward.

## Concept Task
Covered inline as part of the walkthrough above — see Step 1–4 comments
in `disk_monitor.py` for the detailed "why" behind each design choice
(named tuples, append vs. write mode, f-strings, etc.).

## How to Run
```bash
python3 disk_monitor.py
```

To test the alert path, temporarily change `THRESHOLD = 80` to a lower
number (e.g. `1`), run again, then check:
```bash
cat alerts.log
```
Remember to change `THRESHOLD` back to `80` afterward.

## Sample Output (below threshold)
```
---- STEP 1: Raw disk stats (in bytes) ----
Total: 270553174016
Used : 9178406912
Free : 10720509952

---- STEP 2: Calculated usage percentage ----
Used percentage: 3.39%

---- STEP 3: Formatted timestamp ----
2026-08-11 03:45:05

---- STEP 4: No alert ----
Disk usage (3.39%) is below the 80% threshold. All good.
```

## Sample Output (mock test, alert triggered)
```
---- STEP 4: Alert triggered ----
Alert written to alerts.log:
[2026-08-11 03:45:08] CRITICAL: Disk space running low! Current usage is 3.39%.
```

`alerts.log` contents after the mock test:
```
[2026-08-11 03:45:08] CRITICAL: Disk space running low! Current usage is 3.39%.
```

## Code

```python
"""
Assignment: Python Automation Task - L2
Scenario: Monitor local disk space. If usage exceeds 80%, log a
          critical alert (with timestamp) to alerts.log.
"""

# ------------------------------------------------------------------
# STEP 1: Environment Setup & the shutil module
# ------------------------------------------------------------------
# shutil is a built-in Python module used for high-level file and
# system operations. We only need it here for disk_usage().
import shutil

# shutil.disk_usage(path) returns a NAMED TUPLE with 3 fields:
#   total -> total size of the disk/partition (in bytes)
#   used  -> space currently used (in bytes)
#   free  -> space still available (in bytes)
# We point it at "/" (root) to check the main filesystem.
# On Windows this would instead be something like "C:\\".
disk_stats = shutil.disk_usage("/")

# Because disk_usage() returns a named tuple, we can "unpack" it
# directly into three separate variables in one line.
total, used, free = disk_stats

# Printing raw byte values so we can SEE what the OS is actually
# reporting before we do any math on it. Byte values are huge and
# hard to read, but this confirms the data is real.
print("---- STEP 1: Raw disk stats (in bytes) ----")
print("Total:", total)
print("Used :", used)
print("Free :", free)
print()


# ------------------------------------------------------------------
# STEP 2: Math and Percentage Calculation
# ------------------------------------------------------------------
# Formula: (used space / total space) * 100 gives us the percentage
# of the disk that is currently occupied.
# Example: used=80, total=100 -> (80/100)*100 = 80.0%
used_percentage = (used / total) * 100

# round(value, 2) rounds to 2 decimal places, e.g. 74.5231 -> 74.52
# This just makes the number readable/presentable — it does NOT
# change the underlying precision used elsewhere unless we
# reassign it, which we do here since we want the rounded value
# to be what gets logged too.
used_percentage = round(used_percentage, 2)

print("---- STEP 2: Calculated usage percentage ----")
print(f"Used percentage: {used_percentage}%")
print()


# ------------------------------------------------------------------
# STEP 3: Adding Timestamps
# ------------------------------------------------------------------
# datetime is a built-in module for working with dates and times.
import datetime

# datetime.datetime.now() captures the EXACT moment this line runs
# (down to microseconds), as a datetime object — not yet a string.
current_time = datetime.datetime.now()

# A raw datetime object looks messy when printed directly
# (e.g. 2026-08-11 14:23:07.891234). strftime() ("string format
# time") lets us control exactly how it's displayed using format
# codes:
#   %Y -> 4-digit year      %m -> 2-digit month   %d -> 2-digit day
#   %H -> 24-hour hour      %M -> minute           %S -> second
formatted_time = current_time.strftime("%Y-%m-%d %H:%M:%S")

print("---- STEP 3: Formatted timestamp ----")
print(formatted_time)
print()


# ------------------------------------------------------------------
# STEP 4: Conditionals & File Handling
# ------------------------------------------------------------------
# THRESHOLD is pulled out as its own variable (instead of hardcoding
# "80" inline) so it's easy to change in one place — this is what
# lets us do the Step 5 mock test cleanly by editing just this line.
THRESHOLD = 80  # <-- percentage threshold that triggers a CRITICAL alert

if used_percentage > THRESHOLD:
    # An f-string ("formatted string") lets us inject variables
    # directly into the text using {variable_name}.
    # This builds the exact alert line that will go into the log.
    alert_message = (
        f"[{formatted_time}] CRITICAL: Disk space running low! "
        f"Current usage is {used_percentage}%."
    )

    # "with open(...) as file:" is the safe way to work with files.
    # It automatically closes the file for you when the block ends
    # — even if an error happens inside — so you never leak open
    # file handles.
    #
    # Mode "a" = APPEND. It adds new text to the END of the file
    # instead of erasing existing content (which "w" mode would do).
    # This means every time the script runs and finds high usage,
    # a new alert line gets added, and history is preserved.
    with open("alerts.log", "a") as file:
        # "\n" adds a newline character so the NEXT alert (from a
        # future run) starts on its own fresh line instead of being
        # jammed onto the end of this one.
        file.write(alert_message + "\n")

    print("---- STEP 4: Alert triggered ----")
    print("Alert written to alerts.log:")
    print(alert_message)
else:
    print("---- STEP 4: No alert ----")
    print(f"Disk usage ({used_percentage}%) is below the {THRESHOLD}% threshold. All good.")
```

## Files
- `disk_monitor.py` — main script
- `alerts.log` — generated log file (created only when threshold is exceeded)
- `console_output.png` — console output screenshot (add before pushing)
