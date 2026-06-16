# Package Management — L1 Assignment

---

## Concept Task: apt vs yum

| | apt | yum |
|---|---|---|
| **Full form** | Advanced Package Tool | Yellowdog Updater Modified |
| **OS** | Ubuntu / Debian | CentOS / RHEL / Fedora |
| **Update repo** | `sudo apt update` | `sudo yum update` |
| **Install package** | `sudo apt install <pkg>` | `sudo yum install <pkg>` |
| **Remove package** | `sudo apt remove <pkg>` | `sudo yum remove <pkg>` |

> **Key difference:** `apt` and `yum` are package managers for different Linux distributions. They do the same job — installing, updating, and removing software — but are used on different OS families. Ubuntu uses `apt`; CentOS/RHEL uses `yum`.

---

## Hands-on Task

### Step 1 — Confirm OS (Ubuntu → use apt)
```bash
charan@Ozoo:/$ echo "Am in Ubuntu so i will be using apt"
Am in Ubuntu so i will be using apt
```

### Step 2 — Update the package repository
```bash
charan@Ozoo:/$ sudo apt update

Hit:1 http://archive.ubuntu.com/ubuntu noble InRelease
Get:2 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Hit:3 http://archive.ubuntu.com/ubuntu noble-updates InRelease
Fetched 2073 kB in 1s (1503 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
72 packages can be upgraded.
```
- Fetches the latest package list from Ubuntu's repositories.
- Does **not** install anything — just refreshes what's available.

### Step 3 — Install curl
```bash
charan@Ozoo:/$ sudo apt install curl -y

curl is already the newest version (8.5.0-2ubuntu10.9).
curl set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 72 not upgraded.
```
- `-y` → auto-confirms the installation prompt.
- curl was already present on this system — apt confirmed it's the latest version ✅

### Step 4 — Verify installation
```bash
charan@Ozoo:/$ curl --version

curl 8.5.0 (x86_64-pc-linux-gnu) libcurl/8.5.0 OpenSSL/3.0.13 zlib/1.3
Release-Date: 2023-12-06, security patched: 8.5.0-2ubuntu10.9
Protocols: dict file ftp ftps gopher http https imap smtp telnet tftp ...
Features: alt-svc AsynchDNS brotli HSTS HTTP2 IPv6 SSL zstd ...
```
- curl version **8.5.0** is installed and working ✅

---

## Summary of Commands Used

| Purpose | Command |
|---|---|
| Update package list | `sudo apt update` |
| Install curl | `sudo apt install curl -y` |
| Verify installation | `curl --version` |
