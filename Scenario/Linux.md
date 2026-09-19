# Linux Interview Prep: 2 to 5 Years Experience

Scenario-based questions with answers (47 questions).
Practice folder: `~/linuxCMD` in WSL.

## How to answer in an interview

Use this order for every scenario:

1. **Read the error or symptom** carefully. The exact words tell you where to look.
2. **Find the problem**: run commands step by step (say the commands out loud).
3. **Fix it**: solve the problem safely.
4. **Prevent it**: add monitoring, cleanup, or automation so it does not come back.

Step 4 is what makes an answer sound like 3+ years of experience.

## Sections

1. Server is slow (Q1 to Q5)
2. Disk and storage (Q6 to Q11)
3. Processes and services (Q12 to Q16)
4. Users and permissions (Q17 to Q21)
5. Networking (Q22 to Q27)
6. Logs and text processing (Q28 to Q32)
7. Cron and automation (Q33 to Q35)
8. Security (Q36 to Q38)
9. Boot and system (Q39 to Q43)
10. Concept questions (Q44 to Q47)
11. Practice labs for `~/linuxCMD`

Some tools may not be installed on WSL. Install them once:

```bash
sudo apt update
sudo apt install -y sysstat lsof htop iotop ncdu net-tools dnsutils traceroute mtr-tiny iperf3
```

---

# 1. Server is slow

## Q1. The server is very slow. How do you find the reason, step by step?

**Idea:** A server is slow because one of four things is full: **CPU, memory, disk I/O, or network**. Find which one, then find the process using it.

```bash
uptime                 # load average: 1, 5, 15 minutes
top                    # or htop: CPU, memory, top processes
free -h                # memory and swap
vmstat 1 5             # r (waiting for CPU), b (blocked), si/so (swap), wa (I/O wait)
iostat -xz 1           # disk: %util and await (needs sysstat)
df -h ; df -i          # disk space and inodes
ss -s                  # network connection summary
dmesg -T | tail -30    # kernel messages (OOM, disk errors)
journalctl -p err -n 50   # recent errors
```

Then find the guilty process:

```bash
ps aux --sort=-%cpu | head      # top CPU
ps aux --sort=-%mem | head      # top memory
sudo iotop                      # top disk users
```

**Fix and prevent:** Fix the cause (restart the bad service, fix the code, add resources). Ask: *what changed recently?* (new deploy, new cron job, traffic spike). Add monitoring and alerts.

---

## Q2. CPU is at 100%. How do you find which process is using it, and why?

```bash
top                              # press P to sort by CPU, press 1 to see each core
ps aux --sort=-%cpu | head
top -H -p <PID>                  # which thread inside the process
pidstat 1                        # CPU per process over time
```

Read the CPU line in `top`:

| Value | Meaning |
|---|---|
| `us` | user programs (your app) |
| `sy` | kernel / system calls |
| `wa` | waiting for disk (I/O wait) |
| `st` | stolen by the hypervisor (noisy neighbour in cloud) |

Look deeper into the process:

```bash
strace -p <PID> -c       # which system calls it makes
lsof -p <PID>            # which files and sockets it uses
```

**Common causes:** infinite loop, heavy database query, traffic spike, crypto miner (malware).

**Fix:** restart or fix the app, limit CPU (`nice`, `renice`, systemd `CPUQuota=`), or scale out. If it looks like malware, go to Q36.

---

## Q3. An app got killed and memory was full. How do you check if the OOM killer did it?

**OOM killer** = when memory is full, the kernel kills a process to save the system. It picks the process with the highest `oom_score`.

```bash
dmesg -T | grep -i -E "out of memory|killed process"
journalctl -k | grep -i oom
grep -i oom /var/log/syslog          # Ubuntu (/var/log/messages on RHEL)
```

You will see a line like: `Out of memory: Killed process 1234 (java)`.

Then check:

```bash
free -h
ps aux --sort=-%mem | head
cat /proc/<PID>/oom_score
```

**Fix:** find the memory leak, add RAM, set memory limits (systemd `MemoryMax=`, Docker `--memory`), add swap as a small buffer. Protect a critical process with `oom_score_adj` (a negative value).

---

## Q4. Load average is high, but CPU usage is low. What does that mean?

Load average counts processes that are **running**, **waiting for CPU**, and also **stuck in D state** (waiting for disk or network storage). So high load with low CPU usually means **I/O wait**.

```bash
top                                   # look at the "wa" value
vmstat 1                              # column b (blocked) and wa
iostat -xz 1                          # high await and %util = slow disk
ps aux | awk '$8 ~ /D/'               # processes in D state
sudo iotop                            # who is using the disk
```

**Common causes:** slow or failing disk, NFS mount that is hanging, heavy swapping, a database doing too much disk work.

**Fix:** fix the storage problem, stop the heavy job, move to faster disks.

---

## Q5. Swap usage keeps growing. What do you check and what do you do?

```bash
free -h
swapon --show
vmstat 1          # watch si (swap in) and so (swap out)
grep VmSwap /proc/*/status 2>/dev/null | sort -k2 -n -r | head    # swap per process
```

- Swap **used** but `si/so` are zero: usually not a problem. Old memory pages were moved out and are not being used.
- `si/so` are high all the time: this is **thrashing**. The system does not have enough memory and is slow.

**Fix:** find the process using too much memory, fix the leak, restart it, or add RAM. You can tune `vm.swappiness`. Do not just run `swapoff -a` when memory is already low. That can cause an OOM kill.

---

# 2. Disk and storage

## Q6. You get "No space left on device", but `df -h` shows free space. Why?

**Answer: the inodes are full.**

An inode is a small record for each file (owner, permissions, size, time, where the data is). Every file and folder uses 1 inode. The number of inodes is **fixed** when the filesystem is created. Many tiny files finish the inodes before the data space.

```bash
df -h                 # data space: looks free
df -i                 # inodes: check IUse%, it is 100%
```

Find the folder with too many files:

```bash
find /var -xdev -printf '%h\n' | sort | uniq -c | sort -rn | head
```

Delete safely (with millions of files, `rm -rf folder/*` fails with "Argument list too long"):

```bash
find /path/to/folder -type f -delete
```

**Common causes:** session files, mail queue, cache, temp files, logs that were never cleaned.

**Prevent:** cron job to clean old temp files, and an alert when `df -i` is above 80%.

**Read the error first:** `No space left on device` means space or inodes. `Permission denied` means permissions.

---

## Q7. `/var` is 100% full. How do you find the biggest files and clean up safely?

```bash
df -h
sudo du -xh /var --max-depth=1 | sort -h | tail      # biggest folders
sudo ncdu /var                                       # interactive view
sudo find /var -xdev -type f -size +500M -exec ls -lh {} \;   # big files
```

**Usual suspects:** `/var/log`, `/var/lib/docker`, apt cache, systemd journal.

Clean safely:

```bash
sudo journalctl --vacuum-size=200M     # shrink journal logs
sudo apt clean                         # apt cache
docker system prune                    # unused Docker data (read the warning first)
sudo truncate -s 0 /var/log/big.log    # empty a log that is in use
```

Do **not** `rm` a log file that a running process is writing to. The space will not be freed (see Q8). Empty it with `truncate` instead.

**Prevent:** logrotate (Q30), monitoring, and a separate partition for `/var`.

---

## Q8. You deleted a huge log file, but the space is not freed. Why? How do you fix it?

**Reason:** a process still has the file **open**. Linux only frees the space when the last process closes the file.

```bash
sudo lsof +L1                    # files with 0 links (deleted) but still open
sudo lsof | grep deleted
```

**Fix (choose one):**

1. Restart the process that holds the file. The space is freed.
2. If you cannot restart it, empty the file through `/proc`:

```bash
sudo lsof +L1                                # note the PID and FD number
: > /proc/<PID>/fd/<FD>                      # example: : > /proc/1234/fd/4
```

**Better habit:** to clear a big log that is in use, use `truncate -s 0 file` or `: > file`, not `rm`.

---

## Q9. A new disk is added to the server. How do you partition, format, mount, and make it permanent?

```bash
lsblk                              # find the new disk, for example /dev/sdb
sudo fdisk /dev/sdb                # n (new), accept defaults, w (write)
sudo mkfs.ext4 /dev/sdb1           # format (or mkfs.xfs)
sudo mkdir /data
sudo mount /dev/sdb1 /data         # mount now
sudo blkid /dev/sdb1               # get the UUID
```

Add to `/etc/fstab` so it mounts after reboot:

```
UUID=<your-uuid>  /data  ext4  defaults,nofail  0  2
```

Test **before** reboot:

```bash
sudo mount -a          # if there is an error, fix fstab now
df -h
```

Use the **UUID**, not `/dev/sdb1`, because device names can change. `nofail` stops the server from failing to boot if the disk is missing.

---

## Q10. A wrong `/etc/fstab` entry makes the server fail to boot. How do you recover?

The server goes to **emergency mode** (a root shell, or a message to press Enter).

```bash
# in emergency mode, enter root password, then:
mount -o remount,rw /        # make root writable
vi /etc/fstab                # fix or comment out (#) the bad line
mount -a                     # test, it must give no errors
reboot
```

If you cannot log in (for example, no root password or a cloud server): boot into rescue mode, or (AWS) stop the instance, attach its root volume to another instance, edit `/etc/fstab` there, and attach it back.

**Prevent:** always run `cp /etc/fstab /etc/fstab.bak` before editing, use `nofail`, and always run `mount -a` after editing.

---

## Q11. A partition is full and you use LVM. How do you extend it without downtime?

LVM has 3 layers: **PV** (physical volume, disk) → **VG** (volume group) → **LV** (logical volume, what you mount).

```bash
lsblk ; sudo pvs ; sudo vgs ; sudo lvs        # see current setup
sudo pvcreate /dev/sdc                        # new disk becomes a PV
sudo vgextend vg_data /dev/sdc                # add it to the VG
sudo lvextend -l +100%FREE /dev/vg_data/lv_data      # grow the LV
sudo resize2fs /dev/vg_data/lv_data           # grow the filesystem (ext4)
# for XFS use: sudo xfs_growfs /mountpoint
```

Shortcut: `lvextend -r -l +100%FREE /dev/vg_data/lv_data` grows the LV and the filesystem in one command.

This works **online**, with no unmount and no downtime. Note: XFS can grow but cannot shrink.

---

# 3. Processes and services

## Q12. A service fails to start after reboot. How do you troubleshoot?

```bash
systemctl status myapp              # state and last log lines
journalctl -xeu myapp               # full logs for that service
systemctl is-enabled myapp          # is it enabled at boot?
systemctl --failed                  # all failed services
```

Then check the usual causes:

- **Not enabled:** run `sudo systemctl enable myapp`.
- **Wrong order:** the app starts before network or disk is ready. Add `After=network-online.target` (and `Wants=`) in the unit file.
- **Config error:** test the config, for example `nginx -t`.
- **Port already in use:** `ss -tulnp | grep <port>`.
- **Permission or path error:** wrong user, missing file, missing environment variable.
- **Disk full:** `df -h ; df -i`.

Useful extras: `systemctl list-dependencies myapp` and `systemd-analyze critical-chain`.

---

## Q13. What is a zombie process? What is a process in D state? What do you do about each?

**Zombie (state Z):** the process has finished, but its **parent has not read its exit status**. It uses no CPU and no memory. It only holds a PID entry.

```bash
ps aux | awk '$8=="Z"'              # find zombies
ps -o ppid= -p <PID>                # find the parent
```

You **cannot kill a zombie** (it is already dead). Fix the parent: restart it or fix its code so it calls `wait()`. When the parent dies, `init` cleans the zombies. Many zombies can use up all PIDs.

**D state (uninterruptible sleep):** the process is waiting for I/O (disk, NFS). It **cannot be killed**, not even with `kill -9`.

```bash
ps aux | awk '$8 ~ /D/'
dmesg -T | tail
mount | grep nfs
```

Fix the cause: the failing disk or the hanging NFS server. If nothing works, a reboot is the last option.

---

## Q14. A process does not stop with `kill -15`. What do you do next, and why not use `kill -9` first?

- `kill -15` (SIGTERM) asks the process to stop **nicely**. It can save data, close files, and remove lock files.
- `kill -9` (SIGKILL) **cannot be caught**. The kernel kills it at once. No cleanup, so you can get data loss, leftover lock files, and orphan child processes.

Order to follow:

```bash
kill -15 <PID>          # ask nicely, wait 10-30 seconds
kill -2 <PID>           # SIGINT (like Ctrl+C), optional
kill -9 <PID>           # last option
```

Also check:

- Is it in **D state**? Then no signal will work (see Q13).
- Does it have child processes? `pstree -p <PID>`. Kill the whole group with `kill -9 -<PGID>`.
- Use `pkill -f name` to kill by name.

---

## Q15. A script must keep running after you log out. How do you do it?

When you log out, the shell sends **SIGHUP** to its child processes and they stop. Options:

```bash
nohup ./script.sh > out.log 2>&1 &     # ignores SIGHUP
```

```bash
tmux new -s work        # run inside tmux, detach with Ctrl+b then d
tmux attach -t work     # come back later
```

```bash
./script.sh &
disown                  # remove the job from the shell
```

**Best for production:** create a **systemd service** (Q16). It also restarts on failure and starts at boot.

---

## Q16. Create a custom systemd service for an app that restarts on failure.

File: `/etc/systemd/system/myapp.service`

```ini
[Unit]
Description=My App
After=network-online.target
Wants=network-online.target

[Service]
User=appuser
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/node /opt/myapp/server.js
Restart=on-failure
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
```

Commands:

```bash
sudo systemctl daemon-reload            # read the new file
sudo systemctl enable --now myapp       # start now and at boot
systemctl status myapp
journalctl -u myapp -f                  # follow logs
```

Notes: `Restart=on-failure` restarts only when the app crashes. `Restart=always` restarts even after a clean exit. Run the app as a normal user, not root.

---
# 4. Users and permissions

## Q17. A new developer joins. Give access to only one folder, and let them restart only nginx with sudo.

**Step 1: create the user and SSH key access**

```bash
sudo useradd -m -s /bin/bash dev1
sudo mkdir -p /home/dev1/.ssh
echo "<public-key>" | sudo tee /home/dev1/.ssh/authorized_keys
sudo chmod 700 /home/dev1/.ssh
sudo chmod 600 /home/dev1/.ssh/authorized_keys
sudo chown -R dev1:dev1 /home/dev1/.ssh
```

**Step 2: access to one folder only**

```bash
sudo groupadd devteam
sudo usermod -aG devteam dev1
sudo chgrp -R devteam /var/www/app
sudo chmod -R 2770 /var/www/app          # group can read and write, others get nothing
```

Or with ACL, for one user only:

```bash
sudo setfacl -R -m u:dev1:rwx /var/www/app
```

**Step 3: sudo for one command only**

```bash
which systemctl                              # note the full path
sudo visudo -f /etc/sudoers.d/dev1
```

Add this line:

```
dev1 ALL=(root) NOPASSWD: /usr/bin/systemctl restart nginx
```

Check: `sudo -l -U dev1`.

**Principle:** *least privilege*. Give only what is needed. Always use `visudo`, because it checks the syntax and a broken sudoers file can lock everyone out.

---

## Q18. You did `chmod 777` but still get "Permission denied". What else can cause it?

Check these in order:

```bash
namei -l /path/to/file        # shows permissions of every folder in the path
```

1. **A parent folder has no `x` (execute) permission.** You need `x` on every folder in the path to enter it. `namei -l` shows this.
2. **SELinux** (RHEL, CentOS): `getenforce`, `ls -Z file`, `sudo ausearch -m avc -ts recent`. AppArmor on Ubuntu: `sudo aa-status`.
3. **Immutable attribute:** `lsattr file`. If you see `i`, run `sudo chattr -i file`.
4. **ACL:** `getfacl file`.
5. **Mount options:** the filesystem may be read-only (`ro`) or `noexec`. Check with `findmnt` or `mount | grep <path>`.
6. **Wrong owner or user:** check `ls -l` and `id`.
7. **Network storage (NFS):** root squash can block even root.
8. For scripts: missing `#!` (shebang) line, or the file is on a `noexec` mount.

Also, `chmod 777` is bad practice. Never use it in production.

---

## Q19. Make a shared team folder where new files always get the team's group.

```bash
sudo groupadd team
sudo mkdir /shared
sudo chgrp team /shared
sudo chmod 2775 /shared             # 2 = setgid
sudo usermod -aG team user1
sudo usermod -aG team user2
```

Ideas to explain:

- **setgid on a folder (`2xxx`)**: new files and folders take the **folder's group**, not the creator's main group.
- **umask 002**: new files are created with group write permission (default 022 does not give group write). Set it in the user's `~/.bashrc` or `/etc/profile`.
- **sticky bit (`+t`, or `1xxx`)**: users can delete only their **own** files in the folder (like `/tmp`). Use `chmod 3775 /shared` for setgid + sticky.
- **Default ACL** (another way): `sudo setfacl -d -m g:team:rwx /shared`.

Users must log out and log in again to get the new group.

---

## Q20. An employee leaves. What do you check and remove?

```bash
sudo usermod -L username                 # lock the password
sudo usermod -s /usr/sbin/nologin username    # no shell
sudo chage -E 0 username                 # expire the account now
sudo pkill -u username                   # end active sessions
```

Then check everything they could use:

- **SSH keys:** `~/.ssh/authorized_keys` (also in shared or service accounts).
- **Cron jobs:** `sudo crontab -l -u username`, `/etc/cron.d/`, `at` jobs, systemd timers.
- **Sudo access:** `/etc/sudoers` and `/etc/sudoers.d/`.
- **Files they own:** `sudo find / -user username -ls 2>/dev/null`, then `chown` them to someone else.
- **Shared secrets:** rotate passwords, API keys, tokens, DB users, and VPN or cloud (IAM) access.

Back up the home folder first. Delete the user later with `userdel -r username`.

---

## Q21. SSH key login is not working. How do you troubleshoot?

**Client side:**

```bash
ssh -vvv user@host                 # shows exactly where it fails
chmod 600 mykey.pem                # private key must not be open to others
ssh -i mykey.pem user@host         # correct key and correct username (ubuntu, ec2-user)
```

**Server side:**

```bash
ls -ld ~ ~/.ssh ~/.ssh/authorized_keys
# home dir: not writable by group/others; ~/.ssh = 700; authorized_keys = 600; owned by the user
sudo grep -E "PubkeyAuthentication|AuthorizedKeysFile|AllowUsers|PermitRootLogin" /etc/ssh/sshd_config
sudo sshd -t                                # test the config
sudo tail -f /var/log/auth.log              # Ubuntu (/var/log/secure on RHEL)
sudo journalctl -u ssh -f
```

Other causes: SELinux (`restorecon -Rv ~/.ssh`), port 22 blocked by firewall or cloud security group, wrong public key in `authorized_keys`, user not allowed by `AllowUsers`.

Most common cause: **wrong permissions** on `~/.ssh` or the key file. SSH refuses keys that are too open.

---

# 5. Networking

## Q22. The server cannot reach a website. How do you find where the problem is?

Go step by step, from local to far:

```bash
ip a                          # 1. do I have an IP address?
ip route                      # 2. is there a default gateway?
ping -c 3 <gateway-ip>        # 3. can I reach the gateway?
ping -c 3 8.8.8.8             # 4. can I reach the internet by IP?
ping -c 3 google.com          # 5. does DNS work? (if this fails, see Q25)
curl -v https://example.com   # 6. shows where it fails: DNS, connect, TLS, or HTTP
traceroute example.com        # 7. where does the path stop? (or: mtr example.com)
```

Then check blockers:

- Local firewall: `sudo iptables -L -n`, `sudo ufw status`, `sudo nft list ruleset`.
- Cloud: security group, network ACL, route table, NAT gateway.
- Proxy variables: `env | grep -i proxy`.
- Wrong date on the server (causes certificate errors): `date`.

**Reading the result:** ping to IP works but name fails = DNS problem. Nothing works = network, gateway, or firewall problem. `curl` connects but shows a certificate error = TLS or date problem.

---

## Q23. Your app runs on port 8080, but it cannot be opened from outside. What do you check?

```bash
ss -tulnp | grep 8080          # 1. what address is it listening on?
```

- `127.0.0.1:8080` means only **local** connections. Change the app to listen on `0.0.0.0` (all interfaces).
- `0.0.0.0:8080` or `*:8080` is fine. Go to the next step.

```bash
curl localhost:8080                          # 2. works on the server itself?
sudo ufw status                              # 3. local firewall
sudo iptables -L -n
sudo firewall-cmd --list-all                 # RHEL
nc -zv <server-ip> 8080                      # 4. test from another machine
```

Then check the **cloud security group / NACL** for port 8080, and the reverse proxy if there is one. For Docker, check that the port is published: `docker ps` should show `0.0.0.0:8080->8080/tcp`.

---

## Q24. How do you find which process is using port 80?

```bash
sudo ss -tulnp | grep :80
sudo lsof -i :80
sudo fuser 80/tcp
```

Use `sudo`, otherwise you cannot see the process name. The old command is `netstat -tulnp`. Flags for `ss`: `t` TCP, `u` UDP, `l` listening, `n` show numbers, `p` show process.

---

## Q25. DNS is not resolving names. How do you debug?

**First confirm it is DNS:** `ping 8.8.8.8` works, but `ping google.com` fails.

```bash
cat /etc/resolv.conf                 # which DNS server is used
resolvectl status                    # if systemd-resolved is used
dig google.com                       # does it answer?
dig @8.8.8.8 google.com              # test with a different DNS server
nslookup google.com
cat /etc/hosts                       # wrong or old entries here override DNS
grep hosts /etc/nsswitch.conf        # order: files first, then dns
```

Other causes: firewall blocking port 53, wrong DNS in the cloud network (VPC) settings, DNS server is down.

**Fix:** correct the nameserver, then restart the resolver: `sudo systemctl restart systemd-resolved`.

Note: on many systems `/etc/resolv.conf` is managed by systemd-resolved or NetworkManager. If you edit it by hand, your change can be overwritten. Change the real setting.

---

## Q26. You see many connections in `TIME_WAIT` or `CLOSE_WAIT`. What does it mean?

```bash
ss -tan | awk 'NR>1 {print $1}' | sort | uniq -c
```

- **TIME_WAIT:** normal. The connection closed properly, and the socket waits about 60 seconds to catch late packets. Many of them mean many short connections. It is a problem only if you run out of ports. Fix with keep-alive, connection pooling, or a wider `net.ipv4.ip_local_port_range`.
- **CLOSE_WAIT:** the **other side closed** the connection, but **your application has not closed its socket**. This is usually a **bug** in the app (connection leak). Fix the code. A restart is only a temporary fix.

Rule to remember: **CLOSE_WAIT is the more serious one.**

---

## Q27. Connection between two servers is slow. How do you test and find the cause?

```bash
ping -c 20 <server2>                 # latency and packet loss
mtr <server2>                        # loss and delay on every hop
iperf3 -s                            # on server 2 (start the listener)
iperf3 -c <server2-ip>               # on server 1 (test bandwidth)
ss -ti                               # look at retransmits
ip -s link                           # errors and drops on the interface
sudo ethtool eth0                    # link speed and duplex
ping -M do -s 1472 <server2>         # MTU test (fails if packet is too big)
```

Also check: CPU load on both servers, cloud limits (instance network size, different regions or zones), DNS delay, and firewall rules.

---

# 6. Logs and text processing

## Q28. Find the top 10 IP addresses hitting nginx from the access log.

```bash
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10
```

How it works:

1. `awk '{print $1}'` takes the first column (the IP).
2. `sort` puts equal IPs next to each other.
3. `uniq -c` counts them. It only counts **neighbouring** lines, so `sort` must come first.
4. `sort -rn` sorts by count, highest first.
5. `head -10` shows the top 10.

---

## Q29. Find all HTTP 500 errors from the last 1 hour.

In the default nginx log format the status code is column 9, and the time looks like `[19/Sep/2026:10:15:32 +0530]`.

```bash
grep -E "$(date -d '1 hour ago' '+%d/%b/%Y:%H')|$(date '+%d/%b/%Y:%H')" /var/log/nginx/access.log \
  | awk '$9 ~ /^5[0-9][0-9]$/'
```

This matches the previous hour and the current hour, then keeps only 5xx codes.

Useful extras:

```bash
awk '{print $9}' access.log | sort | uniq -c | sort -rn      # count of each status code
journalctl -u myapp --since "1 hour ago" | grep -i error      # for systemd logs
```

---

## Q30. Logs are growing very fast. How do you set up log rotation?

File: `/etc/logrotate.d/myapp`

```
/var/log/myapp/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
```

| Option | Meaning |
|---|---|
| `daily` | rotate every day (or use `size 100M`) |
| `rotate 7` | keep 7 old files |
| `compress` | gzip old files |
| `missingok` / `notifempty` | no error if missing, skip if empty |
| `copytruncate` | copy then empty the file; use when the app cannot reopen its log file |

Test:

```bash
sudo logrotate -d /etc/logrotate.d/myapp      # dry run, shows what would happen
sudo logrotate -f /etc/logrotate.d/myapp      # force a rotation now
```

logrotate runs once a day from cron or a systemd timer. Without `copytruncate`, use a `postrotate` script to tell the app to reopen its log (for example `systemctl reload nginx`). Also limit the systemd journal with `SystemMaxUse=` in `/etc/systemd/journald.conf`.

---

## Q31. Find all files bigger than 500 MB, modified in the last 7 days.

```bash
sudo find / -xdev -type f -size +500M -mtime -7 -ls 2>/dev/null
```

| Part | Meaning |
|---|---|
| `-xdev` | stay on one filesystem (skip `/proc`, other disks) |
| `-size +500M` | bigger than 500 MB |
| `-mtime -7` | modified in the last 7 days (`+7` means older than 7 days) |
| `-ls` | show details |

To delete: **look at the list first** with `-ls`. Only then replace `-ls` with `-delete`. Never run `-delete` without checking, and limit the path (for example `/var/log` or `/tmp`).

---

## Q32. How do you follow a log live and filter only errors?

```bash
tail -f app.log | grep --line-buffered -i error
tail -F app.log                          # -F keeps following after log rotation
journalctl -u myapp -f -p err            # for systemd services
grep -i -C 3 "error" app.log             # show 3 lines before and after each match
less +F app.log                          # follow inside less (Ctrl+C to stop, F to follow again)
```

`--line-buffered` makes `grep` print each line at once, not in big blocks. Use `grep -E "error|fail|timeout"` for many words.

---

# 7. Cron and automation

## Q33. A cron job is not running. What do you check?

Checklist:

```bash
crontab -l                                # is the job there? are the 5 time fields right?
systemctl status cron                     # is the cron service running? (crond on RHEL)
grep CRON /var/log/syslog                 # Ubuntu (RHEL: /var/log/cron)
journalctl -u cron
```

Common causes:

1. **Cron has a very small `PATH`.** Use full paths for commands (`/usr/bin/python3`) and files.
2. **Script is not executable** (`chmod +x`) or has no shebang line (`#!/bin/bash`).
3. **Missing environment variables.** Cron does not load your `.bashrc`.
4. **The `%` sign** must be escaped as `\%` in crontab lines (for example in `date +\%F`).
5. **Wrong user or permissions.** Check `/etc/cron.allow` and `/etc/cron.deny`.
6. **Timezone** of the server is different from what you expect.
7. **The last line** of a crontab file must end with a newline.

**Best debugging trick:** save the output.

```
* * * * * /opt/scripts/job.sh >> /tmp/job.log 2>&1
```

Also run the script by hand as the same user. If it fails there, the problem is the script, not cron.

---

## Q34. Write a script that takes a backup and deletes backups older than 7 days.

```bash
#!/bin/bash
set -euo pipefail

SRC="/var/www/app"
DEST="/backup"
KEEP_DAYS=7
DATE=$(date +%F_%H-%M)
FILE="$DEST/app_backup_$DATE.tar.gz"
LOG="/var/log/backup.log"

mkdir -p "$DEST"

tar -czf "$FILE" "$SRC"
echo "$(date) Backup created: $FILE" >> "$LOG"

find "$DEST" -name "app_backup_*.tar.gz" -type f -mtime +"$KEEP_DAYS" -delete
echo "$(date) Old backups removed" >> "$LOG"
```

Run it every day at 2 AM with cron:

```
0 2 * * * /opt/scripts/backup.sh
```

Explain to the interviewer:

- `set -euo pipefail`: stop on errors, on unset variables, and on errors inside pipes.
- `-mtime +7` means older than 7 days.
- In real projects also copy the backup off the server (for example `aws s3 cp`) and **test a restore** from time to time.

---

## Q35. Write a script that alerts when disk usage is above 80%.

```bash
#!/bin/bash
THRESHOLD=80
WEBHOOK_URL="https://hooks.slack.com/services/XXXX"    # your Slack webhook

df -hP -x tmpfs -x devtmpfs | awk 'NR>1 {print $5, $6}' | while read -r usage mount; do
  percent=${usage%\%}
  if [ "$percent" -ge "$THRESHOLD" ]; then
    MSG="ALERT: $mount is ${percent}% full on $(hostname)"
    echo "$MSG"
    curl -s -X POST -H 'Content-type: application/json' \
      --data "{\"text\":\"$MSG\"}" "$WEBHOOK_URL" > /dev/null
  fi
done
```

Explain:

- `df -hP` gives one line per filesystem (`-P` stops long lines from breaking).
- `-x tmpfs -x devtmpfs` skips fake filesystems.
- `${usage%\%}` removes the `%` sign so we can compare numbers.
- Run it every 5 minutes with cron: `*/5 * * * * /opt/scripts/disk_alert.sh`.
- Add the same check for inodes (`df -i`).
- In real companies, use a monitoring tool (Prometheus, CloudWatch, Zabbix). A script is a quick solution.

---
# 8. Security

## Q36. You think the server is hacked. What do you check first?

**First:** stay calm, do not delete anything, and **do not reboot** (you lose evidence in memory). If possible, isolate the server from the network (security group) and tell your team or security team.

```bash
last -a | head -20                       # who logged in, from where
sudo lastb | head                        # failed logins
w ; who                                  # who is logged in now
sudo grep -i "accepted" /var/log/auth.log | tail -30
ps auxf                                  # odd processes (crypto miners use high CPU)
ss -tulnp                                # unknown listening ports
ss -tnp                                  # unknown outgoing connections
sudo crontab -l -u <user> ; ls /etc/cron* ; systemctl list-timers    # hidden jobs
awk -F: '$3==0' /etc/passwd              # users with UID 0 (should be only root)
cat /etc/passwd | tail                   # new users
sudo find / -name authorized_keys 2>/dev/null     # unknown SSH keys
sudo find / -mtime -2 -type f -ls 2>/dev/null | head -50    # recently changed files
ls -la /tmp /dev/shm                     # malware often hides here
sudo debsums -c                          # changed system files (Ubuntu); on RHEL: rpm -Va
```

**Then:** change all passwords and keys, patch the hole that was used, and check other servers. The safest fix is to **rebuild the server from a clean image** and restore data from a clean backup. Cleaning a hacked server by hand is risky because you can miss something.

---

## Q37. There are many failed SSH login attempts. How do you secure the server?

See who is attacking:

```bash
sudo grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head
```

Secure the server:

1. **Key-only login:** in `/etc/ssh/sshd_config` set `PasswordAuthentication no`.
2. **No root login:** `PermitRootLogin no`.
3. **Allow only some users:** `AllowUsers dev1 admin`.
4. **fail2ban:** bans an IP after many failed attempts (`sudo apt install fail2ban`).
5. **Firewall or security group:** allow port 22 only from your office IP or a VPN.
6. **MFA** and regular updates.
7. Changing the SSH port only reduces noise. It is not real security.

Apply safely:

```bash
sudo sshd -t                      # test the config first
sudo systemctl reload sshd        # (service name is "ssh" on Ubuntu)
```

Keep **one SSH session open** while you test in a second one, so you do not lock yourself out.

---

## Q38. How do you find files with the SUID bit, and why is it risky?

```bash
sudo find / -perm -4000 -type f 2>/dev/null       # SUID files
sudo find / -perm -2000 -type f 2>/dev/null       # SGID files
```

**SUID** means the program runs with the **owner's** permissions (often root), not the user's. Example: `/usr/bin/passwd` needs to write to `/etc/shadow`, so it has SUID root.

**Risk:** if a SUID program has a bug, or a tool like `find`, `vim`, or `bash` has SUID by mistake, a normal user can become **root**.

**What to do:** compare the list with the normal list for your OS, and remove SUID from anything not needed: `sudo chmod u-s /path/to/file`. Mount folders like `/tmp` with `nosuid`.

---

# 9. Boot and system

## Q39. You forgot the root password on a server. How do you recover?

**RHEL / CentOS (physical server or VM):**

1. Reboot. At the GRUB menu press `e`.
2. On the line that starts with `linux`, add `rd.break` at the end. Press `Ctrl+X`.
3. Then run:

```bash
mount -o remount,rw /sysroot
chroot /sysroot
passwd root
touch /.autorelabel          # needed when SELinux is on
exit
exit                         # the system reboots
```

**Ubuntu:** GRUB menu → Advanced options → recovery mode → root shell:

```bash
mount -o remount,rw /
passwd root
```

**Cloud servers (AWS):** you normally do not use a root password. If you lost your key: use **SSM Session Manager** or **EC2 Instance Connect**, or stop the instance, attach its root volume to another instance, add your new public key to `authorized_keys`, and attach it back.

**Why this matters:** anyone with physical or console access can reset the password. Protect the GRUB with a password and control console access.

---

## Q40. Explain the Linux boot process, from power on to login.

1. **BIOS / UEFI:** checks the hardware (POST) and finds the boot device.
2. **Bootloader (GRUB2):** shows the menu and loads the **kernel** and **initramfs** into memory.
3. **Kernel:** starts the hardware drivers. It uses **initramfs** (a small temporary root with needed drivers) to find and mount the real root filesystem.
4. **systemd (PID 1):** the first process. It reads unit files and moves to a **target** (`multi-user.target` or `graphical.target`).
5. **Services start** (in parallel), filesystems from `/etc/fstab` are mounted, and the network comes up.
6. **Login:** the login prompt (getty) or SSH is ready.

Useful commands when debugging boot:

```bash
systemd-analyze                  # total boot time
systemd-analyze blame            # which service took the longest
journalctl -b                    # logs of this boot
journalctl -b -1                 # logs of the previous boot
dmesg -T                         # kernel messages
```

---

## Q41. You must patch the kernel on a production server. How do you plan it?

1. **Understand the patch:** is it a security fix (CVE)? How serious? `uname -r` shows the current kernel.
2. **Test in staging first.**
3. **Take a backup or snapshot** (for example an AMI or LVM snapshot).
4. **Plan a maintenance window** and tell the team.
5. **Rolling update** if you have many servers behind a load balancer. Do one server at a time:
   - remove it from the load balancer and drain connections
   - patch (`sudo apt upgrade` or `sudo yum update kernel`) and reboot
   - check: `uname -r`, `systemctl --failed`, app health check
   - add it back, then do the next server
6. **Rollback plan:** the old kernel stays in GRUB, so you can boot it if the new one fails.
7. **No reboot option:** kernel live patching (Canonical Livepatch, kpatch) for urgent security fixes.

---

## Q42. `apt install` fails with a lock or "broken dependency" error. What do you do?

**Lock error:** `Could not get lock /var/lib/dpkg/lock-frontend`. Another apt process is running (often `unattended-upgrades`).

```bash
ps aux | grep -E "apt|dpkg"
sudo lsof /var/lib/dpkg/lock-frontend
```

Wait for it to finish. Only if it is really stuck, stop that process. Removing lock files is the **last** option. After that:

```bash
sudo dpkg --configure -a
```

**Broken dependency:**

```bash
sudo apt update
sudo apt --fix-broken install         # same as: apt-get install -f
apt-cache policy <package>            # which version is available
apt-mark showhold                     # held packages
```

Also check `/etc/apt/sources.list*` (wrong repository), disk space (`df -h`), and DNS or network. **RHEL:** `yum clean all`, `yum check`, `dnf distro-sync`.

---

## Q43. A symlink stopped working after you moved a file. Why? How is it different from a hard link?

| | Symlink (soft link) | Hard link |
|---|---|---|
| What it is | A small file that stores the **path** to another file | Another **name** for the same inode |
| Create | `ln -s target link` | `ln file link` |
| If the original is moved or deleted | Link **breaks** (dangling) | Still works, data stays until all links are removed |
| Across filesystems | Yes | No |
| For folders | Yes | No |

**Why it broke:** the symlink stores a path. A **relative** path is read from the link's own folder, so moving the link or the target breaks it.

```bash
ls -li                    # shows inode numbers (hard links share the same number)
readlink -f link          # shows the real target
find . -xtype l           # find broken symlinks
ln -sfn /new/absolute/path link      # fix: recreate with an absolute path
```

---

# 10. Concept questions

## Q44. What happens when you type a command and press Enter?

1. The **shell** (bash) reads the line and expands it: variables, wildcards (`*`), aliases, quotes.
2. It decides the type: alias, function, **builtin** (like `cd`), or an **external program**.
3. For an external program it searches the folders in `$PATH` from left to right (`type ls` shows what will run).
4. The shell calls **`fork()`**. This makes a child process, a copy of the shell.
5. The child calls **`exec()`**. It replaces itself with the new program (the kernel checks permissions and loads the file).
6. The parent shell **waits** for the child to finish (unless you used `&`).
7. The program runs with stdin (0), stdout (1), stderr (2). The shell sets up pipes and redirections before `exec`.
8. The program exits with an **exit code** (`echo $?`), and the shell shows the next prompt.

Useful exit codes: `0` success, `126` found but permission denied, `127` command not found.

---

## Q45. What is an inode? What happens to it when you delete a file?

An **inode** stores the file's **metadata**: owner, group, permissions, size, timestamps, link count, and pointers to the data blocks. It does **not** store the file name.

A **directory** is a table that maps names to inode numbers.

When you delete a file (`rm`):

1. The name (directory entry) is removed and the **link count** goes down by 1.
2. When the link count is 0 **and** no process has the file open, the inode and data blocks are freed.
3. If a process still has it open, the space stays used (see Q8).

```bash
ls -i file        # inode number
stat file         # full inode details
df -i             # inode usage
```

The number of inodes is fixed at format time for ext4 (`mkfs.ext4 -N`). XFS creates inodes on demand, so it runs out much less often.

---

## Q46. What does load average mean (1, 5, 15 minutes)?

The load average is the average number of processes that are **running or waiting** (for CPU, or in D state for I/O) over the last 1, 5, and 15 minutes.

```bash
uptime
cat /proc/loadavg
nproc                # number of CPU cores
```

Compare it with the number of cores:

- 4 cores, load **4** = fully busy.
- 4 cores, load **8** = overloaded. Processes are waiting.
- 4 cores, load **1** = mostly idle.

Read the trend:

- 1 min **higher** than 15 min: load is going **up**.
- 1 min **lower** than 15 min: load is coming **down**.

High load with low CPU usage means processes are waiting for I/O (see Q4).

---

## Q47. What is the difference between a process and a thread?

| | Process | Thread |
|---|---|---|
| Memory | Has its **own** memory space | **Shares** memory with other threads in the same process |
| Isolation | Strong. One process crashing does not kill others | Weak. A bug in one thread can crash the whole process |
| Create cost | Higher | Lower |
| Talk to each other | Needs IPC (pipes, sockets, shared memory) | Easy, through shared memory |

Examples: nginx uses several **worker processes**. Java apps use many **threads**. Node.js runs your code on one main thread with an event loop.

```bash
ps -eLf              # shows threads (LWP column)
top -H               # threads view
```

In Linux both are created with the `clone()` system call. A thread is a task that shares memory with its parent.

---

# 11. Practice labs for `~/linuxCMD`

Do these to make the answers stick. Start with `cd ~/linuxCMD`.

## Lab 1: Inodes full (Q6, Q45)

```bash
mkdir inode-lab && cd inode-lab
dd if=/dev/zero of=disk.img bs=1M count=50
mkfs.ext4 -F -N 100 disk.img
mkdir mnt
sudo mount -o loop disk.img mnt
sudo chown $USER:$USER mnt

for i in $(seq 1 200); do touch mnt/file$i || break; done    # fails near file 89
df -h mnt        # plenty of space
df -i mnt        # IUse% = 100%

find mnt -type f -name 'file*' -delete                       # fix
touch mnt/newfile && echo "works"
sudo umount mnt
cd ..
```

## Lab 2: Deleted file but space not freed (Q8)

```bash
dd if=/dev/zero of=bigfile bs=1M count=500
tail -f bigfile > /dev/null &        # a process holds the file open
rm bigfile
lsof +L1                             # shows the deleted file still open
df -h .                              # space is not freed
kill %1                              # stop tail
df -h .                              # space is freed
```

## Lab 3: CPU hog (Q2)

```bash
yes > /dev/null &
top                    # find "yes" at the top (press q to quit)
ps aux --sort=-%cpu | head -3
pkill yes
```

## Lab 4: Zombie process (Q13)

```bash
cat > zombie.py << 'EOF'
import os, time
pid = os.fork()
if pid == 0:
    os._exit(0)        # child exits at once
else:
    time.sleep(60)     # parent sleeps and never calls wait()
EOF

python3 zombie.py &
ps -eo pid,ppid,stat,cmd | grep " Z"      # the child shows as <defunct>
```

## Lab 5: Shared folder with setgid (Q19)

```bash
sudo groupadd team
sudo mkdir /tmp/shared
sudo chgrp team /tmp/shared
sudo chmod 2775 /tmp/shared
ls -ld /tmp/shared                        # look for the "s" in drwxrwsr-x
sudo touch /tmp/shared/test.txt
ls -l /tmp/shared/test.txt                # the group is "team"
```

## Lab 6: Top IPs and 5xx errors from a fake log (Q28, Q29)

```bash
for i in $(seq 1 200); do
  echo "192.168.1.$((RANDOM%5+1)) - - [19/Sep/2026:10:00:00 +0530] \"GET / HTTP/1.1\" $((RANDOM%2==0?200:500)) 123" >> access.log
done

awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10
awk '$9 ~ /^5[0-9][0-9]$/' access.log | wc -l
awk '{print $9}' access.log | sort | uniq -c
```

## Lab 7: Cron job and its log (Q33)

```bash
sudo service cron start                    # on WSL, cron may not be running
crontab -e                                 # add the next line
# * * * * * echo "hi $(date)" >> ~/linuxCMD/cron.log 2>&1
tail -f ~/linuxCMD/cron.log                # wait one minute
```

## Lab 8: Custom systemd service (Q16)

WSL needs systemd enabled. Check with `systemctl is-system-running`. If it works, create a small service that runs `sleep 1000`, then test `systemctl status`, `kill` its process, and see it restart with `Restart=on-failure`.

---

**Final tip for the interview:** if you do not know an answer, do not guess. Say what you know, then say how you would find out (which command, which log, which document). Interviewers like a clear method more than a memorized answer.
