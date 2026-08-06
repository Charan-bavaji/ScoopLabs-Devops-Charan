# RCA: Docker Resource Exhaustion & Cgroup Throttling

## Summary
A data-processing application deployed as a Docker container had no CPU or 
memory limits, allowing it to consume nearly all available host resources 
and freeze other workloads. This was intentionally reproduced using a 
stress-testing image, observed via `docker stats`, and then mitigated by 
re-running the same workload with Docker cgroup-based resource constraints.

## What Are Cgroups?
Linux Control Groups (cgroups) are a kernel feature that lets the OS limit, 
account for, and isolate the resource usage (CPU, memory, disk I/O, network) 
of a group of processes. Every Docker container runs inside its own cgroup. 
When you pass flags like `--cpus` and `-m` to `docker run`, Docker translates 
them directly into cgroup CPU quota and memory limit settings enforced by 
the Linux kernel.

Without an explicit cgroup limit, a container's processes are free to consume 
as much CPU and memory as the host has available — the kernel scheduler will 
hand it as many CPU cycles as it asks for, and it can keep allocating memory 
until the host itself runs out.

## Step 1: Baseline — Unbounded Container

**Command:**
```bash
docker run -d --name rogue-app polinux/stress stress --cpu 4
docker stats --no-stream rogue-app
```

**Result:**

With no resource constraints, the container's 4 stress workers pushed CPU 
usage to **408.59%** — well over 4x a single core's worth of capacity — 
demonstrating that an unconstrained container will compete for the entire 
host's CPU pool and can starve every other process running on that machine.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/d509af83-e62e-40b4-bfcc-f82c2692d07a" />


**Cleanup:**
```bash
docker rm -f rogue-app
```

## Step 2: Mitigation — Cgroup-Enforced Limits

**Command:**
```bash
docker run -d --name throttled-app \
  --cpus="0.5" \
  -m="256m" \
  polinux/stress stress --cpu 4 --vm 1 --vm-bytes 512M
docker stats --no-stream throttled-app
```

**Result:**

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/b6bd7ff6-d1d9-4320-bfea-40ee26f56da2" />


Even though the stress process inside the container tried to use 4 CPU 
cores and allocate 512MB of memory, the Docker Engine configured its 
cgroup with a CPU quota equivalent to half a core and a hard memory 
ceiling of 256MB. The kernel enforced these limits directly: CPU usage 
was held at approximately **50.00%**, and memory usage was capped near 
**256MiB**, regardless of how aggressively the process inside tried to 
exceed them.

## Why This Matters in Production
Running containers without resource limits is a significant operational risk:

- **Noisy neighbor problem**: one misbehaving container can starve every 
  other container or process on the same host of CPU and memory.
- **Cascading failures**: memory leaks can trigger host-level OOM conditions, 
  causing the kernel to kill unrelated, healthy processes to reclaim memory.
- **No blast radius containment**: without limits, a single bug in one 
  service becomes a host-wide incident instead of a contained, single-
  container failure.
- **Unpredictable capacity planning**: without hard caps, it's impossible to 
  reliably calculate how many containers a host can safely run at once.

## Fix / Recommendation
All containers in production should have explicit `--cpus` and `-m` limits 
set (or the equivalent `resources.limits` block in Docker Compose or 
Kubernetes), sized to each workload's actual needs. This ensures a single 
container's bug or leak can never take down the entire host.
