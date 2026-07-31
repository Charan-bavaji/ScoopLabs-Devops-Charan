# Docker Assignment 3 — Container Lifecycle

## Detailed Description
Managing the container lifecycle.

## Concept Task
**Explain what `docker exec` does.**

`docker exec` runs a new command inside an already-running container — it doesn't start a new container, it attaches into the existing one's namespace.

- Common use: `docker exec -it my-nginx bash` drops you into an interactive shell inside the running Nginx container, so you can inspect logs, config files, or debug live, without stopping the container.
- Difference from `docker run`: `run` creates a new container from an image; `exec` executes a command in a container that's already running.
- Difference from `docker attach`: `attach` connects to the container's main process (PID 1) and its stdin/stdout; `exec` spins up a separate process inside the same container — safer, since exiting won't kill the main process.

**Summary:** `docker exec` lets you run an additional command — often a shell — inside a container that's already running, which is useful for debugging without disrupting the container's main process.

## Hands-on Task
Stopped the running Nginx container, removed it, and completely deleted the Nginx image from the local machine.

### Commands
```bash
# Stop the running container
docker stop my-nginx

# Remove the (now stopped) container
docker rm my-nginx

# Remove the image itself
docker rmi nginx
```

### Verification
```bash
docker ps -a        # should NOT show my-nginx anymore
docker images        # should NOT show nginx anymore
```

## Submission Requirements
- [x] Log of commands used: `docker stop my-nginx`, `docker rm my-nginx`, `docker rmi nginx` (above)
- [ ] Screenshot of `docker ps -a` (no my-nginx)
- [ ] Screenshot of `docker images` (no nginx)
