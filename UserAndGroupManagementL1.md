# User and Group Management — L1 Assignment

---

## Concept Task: /etc/passwd and /etc/group Files

### /etc/passwd
- Stores information about every user account on the system.
- Each line represents one user in this format:
  ```
  username:password:UID:GID:comment:home_directory:shell
  ```
- Example:
  ```
  devuser:x:1001:1001::/home/devuser:/bin/bash
  ```
- The `x` in the password field means the actual password is stored securely in `/etc/shadow`.
- Used by the OS to identify who is logging in and what shell/home they get.

### /etc/group
- Stores information about every group on the system.
- Each line represents one group in this format:
  ```
  groupname:password:GID:members
  ```
- Example:
  ```
  devteam:x:1004:devuser
  ```
- Used by the OS to manage permissions — files and directories can be assigned to a group, and all members of that group inherit access.

---

## Hands-on Task: Commands Used

### Step 1 — Create a new group
```bash
groupadd devteam
```

### Step 2 — Create a new user with home directory and bash shell
```bash
useradd -m -s /bin/bash devuser
```
- `-m` → creates home directory at `/home/devuser`
- `-s /bin/bash` → sets default shell to bash

### Step 3 — Add user to the devteam group
```bash
usermod -aG devteam devuser
```
- `-a` → append (don't remove from existing groups)
- `-G` → specify the group to add

---

## Verification Output

```bash
root@Ozoo:/home# ls -l
total 8
drwxr-x--- 8 charan  charan  4096 Jun  2 14:37 charan
drwxr-x--- 2 devuser devuser 4096 Jun 16 04:52 devuser
```

```bash
root@Ozoo:/home# id devuser
uid=1001(devuser) gid=1001(devuser) groups=1001(devuser),1004(devteam)
```

```bash
root@Ozoo:/home# getent group devteam
devteam:x:1004:devuser
```

### What the output confirms
- `id devuser` → devuser belongs to their own group (1001) **and** devteam (1004) ✅
- `getent group devteam` → devteam group exists with devuser as a member ✅
- `ls -l` → devuser's home directory was created successfully ✅

<img width="960" height="593" alt="image" src="https://github.com/user-attachments/assets/dcc2c2c2-8c43-48ce-af84-cf0abf22ade4" />
