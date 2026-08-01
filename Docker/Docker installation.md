# Docker Assignment 1 — Docker Installation

## Detailed Description
Preparing the container engine.

## Concept Task
**Explain the difference between a Virtual Machine and a Docker Container.**

**Virtual Machine**
- Virtualizes hardware — each VM runs a full guest OS (kernel + all) on top of a hypervisor
- Heavy: gigabytes in size, takes minutes to boot
- Strong isolation since each VM has its own kernel
- Example: 3 VMs on one host = 3 full OS copies running

**Docker Container**
- Virtualizes the OS, not the hardware — containers share the host's kernel via namespaces and cgroups
- Lightweight: megabytes, starts in seconds
- Process-level isolation, not full kernel isolation
- Example: 3 containers on one host = 3 isolated processes sharing one kernel

**Summary:** A VM virtualizes hardware and runs a full OS per instance; a container virtualizes the OS and runs isolated processes that share the host kernel — that's why containers are faster to start and lighter on resources.

## Hands-on Task
Installed Docker Desktop for Windows with the WSL2 backend, enabled WSL Integration for the Ubuntu distro, and verified from the WSL terminal.

### Commands
```bash
docker --version
docker run hello-world
```

**Expected output:** The `hello-world` container prints a confirmation message showing the Docker client successfully contacted the Docker daemon, pulled the `hello-world` image, and ran it in a new container.

## Submission Requirements
<img width="1920" height="1080" alt="Screenshot (37)" src="https://github.com/user-attachments/assets/cbcd64c4-4af3-4c15-a808-6bd42eb6f9bd" />

