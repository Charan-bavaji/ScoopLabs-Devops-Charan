# Loops and Conditions - L1

## Description
Controlling the flow of a script using loops and conditional statements.

## Concept Task
**Difference between a `for` loop and a `while` loop:**
- A **for loop** runs a fixed number of times — it iterates through each item
  in a sequence (like a list, string, or range) one by one, and stops
  automatically when the sequence ends.
- A **while loop** keeps running as long as a given condition stays `True`.
  The number of iterations isn't known in advance, and the exit condition
  must be controlled carefully to avoid an infinite loop.

## Hands-on Task
A Python script (`server_status_check.py`) that:
- Iterates through a list of server statuses: `["UP", "DOWN", "UP"]`
- Prints a warning message for any server whose status is `"DOWN"`
- Prints a normal status message for servers that are `"UP"`

## How to Run
```bash
python3 server_status_check.py
```

## Sample Output
```
Server 1 is UP. All good.
WARNING: Server 2 is DOWN!
Server 3 is UP. All good.
```

## Files
- `server_status_check.py` — main script
- `execution_output.png` — execution output screenshot (add before pushing)
