# Docker Installation — L1
## Charan Bavaji – Docker Installation Assignment (L1)

---

## Problem Statement

Install Docker Engine on a Linux system (Amazon Linux 2023 on AWS EC2), verify the installation by running the `hello-world` container, and explain the conceptual difference between a Virtual Machine and a Docker Container.

---

## Concept: VM vs Docker Container

| Feature | Virtual Machine (VM) | Docker Container |
|---|---|---|
| Virtualizes | Entire hardware (CPU, RAM, disk) | OS-level (processes, filesystem, network) |
| Own OS? | Yes — full Guest OS with kernel | No — shares Host OS kernel |
| Startup Time | Minutes | Seconds / milliseconds |
| Size | GBs (full OS image) | MBs (app + dependencies only) |
| Isolation Level | Hardware-level via Hypervisor | Process-level via namespaces + cgroups |
| Portability | Heavy, hypervisor-coupled | High — runs anywhere Docker is installed |
| Resource Overhead | High | Low |
| Use Case | Full OS isolation, legacy apps | Microservices, CI/CD, dev environments |

**Key difference:** A VM uses a Hypervisor to emulate hardware and runs a complete Guest OS on top. A Docker container shares the Host OS kernel and uses Linux **namespaces** (for isolation: PID, NET, MNT, UTS, IPC) and **cgroups** (for resource limits: CPU, memory, I/O) — making containers faster, lighter, and more portable.

---

## Environment

| Detail | Value |
|---|---|
| Platform | AWS EC2 |
| OS | Amazon Linux 2023 |
| Instance | `ip-172-31-31-228` |
| User | `devuser` |
| Hostname | `Ozoo` |

---

## Steps Followed

### Step 1 — Update System Packages

```bash
sudo dnf update -y
```

Ensures the package manager has the latest metadata before installing Docker.

### Step 2 — Install Docker Engine

```bash
sudo dnf install docker -y
```

Installs Docker Engine from the Amazon Linux 2023 package repository.

### Step 3 — Start and Enable Docker Service

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

- `start` — launches the Docker daemon immediately
- `enable` — ensures Docker starts automatically on system reboot

### Step 4 — Verify Docker Service Status

```bash
sudo systemctl status docker
```

Expected: `Active: active (running)`

### Step 5 — Add User to Docker Group

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Adds the current user to the `docker` group so Docker commands can be run without `sudo`. `newgrp` applies the group change to the current session without requiring a logout.

### Step 6 — Verify Docker Installation

```bash
docker --version
```

Expected output:
```
Docker version 25.x.x, build xxxxxxx
```

### Step 7 — Run hello-world Container

```bash
docker run hello-world
```

This command:
1. Checks local image cache for `hello-world:latest` → not found
2. Pulls the image from Docker Hub (`library/hello-world`)
3. Creates a container from the image
4. Runs the container → prints output → container exits

### Step 8 — Verify Image and Container State

```bash
docker images       # Confirm hello-world image is cached locally
docker ps -a        # Confirm stopped hello-world container exists
```

---

## Output

```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
Digest: sha256:...
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
...
```



---

## Key Concepts Learned

- **Docker Image** — A read-only, layered blueprint for a container (like a class definition)
- **Docker Container** — A running instance of an image (like an object instantiated from a class)
- **Docker Hub** — The default public image registry; Docker pulls images from here when not found locally
- **Docker Daemon** — Background service (`dockerd`) that manages containers, images, networks, and volumes
- **docker run lifecycle** — `pull (if needed) → create container → start container → execute → exit`

---
<img width="1920" height="1080" alt="Screenshot (2)" src="https://github.com/user-attachments/assets/466b7ef2-5e67-42e1-b9a4-a622af7dc1d6" />


```
