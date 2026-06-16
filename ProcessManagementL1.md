# Process Management — L1 Assignment

---

## Concept Task

### What is a PID?
- PID stands for **Process ID** — a unique number the Linux kernel assigns to every running process.
- Every process gets a PID when it starts and it is released when the process ends.
- Used to identify, monitor, and control specific processes.

### SIGTERM vs SIGKILL

| | SIGTERM (signal 15) | SIGKILL (signal 9) |
|---|---|---|
| **Command** | `kill <PID>` | `kill -9 <PID>` |
| **What it does** | Sends a polite termination request | Forces the OS to kill the process immediately |
| **Process can ignore it?** | Yes — process can catch and handle it | No — process cannot ignore it |
| **Graceful shutdown?** | Yes — process gets time to clean up | No — killed instantly, no cleanup |
| **When to use** | Default, always try this first | When process is frozen or not responding |

---

## Hands-on Task

### Step 1 — Switch to root and start a background process
```bash
charan@Ozoo:/$ sudo -i

root@Ozoo:~# sleep 1000 &
[1] 2971
```
- `sleep 1000 &` runs the process in the background.
- `[1] 2971` → job number is 1, PID is **2971**.

---

### Step 2 — Find the process using ps
```bash
root@Ozoo:~# ps aux | grep sleep
root  2971  0.0  0.0  3124  1852 pts/4  S  08:43  0:00 sleep 1000
root  2973  0.0  0.0  4088  2048 pts/4  S+ 08:44  0:00 grep --color=auto sleep
```
- First line → our `sleep 1000` process with PID **2971**.
- Second line → the `grep` command itself (can be ignored).

---

### Step 3 — Terminate with SIGTERM (graceful)
```bash
root@Ozoo:~# kill 2971

root@Ozoo:~# ps aux | grep sleep
root  2975  0.0  0.0  4088  2052 pts/4  S+ 08:45  0:00 grep --color=auto sleep
[1]+  Terminated              sleep 1000
```
- `sleep 1000` is gone from the process list ✅
- Terminal confirms: `Terminated sleep 1000`

---

### Step 4 — Start another process and force kill with SIGKILL
```bash
root@Ozoo:~# sleep 2000 &
[1] 2976

root@Ozoo:~# ps aux | grep sleep
root  2976  0.0  0.0  3124  1852 pts/4  S  08:45  0:00 sleep 2000
root  2978  0.0  0.0  4088  2044 pts/4  S+ 08:46  0:00 grep --color=auto sleep

root@Ozoo:~# kill -9 2976

root@Ozoo:~# ps aux | grep sleep
root  2984  0.0  0.0  4088  2044 pts/4  S+ 08:46  0:00 grep --color=auto sleep
[1]+  Killed                  sleep 2000
```
- `sleep 2000` is gone from the process list ✅
- Terminal confirms: `Killed sleep 2000`

---

## Summary of Commands Used

| Purpose | Command |
|---|---|
| Start background process | `sleep 1000 &` |
| Find process by name | `ps aux \| grep sleep` |
| Graceful kill (SIGTERM) | `kill 2971` |
| Force kill (SIGKILL) | `kill -9 2976` |
| Verify process is gone | `ps aux \| grep sleep` |

<img width="958" height="1017" alt="image" src="https://github.com/user-attachments/assets/e2b058f9-ccc9-4e74-a3ca-78c3d28551c3" />
