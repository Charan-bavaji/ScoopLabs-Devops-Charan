# Functions - L1

## Description
Creating reusable blocks of code using functions.

## Concept Task
**Why is code modularity important in DevOps automation?**
- **Reusability** — write logic once (e.g. `calculate_storage`) and reuse it
  across multiple scripts instead of duplicating code.
- **Easier maintenance** — a bug fix or logic update happens in one place
  instead of being repeated across many scripts.
- **Easier testing** — small, focused functions are simpler to test in
  isolation before being used in larger automation pipelines.
- **Readability** — automation scripts (deployments, monitoring, backups)
  become easier for teammates to read, understand, and extend.

## Hands-on Task
A Python script (`calculate_storage.py`) that:
- Defines a function `calculate_storage(total_bytes)` which converts a byte
  value into Gigabytes (GB)
- Calls the function with an example value and prints the result

## How to Run
```bash
python3 calculate_storage.py
```

## Sample Output
```
Total Bytes: 5000000000
Storage in GB: 4.66 GB
```

## Files
- `calculate_storage.py` — main script
- `execution_output.png` — execution output screenshot (add before pushing)
