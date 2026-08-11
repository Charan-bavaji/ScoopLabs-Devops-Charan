# Python Automation Task - L3: Nginx 404 Log Analyzer

## Scenario
The company's primary Nginx web server is experiencing intermittent issues,
and the monitoring team suspects a malicious bot is scanning for hidden
endpoints, resulting in thousands of 404 Not Found errors. This script
parses a raw Nginx access log, identifies all 404 errors, extracts the IP
addresses responsible, counts how many times each IP hit a missing page,
and outputs the intelligence into a structured `report.json` file for the
security team.

## Step-by-Step Breakdown

### Step 1: Environment Setup & Data Generation
- Created a `python-log-parser/` directory containing `access.log`.
- Populated it with 20 lines in **Nginx Combined Log Format**, including a
  mix of `200 OK`, `500 Internal Server Error`, and several `404 Not Found`
  responses from a few recurring IPs (`198.51.100.23`, `203.0.113.9`).

### Step 2: File Handling & Filtering Logic
- Used `with open(log_path, "r") as file:` to safely open the log — the
  file closes automatically even if an error occurs mid-read.
- Looped over the file object directly (`for line in file:`) instead of
  using `.read()`, so lines are processed **one at a time** rather than
  loading the entire file into memory — critical for real multi-GB logs.
- Checked for the literal substring `" 404 "` (with surrounding spaces) to
  reliably match the status-code field only, avoiding false positives from
  "404" appearing elsewhere in a line.

### Step 3: Data Extraction & Aggregation
- Started with an empty dictionary `ip_counts = {}`.
- Since the IP address is always the first whitespace-separated token in
  Nginx combined log format, used `line.split()[0]` to extract it.
- Used `ip_counts.get(ip_address, 0) + 1` to increment each IP's count,
  initializing it to 0 the first time an IP is seen.
- Printed the dictionary to verify counts before exporting, e.g.
  `{'198.51.100.23': 8, '203.0.113.9': 2}`.

### Step 4: Structuring & Exporting to JSON
- Imported the built-in `json` module.
- Opened `report.json` in write mode (`"w"`) and used `json.dump()` to
  serialize `ip_counts` into it.
- Used `indent=4` so the output file is pretty-printed and human-readable
  rather than a single unreadable line (the L3 challenge requirement).

### Step 5: Refactoring & Error Handling
- Wrapped the core logic in `analyze_logs(log_path, output_path)` so it's
  reusable and testable rather than loose top-level script code.
- Wrapped the file-reading logic in a `try...except FileNotFoundError`
  block — if the log file is missing, the script prints a clean message
  (`"Error: The log file was not found at the specified path."`) instead
  of crashing with a raw traceback.
- Added `if __name__ == "__main__":` at the bottom to call
  `analyze_logs("access.log", "report.json")` only when the script is run
  directly, not when imported as a module.

## Code

```python
"""
Assignment: Python Automation Task - L3
Scenario: Parse an Nginx access log, find all 404 (Not Found) errors,
          count how many times each IP address triggered one, and
          export the intelligence as a pretty-printed report.json
          for the security team.
"""

import json


def analyze_logs(log_path, output_path):
    """
    Read an Nginx access log, count 404 hits per IP address,
    and write the results to a JSON report.

    log_path    -> path to the input access.log file
    output_path -> path where the JSON report should be written
    """

    ip_counts = {}

    try:
        with open(log_path, "r") as file:
            for line in file:
                if " 404 " in line:
                    ip_address = line.split()[0]
                    ip_counts[ip_address] = ip_counts.get(ip_address, 0) + 1

        print("---- 404 hits per IP (raw dictionary) ----")
        print(ip_counts)
        print()

        with open(output_path, "w") as report_file:
            json.dump(ip_counts, report_file, indent=4)

        print(f"Report written to {output_path}")

    except FileNotFoundError:
        print("Error: The log file was not found at the specified path.")


if __name__ == "__main__":
    analyze_logs("access.log", "report.json")
```

## How to Run
```bash
cd python-log-parser
python3 log_analyzer.py
cat report.json
```

To verify the error handling, temporarily rename/delete `access.log` and
run the script again.

## Sample Output
```
---- 404 hits per IP (raw dictionary) ----
{'198.51.100.23': 8, '203.0.113.9': 2}

Report written to report.json
```

**report.json:**
```json
{
    "198.51.100.23": 8,
    "203.0.113.9": 2
}
```

**Error handling test output** (log file missing):
```
Error: The log file was not found at the specified path.
```

## Files
- `access.log` — sample Nginx combined-format log (input data)
- `log_analyzer.py` — main script
- `report.json` — generated JSON report (output)

