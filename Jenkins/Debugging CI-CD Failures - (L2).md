# Debugging CI/CD Failures - L2

## Objective
Reproduce, diagnose, and fix a Docker daemon permission failure in a real Jenkins pipeline — rather than a synthetic throwaway job, this was done directly against the production [U2Collab](https://github.com/Charan-bavaji/U2Collab) CI/CD pipeline, running on a native (non-containerized) Jenkins install on EC2.

## The Error

Intentionally broke the pipeline by removing the `jenkins` Linux user from the `docker` group:
```bash
sudo gpasswd -d jenkins docker
sudo systemctl restart jenkins
```

Triggering the pipeline afterward failed at the Docker build stage with:
```
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock
```

## The Root Cause

Jenkins pipeline steps that run `docker build` / `docker push` execute shell commands as the `jenkins` Linux system user. The Docker daemon socket (`/var/run/docker.sock`) is owned by `root` and the `docker` group:
```bash
ls -l /var/run/docker.sock
# srw-rw---- root docker /var/run/docker.sock
```

Only users who are members of the `docker` group (or root) can read/write that socket. Removing `jenkins` from the `docker` group meant the `jenkins` user no longer had permission to talk to the Docker daemon at all, so every `docker` command in the pipeline failed immediately at the socket connection step, before it could even attempt the build.

Confirmed via:
```bash
groups jenkins
# jenkins : jenkins   (docker group missing)
```

## The Fix

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

Group membership changes only take effect for new sessions/processes, so a Jenkins service restart was required — a running process does not pick up new group membership without one.

Confirmed via:
```bash
groups jenkins
# jenkins : jenkins docker
```

## Complication: Unrelated Stuck Build Queue

After the `systemctl restart jenkins`, re-triggering the pipeline got stuck in the queue indefinitely: `Still waiting to schedule task / Waiting for next available executor`, even though `systemctl status jenkins` showed the service healthy and active.

This turned out to be unrelated to the Docker fix — the EC2 instance type had been temporarily changed from `c7i-flex.large` down to `t2.small`, which didn't have enough resources to properly schedule/run the build executor. Switching the instance type back to `c7i-flex.large` resolved the stuck queue immediately, separate from the Docker permission fix.

## Verification

Re-ran the pipeline after both fixes (docker group membership + correct instance type). All stages passed — Checkout, Build Client Image, Build Server Image, Push to DockerHub, Deploy, and the health check — confirming the pipeline was fully restored to working order.

<img width="1901" height="1020" alt="Screenshot 2026-07-30 191435" src="https://github.com/user-attachments/assets/6ce8d595-a5c8-4f74-8667-f7d92f2e95f4" />

<img width="1920" height="1080" alt="Screenshot (28)" src="https://github.com/user-attachments/assets/f600ff7d-79cd-4391-87f7-c2d4a8047160" />


