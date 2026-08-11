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
## Code
 
```python
"""
Assignment: Functions - L1
Task: Write a function that converts bytes to Gigabytes (GB) and print the result.
"""
 
def calculate_storage(total_bytes):
    """Convert a value in bytes to Gigabytes (GB)."""
    gb = total_bytes / (1024 ** 3)
    return gb
 
 
# Call the function and print the result
total_bytes = 5000000000  # example: 5,000,000,000 bytes
storage_in_gb = calculate_storage(total_bytes)
 
print(f"Total Bytes: {total_bytes}")
print(f"Storage in GB: {storage_in_gb:.2f} GB")
```

<img width="1916" height="1018" alt="Screenshot 2026-08-11 090445" src="https://github.com/user-attachments/assets/f3be7b81-14ac-4ede-882d-4ec9158b1f2d" />

