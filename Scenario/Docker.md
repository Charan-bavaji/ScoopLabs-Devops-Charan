# Docker Interview Prep: 2 to 5 Years Experience

Questions with interview answers, plus the commands and file examples to say (and show) while answering.

**How to use this file:** For each question, read the **Say** part (your spoken answer in simple words). Then practice the **Commands** or **code** part. In the interview, say the answer first, then write or explain the commands.

**Practice folder (WSL with Docker):**

```bash
mkdir -p ~/linuxCMD/docker-lab && cd ~/linuxCMD/docker-lab
docker version
docker run --rm hello-world
```

## Sections

1. Basics and architecture (Q1 to Q6)
2. Dockerfile and images (Q7 to Q13)
3. Storage and volumes (Q14 to Q17)
4. Networking (Q18 to Q22)
5. Docker Compose (Q23 to Q26)
6. Troubleshooting scenarios (Q27 to Q40)
7. Security (Q41 to Q43)
8. Registry, CI/CD, and health checks (Q44 to Q47)
9. Concept questions (Q48 to Q51)

---

# 1. Basics and architecture

## Q1. What is Docker? What is the difference between a container and a virtual machine?

**Say:** Docker is a tool to build, ship, and run applications in **containers**. A container packs the app with everything it needs (libraries, runtime, config), so it runs the same on my laptop, on a test server, and in production. A **VM** has its own full operating system and runs on a hypervisor. A **container shares the host's kernel**, so it is much lighter: it starts in seconds and uses MBs, not GBs. The trade-off: containers are less isolated than VMs, because they share the kernel.

**Commands:**

```bash
docker run -it --rm ubuntu bash        # start a container and open a shell
uname -r                               # inside: shows the HOST's kernel version
exit
uname -r                               # on the host: the same kernel
```

---

## Q2. Explain Docker architecture.

**Say:** Docker uses a client-server model. The **Docker client** (`docker` command) sends requests to the **Docker daemon** (`dockerd`) through a REST API. The daemon manages images, containers, networks, and volumes. Under the daemon, **containerd** manages the container lifecycle, and **runc** actually creates the container process. A **registry** (Docker Hub, ECR) stores images.

Flow: `docker CLI → dockerd → containerd → runc → container`

**Commands:**

```bash
docker version                          # client and server (daemon) details
docker info                             # storage driver, cgroup version, number of containers
systemctl status docker                 # the daemon service
ps aux | grep -E "dockerd|containerd"   # the processes
ls -l /var/run/docker.sock              # the socket the client talks to
```

---

## Q3. What is the difference between an image, a container, and a Dockerfile? What are layers?

**Say:** A **Dockerfile** is the recipe (a text file with instructions). An **image** is the built, **read-only** package made from that recipe. A **container** is a **running instance** of an image, with a thin **writable layer** on top. Each Dockerfile instruction makes a **layer**. Layers are cached and shared between images, which saves disk space and makes builds fast.

**Commands:**

```bash
docker build -t myapp:1.0 .            # Dockerfile -> image
docker images                          # list images
docker history myapp:1.0               # the layers of an image
docker run -d --name app1 myapp:1.0    # image -> container
docker ps -a                           # list containers
docker diff app1                       # files changed in the writable layer
```

---

## Q4. Explain the container lifecycle. What is the difference between `docker stop` and `docker kill`?

**Say:** A container goes through these states: **created → running → paused → exited (stopped) → removed**. `docker stop` is polite: it sends **SIGTERM**, waits 10 seconds (default), and then sends **SIGKILL**. This gives the app time to close connections and save data. `docker kill` sends **SIGKILL** at once, with no cleanup.

**Commands:**

```bash
docker create --name c1 nginx          # created, not running
docker start c1                        # running
docker pause c1 ; docker unpause c1    # freeze and unfreeze
docker stop c1                         # SIGTERM, then SIGKILL after 10 seconds
docker stop -t 30 c1                   # wait up to 30 seconds
docker kill c1                         # SIGKILL now
docker restart c1
docker rm c1                           # remove a stopped container
docker rm -f c1                        # stop and remove
docker ps -a --filter status=exited    # find stopped containers
```

---

## Q5. How do containers work inside Linux? (namespaces and cgroups)

**Say:** A container is just a normal Linux process with two features. **Namespaces** control what the process can **see**: its own process list (pid), network, mounts, hostname, users. **cgroups** (control groups) control how much it can **use**: CPU, memory, disk I/O. The filesystem comes from image layers, joined by a union filesystem (overlay2). There is no "mini VM": it is only isolation and limits on a process.

**Commands:**

```bash
docker run -d --name web nginx
PID=$(docker inspect -f '{{.State.Pid}}' web)     # the process id on the host
ls -l /proc/$PID/ns                               # its namespaces
sudo lsns -p $PID                                 # list namespaces of that process
ps aux | grep nginx                               # the container process is visible on the host

# cgroup limits (path depends on the cgroup version):
docker run -d --name limited --memory 256m --cpus 0.5 nginx
docker inspect -f 'mem={{.HostConfig.Memory}} cpu={{.HostConfig.NanoCpus}}' limited
```

---

## Q6. Which Docker commands and `docker run` flags do you use every day?

**Say:** These are the ones I use the most:

| Flag | Meaning |
|---|---|
| `-d` | run in the background (detached) |
| `-it` | interactive terminal |
| `--name` | give a name |
| `-p 8080:80` | publish port (host:container) |
| `-v vol:/path` | mount a volume |
| `-e KEY=value` | set an environment variable |
| `--rm` | remove the container when it stops |
| `--restart unless-stopped` | restart policy |
| `--memory`, `--cpus` | resource limits |

**Commands:**

```bash
docker run -d --name web -p 8080:80 -e ENV=prod --restart unless-stopped nginx
docker ps                                    # running containers
docker logs -f --tail 100 web                # follow the last 100 log lines
docker exec -it web sh                       # open a shell inside
docker inspect web                           # full details (JSON)
docker inspect -f '{{.NetworkSettings.IPAddress}}' web
docker top web                               # processes inside
docker stats --no-stream                     # CPU and memory now
docker cp web:/etc/nginx/nginx.conf .        # copy a file out
```

---

# 2. Dockerfile and images

## Q7. Explain the Dockerfile instructions. `CMD` vs `ENTRYPOINT`, `COPY` vs `ADD`, `ARG` vs `ENV`, shell form vs exec form.

**Say:**

- **RUN** runs a command at **build time** and creates a layer (install packages). **CMD** is the default command at **run time**. It is easy to override with `docker run image <other command>`.
- **ENTRYPOINT** is the fixed main program. Arguments from `docker run` are added to it. When I use both, ENTRYPOINT is the program and CMD is its default arguments.
- **COPY** copies files from my machine. **ADD** can also unpack tar files and download URLs. I prefer `COPY`, because it is simple and clear.
- **ARG** exists only at **build time**. **ENV** stays in the image and is available at **run time**.
- **Exec form** `["node","server.js"]` runs the program directly as PID 1, so it receives signals like SIGTERM. **Shell form** `node server.js` runs through `/bin/sh -c`, and the app may not receive signals.
- **EXPOSE** only documents a port. It does not publish it. `-p` publishes.

```dockerfile
FROM node:20-alpine
WORKDIR /app
ARG APP_VERSION=1.0
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
EXPOSE 3000
ENTRYPOINT ["node"]
CMD ["server.js"]
```

**Commands:**

```bash
docker run myapp                       # runs: node server.js
docker run myapp other.js              # CMD replaced: node other.js
docker run --entrypoint sh -it myapp   # replace the ENTRYPOINT
docker build --build-arg APP_VERSION=2.0 -t myapp:2.0 .
```

---

## Q8. Write a good Dockerfile for a Node.js app. What makes it "good"?

**Say:** A good Dockerfile is small, fast to rebuild, and safe. I choose a small base image with a fixed version. I copy `package.json` **first** and install dependencies, so Docker cache is reused when only the source code changes. I use a `.dockerignore` to keep junk and secrets out. I run the app as a **non-root user**. I use exec form for CMD.

```dockerfile
FROM node:20-alpine
WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY --chown=node:node . .

ENV NODE_ENV=production
EXPOSE 3000
USER node
CMD ["node", "server.js"]
```

`.dockerignore`

```
node_modules
.git
.env
*.log
Dockerfile
docker-compose.yml
```

**Commands:**

```bash
docker build -t myapp:1.0 .
docker run -d --name myapp -p 3000:3000 myapp:1.0
docker exec myapp whoami               # should print: node (not root)
```

---

## Q9. What is a multi-stage build? Why use it?

**Say:** A multi-stage build uses **more than one `FROM`** in one Dockerfile. The first stage has all the build tools (compilers, dev dependencies) and builds the app. The last stage starts from a clean small image and copies **only the result**. So the final image is much smaller and has fewer tools for an attacker to use.

```dockerfile
# Stage 1: build
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: run (only the built files)
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
```

The build folder name depends on the tool (`dist` for Vite, `build` for Create React App).

**Commands:**

```bash
docker build -t myfrontend:1.0 .
docker images myfrontend               # compare the size with a single-stage build
docker build --target build -t myfrontend:build .    # build only the first stage
```

---

## Q10. How do you reduce the size of a Docker image?

**Say:** I use these ideas:

1. A **small base image**: `alpine`, `-slim`, or `distroless`.
2. **Multi-stage builds** (Q9).
3. A **`.dockerignore`** file.
4. Install only what is needed (`npm ci --omit=dev`, `apt-get install --no-install-recommends`).
5. **Clean the cache in the same RUN line**, because a later `rm` cannot shrink an earlier layer.
6. Combine related commands in one `RUN` to make fewer layers.

```dockerfile
FROM python:3.12-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
```

**Commands:**

```bash
docker images                          # check the size
docker history myapp:1.0               # which layer is big?
docker history --no-trunc myapp:1.0
dive myapp:1.0                         # (tool) explore layers and wasted space
```

---

## Q11. Your Docker build is slow. How does the build cache work, and how do you use it?

**Say:** Docker caches each layer. If an instruction and the files it uses have not changed, Docker reuses the layer. But when one layer changes, **all layers after it are rebuilt**. So I put things that **change rarely first** (base image, dependency install) and things that **change often last** (source code). That is why `COPY package*.json` and `RUN npm ci` come before `COPY . .`. BuildKit also supports cache mounts and remote cache for CI.

**Commands:**

```bash
docker build -t myapp .                       # fast when nothing changed
docker build --no-cache -t myapp .            # ignore cache (full rebuild)
docker builder prune                          # clear the build cache
```

```dockerfile
# syntax=docker/dockerfile:1
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm npm ci
COPY . .
```

**In CI (cache stored in a registry):**

```bash
docker buildx build \
  --cache-from type=registry,ref=<user>/myapp:cache \
  --cache-to type=registry,ref=<user>/myapp:cache,mode=max \
  -t <user>/myapp:1.0 --push .
```

---

## Q12. How do you use secrets in a Docker build without leaking them?

**Say:** I never put secrets in `ENV`, `ARG`, or `COPY .env`, because they stay in the image layers, and anyone can see them with `docker history`. For build-time secrets (like a private npm token), I use **BuildKit secret mounts**. The secret is available only during that one `RUN`, and it is not saved in any layer. For run-time secrets, I pass them when the container starts (env file, Docker/Compose secrets, or a secrets manager) and do not bake them into the image.

```dockerfile
# syntax=docker/dockerfile:1
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN --mount=type=secret,id=npm_token \
    NPM_TOKEN=$(cat /run/secrets/npm_token) npm ci
```

**Commands:**

```bash
docker build --secret id=npm_token,src=./npm_token.txt -t myapp .
docker history myapp                   # the secret is not visible
docker run -d --env-file ./prod.env myapp      # run-time values (keep this file out of Git)
```

---

## Q13. What is a good tagging strategy? Why avoid `latest`?

**Say:** `latest` is only a normal tag name. It does not mean "newest", and it can point to a different image next week, so I cannot tell what is running or roll back. In production I use **version tags** (`1.4.2`), the **Git commit SHA**, or the **build number**. I also **pin base images** to a specific version, and for the strongest safety, to a **digest**, which never changes.

**Commands:**

```bash
docker build -t myapp:1.4.2 -t myapp:$(git rev-parse --short HEAD) .
docker tag myapp:1.4.2 <user>/myapp:1.4.2
docker images --digests                        # see the digest of each image
docker inspect -f '{{index .RepoDigests 0}}' <user>/myapp:1.4.2
docker pull nginx@sha256:<digest>              # pull by digest (fixed forever)
```

---

# 3. Storage and volumes

## Q14. What is the difference between volumes, bind mounts, and tmpfs?

**Say:** A **volume** is created and managed by Docker (in `/var/lib/docker/volumes`). It is the best choice for **persistent data** like databases, and it works the same on any machine. A **bind mount** maps a **host folder** into the container. It is good for **development** (edit code on the host, see it in the container). A **tmpfs** mount is stored in **memory** only and is gone when the container stops, so it is good for temporary or sensitive files.

**Commands:**

```bash
docker volume create pgdata
docker run -d --name db -e POSTGRES_PASSWORD=secret \
  -v pgdata:/var/lib/postgresql/data postgres:16              # volume

docker run -d --name devapp -v $(pwd):/app -w /app node:20 \
  sh -c "npm install && npm start"                            # bind mount

docker run -d --name t --tmpfs /tmp nginx                     # tmpfs

docker run -d --mount type=volume,src=pgdata,dst=/data alpine sleep 3600   # --mount syntax

docker volume ls
docker volume inspect pgdata
docker volume prune                                           # removes unused volumes (careful!)
```

---

## Q15. You removed a database container and all the data is gone. What happened? How do you prevent and recover it?

**Say:** The data was stored in the container's **writable layer**, which is deleted with the container. The fix is to store data in a **volume**. To recover, I first check if the container ran with an **anonymous volume** (for example, the image itself declares `VOLUME`). Those volumes stay after `docker rm` unless I used `-v`, and I can find and mount them. If the data was only in the writable layer and the container is deleted, it cannot be recovered.

**Commands:**

```bash
# Prevent: always use a named volume for data
docker run -d --name db -v pgdata:/var/lib/postgresql/data -e POSTGRES_PASSWORD=secret postgres:16

# Recover: look for leftover volumes
docker volume ls
docker volume ls -f dangling=true
docker run --rm -v <volume-name>:/data alpine ls -la /data     # look inside a volume

# If the container is stopped but not removed, copy the data out
docker cp db:/var/lib/postgresql/data ./data-backup
```

---

## Q16. How do you back up and restore a Docker volume?

**Say:** I mount the volume in a small temporary container, together with a host folder, and create a tar file. To restore, I do the reverse into a new volume. For databases, I prefer a **logical backup** with the database tool (like `pg_dump`), because it is consistent.

**Commands:**

```bash
# backup a volume to a tar file in the current folder
docker run --rm -v pgdata:/data -v $(pwd):/backup alpine \
  tar czf /backup/pgdata.tar.gz -C /data .

# restore into a new volume
docker volume create pgdata_new
docker run --rm -v pgdata_new:/data -v $(pwd):/backup alpine \
  tar xzf /backup/pgdata.tar.gz -C /data

# better for databases:
docker exec db pg_dump -U postgres mydb > backup.sql
docker exec -i db psql -U postgres mydb < backup.sql
```

---

## Q17. You get "Permission denied" on a mounted volume or folder. Why? How do you fix it?

**Say:** Usually a **user ID mismatch**. The app in the container runs as a user with some UID (for example `1000` or `postgres`), but the host folder is owned by a different UID. Linux checks the numbers, not the names. I check the UID inside the container and the owner on the host, and then fix the owner, or run the container with a matching user. On systems with **SELinux** (RHEL, CentOS), the mount also needs the `:z` or `:Z` flag.

**Commands:**

```bash
docker exec app id                             # UID and GID inside the container
ls -ln ./data                                  # numeric owner on the host
sudo chown -R 1000:1000 ./data                 # make the host folder match the container user
docker run --user $(id -u):$(id -g) -v $(pwd)/data:/data myapp    # run as my own user
docker run -v $(pwd)/data:/data:Z myapp        # SELinux label fix
```

---

# 4. Networking

## Q18. What are the Docker network drivers? What is the difference between the default bridge and a user-defined bridge?

**Say:**

| Driver | What it does |
|---|---|
| **bridge** | default; containers on one host talk through a virtual switch |
| **host** | container shares the host's network (no isolation, no port mapping) |
| **none** | no network |
| **overlay** | connects containers across many hosts (Swarm) |
| **macvlan** | container gets its own MAC and IP on the real network |

The **default bridge** (`docker0`) has no name-based DNS. Containers can reach each other only by IP. A **user-defined bridge** has **automatic DNS**, so containers reach each other **by name**, and it gives better isolation. So I always create my own network for apps.

**Commands:**

```bash
docker network ls
docker network create appnet
docker run -d --name db --network appnet postgres:16
docker run -d --name api --network appnet myapi
docker network inspect appnet
docker network connect appnet other-container
docker network disconnect appnet other-container
docker run -d --network host nginx             # host network (Linux only)
```

---

## Q19. Two containers cannot talk to each other. How do you troubleshoot?

**Say:** I check in this order: (1) Are they on the **same network**? (2) Am I using the **container/service name**, not `localhost`? (3) Is the app listening on `0.0.0.0` and not `127.0.0.1`? (4) Am I using the **container port** and not the published host port? (5) Is a firewall or a wrong network blocking it?

**Commands:**

```bash
docker network inspect appnet                        # are both containers listed?
docker inspect -f '{{json .NetworkSettings.Networks}}' api
docker exec api getent hosts db                      # does the name resolve?
docker exec api ping -c 2 db
docker exec api nc -zv db 5432                       # is the port open?
docker exec db ss -tulnp                             # is the app listening on 0.0.0.0 or 127.0.0.1?

# fix: put both on the same user-defined network
docker network connect appnet api
```

Some slim images do not have `ping`, `nc`, or `ss`. In that case use a debug container (see Q36).

---

## Q20. A container cannot reach the internet. What do you check?

**Say:** First I test with an IP address and then with a name. If the **IP works but the name fails**, it is a **DNS** problem. If the **IP also fails**, it is a routing or firewall problem.

**Commands:**

```bash
docker run --rm alpine ping -c 2 8.8.8.8            # IP works?
docker run --rm alpine nslookup google.com          # name works?
docker run --rm alpine cat /etc/resolv.conf

sysctl net.ipv4.ip_forward                          # must be 1 on the host
sudo iptables -L FORWARD -n | head                  # is forwarding dropped? (UFW can do this)
env | grep -i proxy                                 # corporate proxy?
```

**Fixes:**

- DNS: `docker run --dns 8.8.8.8 ...` or set it for all containers in `/etc/docker/daemon.json`:

```json
{ "dns": ["8.8.8.8", "1.1.1.1"] }
```

- IP forwarding is off: `sudo sysctl -w net.ipv4.ip_forward=1`.
- Subnet clash: if the company network or VPN uses `172.17.0.0/16`, change Docker's bridge with `"bip": "10.200.0.1/24"` in `daemon.json`.
- After changes: `sudo systemctl restart docker`.

---

## Q21. Explain port publishing. Why can't I reach my container from outside?

**Say:** `-p 8080:80` maps **host port 8080** to **container port 80**. `EXPOSE` in the Dockerfile only documents the port. If I cannot reach the app, I check: is the port published (`docker ps`)? Does the app listen on `0.0.0.0` inside the container? Is the host port already used? Does the host firewall or the **cloud security group** allow the port? One more tip: Docker adds its own iptables rules, so a published port can be open even if **UFW** says it is blocked. To keep a port private, I bind it to `127.0.0.1`.

**Commands:**

```bash
docker run -d --name web -p 8080:80 nginx
docker run -d -p 127.0.0.1:8080:80 nginx        # only reachable from the host itself
docker run -d -P nginx                          # publish all EXPOSEd ports to random host ports
docker ps --format "table {{.Names}}\t{{.Ports}}"
docker port web
curl -I localhost:8080
sudo ss -tulnp | grep 8080                      # is the host port used?
```

---

## Q22. How does DNS and service discovery work between containers?

**Say:** On a **user-defined network**, Docker runs a small built-in DNS server at `127.0.0.11`. Each container name (and network alias) is a DNS name, so `api` can call `http://db:5432` without knowing any IP. In Compose, each **service name** becomes a DNS name. This is why IP addresses should not be hard-coded.

**Commands:**

```bash
docker network create appnet
docker run -d --name db --network appnet --network-alias database postgres:16
docker run --rm --network appnet alpine nslookup db
docker run --rm --network appnet alpine nslookup database
docker run --rm --network appnet alpine cat /etc/resolv.conf     # shows 127.0.0.11
```

---

# 5. Docker Compose

## Q23. What is Docker Compose? Write a compose file for a Node API with MongoDB.

**Say:** Compose lets me define and run **many containers** with one YAML file and one command. It creates a network for the services, so they reach each other by service name. I use it for local development and small setups. The example has an API and a database, a named volume so data is kept, a health check, and a start order that waits for a healthy database.

`docker-compose.yml`

```yaml
services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      MONGO_URL: mongodb://mongo:27017/appdb
    depends_on:
      mongo:
        condition: service_healthy
    restart: unless-stopped

  mongo:
    image: mongo:7
    volumes:
      - mongo_data:/data/db
    healthcheck:
      test: ["CMD", "mongosh", "--quiet", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  mongo_data:
```

**Commands:**

```bash
docker compose up -d
docker compose ps
docker compose logs -f api
docker compose down                    # stop and remove containers and network
docker compose down -v                 # also remove volumes (deletes data!)
```

---

## Q24. The API starts before the database is ready and crashes. How do you fix it?

**Say:** `depends_on` alone only controls the **start order**. It does not wait until the database is **ready** to accept connections. The fix is a **health check** on the database and `depends_on` with `condition: service_healthy`. It is also good practice to add **retry logic** in the app, because in production the database can restart at any time.

```yaml
services:
  api:
    build: .
    depends_on:
      db:
        condition: service_healthy
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: secret
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 10
```

**Commands:**

```bash
docker compose up -d
docker compose ps                                      # look for "healthy"
docker inspect -f '{{.State.Health.Status}}' <db-container>
```

---

## Q25. How do you manage environment variables and secrets in Compose?

**Say:** For normal settings, I use `environment` or `env_file`. A `.env` file next to the compose file is used to fill `${VARIABLES}` inside the YAML. I keep `.env` files **out of Git**. For real secrets, I use the Compose `secrets` feature, which mounts the value as a file in `/run/secrets/<name>`, so it does not show in `docker inspect` as an environment variable.

`.env`

```
DB_USER=appuser
POSTGRES_TAG=16
```

`docker-compose.yml`

```yaml
services:
  db:
    image: postgres:${POSTGRES_TAG}
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
  api:
    build: .
    env_file:
      - ./api.env

secrets:
  db_password:
    file: ./db_password.txt
```

**Commands:**

```bash
docker compose config                  # show the final file with all variables filled in
echo ".env" >> .gitignore
```

---

## Q26. Which Compose commands do you use daily? How do you scale a service?

**Commands:**

```bash
docker compose up -d                   # start (create if needed)
docker compose up -d --build           # rebuild images, then start
docker compose down                    # stop and remove
docker compose ps
docker compose logs -f --tail 50 api
docker compose exec api sh             # shell in a running service
docker compose run --rm api npm test   # one-off command in a new container
docker compose restart api
docker compose pull                    # get newer images
docker compose config                  # validate and show the final config
docker compose up -d --scale api=3     # run 3 copies of the api service
```

**Say:** For scaling, the service must not use a fixed host port (`3000:3000`), or the copies will clash on the port. I remove the host port and put a reverse proxy or load balancer (like Nginx) in front. For real production scaling I move to Kubernetes.

---
# 6. Troubleshooting scenarios

## Q27. A container exits immediately after starting. How do you find out why?

**Say:** A container lives only as long as its **main process (PID 1)**. If that process ends, the container exits. So I check the exit code and the logs. Common causes: the app crashed, the command is wrong, a config or environment variable is missing, or the app runs in the **background** (like `service nginx start`) so PID 1 ends at once.

**Commands:**

```bash
docker ps -a                                          # see the exit code in STATUS
docker logs --tail 100 mycontainer
docker inspect -f 'exit={{.State.ExitCode}} err={{.State.Error}} oom={{.State.OOMKilled}}' mycontainer
docker run -it --entrypoint sh myimage                # start a shell instead, then try the command by hand
docker inspect -f '{{.Config.Cmd}} {{.Config.Entrypoint}}' myimage
```

**Exit codes to remember:**

| Code | Meaning |
|---|---|
| 0 | finished normally (no long-running process) |
| 1 | app error |
| 125 | `docker run` itself failed |
| 126 | command found but cannot run (permission) |
| 127 | command not found |
| 137 | killed with SIGKILL (often out of memory, or `docker kill`) |
| 139 | segmentation fault |
| 143 | stopped by SIGTERM |

**Fix:** run the main process in the **foreground**. For example, use `nginx -g 'daemon off;'`, not `service nginx start`.

---

## Q28. A container keeps restarting again and again. What do you do?

**Say:** `docker ps` shows `Restarting (1)`. This happens because of a **restart policy** (`always`, `unless-stopped`, `on-failure`) and an app that keeps crashing. I read the logs to find the cause (missing env variable, database not reachable, bad config). To stop the loop while I debug, I change the policy. To avoid infinite loops in the future I use `on-failure:5`.

**Commands:**

```bash
docker ps -a
docker inspect -f 'restarts={{.RestartCount}} exit={{.State.ExitCode}}' mycontainer
docker logs --tail 100 mycontainer
docker update --restart=no mycontainer               # stop the restart loop
docker run -d --restart on-failure:5 myapp           # retry only 5 times
```

**Policies:** `no` (default), `on-failure[:N]`, `always`, `unless-stopped`. The difference: `unless-stopped` will not restart a container that I stopped by hand, even after the Docker daemon restarts.

---

## Q29. A container is killed with exit code 137 (OOMKilled). How do you fix it?

**Say:** Exit code 137 means it was killed by SIGKILL. When it is because of memory, the container went over its **memory limit** and the kernel's OOM killer stopped it. I confirm with `OOMKilled`, then I find the reason: a memory leak, a limit that is too low, or the app not knowing about the container limit (for example, Java or Node using more heap than the container has).

**Commands:**

```bash
docker inspect -f '{{.State.OOMKilled}} {{.State.ExitCode}}' mycontainer    # true 137
dmesg -T | grep -i -E "oom|killed process"
docker stats --no-stream                              # memory use vs limit
docker update --memory 1g --memory-swap 1g mycontainer    # raise the limit for a running container
docker run -d --memory 1g myapp
```

**Fixes:** raise the limit if it is really too low, fix the leak, and set the app's own memory settings (Node: `--max-old-space-size`; Java: `-XX:MaxRAMPercentage=75`). Add monitoring and alerts for memory.

---

## Q30. How do you limit CPU and memory for containers? What is the difference between a "rogue" and a "throttled" container?

**Say:** With **cgroups** through Docker flags. A **rogue** container has **no limits**: it can take all CPU or memory of the host and hurt other containers. A **throttled** container has limits: with `--cpus 0.5` it can use only half a CPU core, so the kernel slows it down. With `--memory 256m` it is killed (OOM) if it goes over. I set limits in production so one bad container cannot take the whole server.

**Commands:**

```bash
docker run -d --name rogue alpine sh -c 'while true; do :; done'
docker run -d --name throttled --cpus 0.5 alpine sh -c 'while true; do :; done'
docker stats --no-stream                # rogue ~100% of a core, throttled ~50%

# memory: this container will be OOM killed
docker run -d --name memhog --memory 100m polinux/stress stress --vm 1 --vm-bytes 200M --vm-hang 0
docker inspect -f '{{.State.OOMKilled}}' memhog

# other flags
docker run -d --memory 512m --memory-reservation 256m --cpus 1.5 --pids-limit 200 myapp
docker run -d --cpu-shares 512 myapp    # relative weight when CPU is busy
docker rm -f rogue throttled memhog
```

Note: `--cpus` is a hard cap. `--cpu-shares` is only a relative weight and matters only when the CPU is fully used.

---

## Q31. The server disk is full because of Docker. What do you do?

**Say:** I check how Docker uses the disk, and then clean the unused things carefully. The big parts are usually **old images**, **stopped containers**, **build cache**, **volumes**, and **container logs**. I never delete files inside `/var/lib/docker` by hand.

**Commands:**

```bash
df -h
docker system df                                    # summary: images, containers, volumes, build cache
docker system df -v                                 # details
sudo du -sh /var/lib/docker/* | sort -h | tail

docker container prune                              # remove stopped containers
docker image prune                                  # remove dangling images (untagged)
docker image prune -a                               # remove ALL unused images
docker builder prune                                # remove build cache
docker volume prune                                 # removes unused volumes (DATA! be careful)
docker system prune                                 # containers + networks + dangling images + cache

# biggest log files
sudo du -sh /var/lib/docker/containers/*/*-json.log | sort -h | tail
```

**Prevent:** set log rotation (Q32), schedule cleanup of old images, and keep `/var/lib/docker` on its own bigger disk.

---

## Q32. A container's log file is huge. How do you control Docker logs?

**Say:** By default, the `json-file` driver keeps logs **forever** in `/var/lib/docker/containers/<id>/<id>-json.log`, so they can fill the disk. I set a maximum size and a number of files. The daemon setting works only for **new** containers, so old containers must be recreated. For many servers, I send logs to a central system (ELK, Loki, CloudWatch).

`/etc/docker/daemon.json`

```json
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" }
}
```

**Commands:**

```bash
sudo systemctl restart docker                       # apply the daemon settings
docker run -d --log-opt max-size=10m --log-opt max-file=3 myapp   # per container
sudo truncate -s 0 /var/lib/docker/containers/<id>/<id>-json.log  # emergency: empty a big log
docker logs --since 10m --tail 200 mycontainer
```

```yaml
# in docker-compose.yml
services:
  api:
    image: myapp
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
```

---

## Q33. "permission denied while trying to connect to the Docker daemon socket". How do you fix it?

**Say:** My user is not allowed to use the Docker socket. The socket belongs to the `docker` group, so I add my user to that group and start a new login session. Note that the `docker` group gives **root-level power** on that machine, so I add only trusted users.

**Commands:**

```bash
ls -l /var/run/docker.sock                          # owner root, group docker
id                                                  # is "docker" in my groups?
sudo usermod -aG docker $USER
newgrp docker                                       # or log out and log in again
docker ps                                           # test
```

Do not use `chmod 666 /var/run/docker.sock`. For better security, use **rootless Docker**.

---

## Q34. `docker pull` fails. What are the common errors and fixes?

**Say:** I read the error message, because each one points to a different cause.

| Error | Meaning | Fix |
|---|---|---|
| `toomanyrequests` | Docker Hub pull rate limit | `docker login`, or use a mirror or ECR pull-through cache |
| `unauthorized` / `denied` | not logged in, or no access | `docker login`, check the token and repo name |
| `manifest unknown` / `not found` | wrong image name or tag | check the tag on the registry |
| `no matching manifest for linux/arm64` | image is not built for this CPU | `docker pull --platform linux/amd64 <image>` |
| `TLS handshake timeout` / `no such host` | network or DNS problem | check DNS, proxy, and firewall |
| `x509: certificate signed by unknown authority` | private registry certificate | install the CA cert (or `insecure-registries` only for a lab) |
| `no space left on device` | disk full | `docker system df` and prune (Q31) |

**Commands:**

```bash
docker login
docker pull --platform linux/amd64 nginx
curl -I https://registry-1.docker.io/v2/            # can I reach the registry?
docker info | grep -i -E "proxy|registry"
cat /etc/docker/daemon.json
```

---

## Q35. A container will not stop or cannot be removed. What do you do?

**Say:** If `docker stop` hangs for 10 seconds and then kills it, the app is **ignoring SIGTERM** (often because of shell-form CMD or no signal handling). I use `docker kill` or `docker rm -f`. If removal fails with "device or resource busy" or "removal in progress", something on the host is still using its mounts, or the process is stuck in D state (waiting for disk or NFS). Then I look at the process on the host, and restarting the Docker service is the last step.

**Commands:**

```bash
docker stop mycontainer                             # hangs?
docker kill mycontainer
docker rm -f mycontainer
docker inspect -f '{{.State.Pid}}' mycontainer      # PID on the host
ps -o pid,stat,cmd -p <PID>                         # D = stuck in I/O, Z = zombie
sudo systemctl restart docker                       # last option
```

Fix the root cause with exec-form CMD (Q39) and `--init`.

---

## Q36. How do you debug a running container that has no shell (a slim or distroless image)?

**Say:** `docker exec -it c sh` fails because the image has no shell or tools. I do not add tools to the production image. Instead I start a **debug container** that **shares the network and process namespace** of the target. That gives me all the tools (ping, curl, ss, tcpdump) and I see the same network and processes. I can also copy files out, or use `nsenter` from the host.

**Commands:**

```bash
docker exec -it myapp sh                            # fails: no shell
docker logs myapp
docker inspect myapp
docker cp myapp:/app/config.json .                  # copy files out

# debug container sharing the target's network and processes
docker run -it --rm --pid=container:myapp --net=container:myapp nicolaka/netshoot

# from the host: run a command inside the network namespace only
PID=$(docker inspect -f '{{.State.Pid}}' myapp)
sudo nsenter -t $PID -n ss -tulnp
```

---

## Q37. The Docker daemon will not start. What do you check?

**Say:** I read the daemon log first. The most common cause is a **wrong `daemon.json`** (bad JSON or an option that clashes with a flag in the systemd service). Other causes: disk full, a leftover socket or PID file, storage driver problems, or iptables problems.

**Commands:**

```bash
sudo systemctl status docker
sudo journalctl -u docker -n 100 --no-pager
cat /etc/docker/daemon.json
python3 -m json.tool /etc/docker/daemon.json        # is the JSON valid?
df -h ; df -i                                       # disk and inodes
sudo dockerd --debug                                # run in the foreground for detailed errors
sudo systemctl restart docker
```

Typical fix: correct the JSON, remove the setting that clashes (for example `hosts` set in both places), free the disk, then restart.

---

## Q38. "port is already allocated" or "address already in use", and "no space left on device" during a build. How do you fix them?

**Say:** **Port already allocated** means something already uses that host port: another container or a normal process. I find it, and then stop it or change my host port. **No space left on device** during a build means the disk is full, usually because of old images and build cache.

**Commands:**

```bash
# port problem
sudo ss -tulnp | grep 8080
docker ps --format "table {{.Names}}\t{{.Ports}}"
docker stop <old-container>
docker run -d -p 8081:80 nginx                      # or use another host port

# space problem
df -h
docker system df
docker builder prune -f
docker image prune -a
```

---

## Q39. `docker stop` takes 10 seconds, and zombie processes appear in my container. Why?

**Say:** The process with **PID 1** in a container is special. It must handle signals like SIGTERM and clean up child processes. A normal app often does not do this. If I use **shell form** CMD, the shell is PID 1 and the app does not get the signal, so Docker waits 10 seconds and then kills it. Also, old child processes can stay as **zombies**, because PID 1 does not collect them. The fixes: use **exec form**, use `exec` in entrypoint scripts, and run with a tiny init program (`--init` uses tini).

```dockerfile
CMD ["node", "server.js"]         # exec form: the app is PID 1 and gets signals
```

`entrypoint.sh`

```sh
#!/bin/sh
set -e
# ... setup steps ...
exec "$@"                         # replace the shell with the real process
```

**Commands:**

```bash
docker run -d --init --name app myapp
docker exec app ps aux                              # PID 1 should be the init or your app
docker stop app                                     # should be quick now
```

```yaml
# in docker-compose.yml
services:
  api:
    image: myapp
    init: true
```

---

## Q40. The app works on my machine but not inside Docker, because it cannot reach the database on `localhost`. Why?

**Say:** Inside a container, **`localhost` is the container itself**, not the host and not another container. So `localhost:5432` means "the database inside my own container", and there is none. To reach another container I use its **name** on a user-defined network. To reach a service on the **host**, I use `host.docker.internal` (Docker Desktop) or the host gateway on Linux. Also, the app must listen on **`0.0.0.0`**, not `127.0.0.1`, or nobody can reach it from outside the container.

**Commands:**

```bash
# another container: use its name
docker run -d --name api --network appnet -e DB_HOST=db myapi

# the host machine, on Linux
docker run --add-host=host.docker.internal:host-gateway myapp
# then use: host.docker.internal:5432

docker exec api getent hosts db                     # does the name resolve?
docker exec api ss -tulnp                           # the app listens on 0.0.0.0?
```

---

# 7. Security

## Q41. What are the Docker security best practices?

**Say:** I think in layers: the image, the container, and the host.

1. **Small, trusted base images**, pinned to a version. Fewer packages means fewer vulnerabilities.
2. **Do not run as root.** Use `USER` in the Dockerfile.
3. **Scan images** in CI (Trivy, Docker Scout) and rebuild often.
4. **No secrets in images** (Q12). Use secrets or a secrets manager.
5. **Never use `--privileged`**, and do not mount the Docker socket into containers.
6. **Drop Linux capabilities** and use a **read-only filesystem** where possible.
7. **Set resource limits** (memory, CPU, pids).
8. **Keep Docker and the host updated.** Use rootless mode or user namespaces if possible.
9. **Network rules:** separate networks, publish only the needed ports, bind private ports to `127.0.0.1`.

**Commands:**

```bash
docker run -d --name secure-app \
  --user 1000:1000 \
  --read-only --tmpfs /tmp \
  --cap-drop ALL --cap-add NET_BIND_SERVICE \
  --security-opt no-new-privileges:true \
  --memory 256m --pids-limit 100 \
  -p 127.0.0.1:8080:8080 \
  myapp:1.0

docker exec secure-app id                           # not root
docker inspect -f '{{.HostConfig.Privileged}}' secure-app    # false
```

---

## Q42. How do you scan images for vulnerabilities and lint Dockerfiles?

**Say:** I scan every image in the CI pipeline and fail the build when it has **HIGH or CRITICAL** issues that have a fix. I use **Trivy** or **Docker Scout**. I also lint the Dockerfile with **hadolint** to catch bad practices early. To fix findings, I usually update the base image and dependencies, and rebuild.

**Commands:**

```bash
trivy image myapp:1.0
trivy image --severity HIGH,CRITICAL --exit-code 1 myapp:1.0    # fail the pipeline
trivy image --ignore-unfixed myapp:1.0
docker scout cves myapp:1.0
hadolint Dockerfile
```

---

## Q43. Why is mounting `/var/run/docker.sock` into a container dangerous?

**Say:** The Docker socket is the **control panel of the Docker daemon**, and the daemon runs as root. A container that has the socket can start new containers, including a **privileged one that mounts the host's `/`**. That means full root access to the host. Some tools (CI agents, monitoring tools) ask for it, but I avoid it. Better options: build with **Kaniko** or **Buildah** (no daemon), use rootless Docker, or use a **socket proxy** that allows only safe API calls.

**Commands (a demo that shows the risk):**

```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock docker:cli docker ps
# this container can see and control ALL containers of the host
```

---

# 8. Registry, CI/CD, and health checks

## Q44. How do you push an image to Docker Hub and to AWS ECR?

**Say:** I log in to the registry, **tag** the image with the registry address and a version, and **push**. For ECR the login uses a temporary token from the AWS CLI.

**Docker Hub:**

```bash
docker login -u <dockerhub-user>
docker tag myapp:1.0 <dockerhub-user>/myapp:1.0
docker push <dockerhub-user>/myapp:1.0
docker pull <dockerhub-user>/myapp:1.0
```

**AWS ECR:**

```bash
aws ecr create-repository --repository-name myapp --region ap-south-1
aws ecr get-login-password --region ap-south-1 \
  | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-south-1.amazonaws.com
docker tag myapp:1.0 <account-id>.dkr.ecr.ap-south-1.amazonaws.com/myapp:1.0
docker push <account-id>.dkr.ecr.ap-south-1.amazonaws.com/myapp:1.0
```

---

## Q45. How do you run a private registry?

**Say:** I run the official `registry` image, and keep its data in a volume. For a real setup I need **TLS** and authentication. For a quick lab on localhost, plain HTTP works. A remote plain-HTTP registry must be added to `insecure-registries` in `daemon.json`, and only for a lab.

**Commands:**

```bash
docker run -d -p 5000:5000 --restart always --name registry \
  -v registry_data:/var/lib/registry registry:2

docker tag myapp:1.0 localhost:5000/myapp:1.0
docker push localhost:5000/myapp:1.0
curl http://localhost:5000/v2/_catalog              # list images
docker pull localhost:5000/myapp:1.0
```

---

## Q46. How is Docker used in a CI/CD pipeline?

**Say:** The pipeline **builds the image once**, tests it, scans it, tags it with the Git SHA or build number, and pushes it to the registry. Every environment (staging, production) then uses **the same image**, and only the configuration changes. This is "build once, deploy many". The deploy step pulls the exact tag and starts it, and a rollback is just deploying an older tag. I use layer caching to keep builds fast.

**Commands (a CI script):**

```bash
IMAGE=<dockerhub-user>/myapp
TAG=$(git rev-parse --short HEAD)

docker build -t $IMAGE:$TAG .
trivy image --severity HIGH,CRITICAL --exit-code 1 $IMAGE:$TAG
docker push $IMAGE:$TAG

# on the server (deploy)
docker pull $IMAGE:$TAG
docker rm -f myapp || true
docker run -d --name myapp --restart unless-stopped -p 80:3000 $IMAGE:$TAG
```

---

## Q47. What is a Docker health check? Does Docker restart an unhealthy container?

**Say:** A `HEALTHCHECK` is a command that Docker runs from time to time inside the container to check if the app really works, not just if the process is alive. The status is `starting`, `healthy`, or `unhealthy`. With **plain Docker**, an unhealthy container is only **marked**, and it is **not restarted** automatically. Compose can use it for start order (Q24), and orchestrators like Swarm and Kubernetes can replace unhealthy containers.

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1
```

Use `curl -f` instead of `wget` if the image has curl.

**Commands:**

```bash
docker ps                                           # STATUS shows (healthy) or (unhealthy)
docker inspect -f '{{.State.Health.Status}}' myapp
docker inspect -f '{{json .State.Health}}' myapp    # the last check results
docker run -d --health-cmd "wget -qO- http://localhost:3000/health || exit 1" --health-interval 30s myapp
```

---

# 9. Concept questions

## Q48. Docker vs Docker Swarm vs Kubernetes. Why do we need orchestration?

**Say:** Docker runs containers on **one host**. When I have many containers on many servers, I need an **orchestrator** to schedule them, scale them, restart failed ones (self-healing), do rolling updates, and do service discovery and load balancing. **Docker Swarm** is Docker's built-in orchestrator: simple and quick, but less used now. **Kubernetes** is the industry standard, with many more features, and a bigger learning curve. My approach: Compose for local development and small setups, Kubernetes for production at scale.

**Commands:**

```bash
# Swarm basics
docker swarm init
docker service create --name web --replicas 3 -p 80:80 nginx
docker service ls
docker service scale web=5
docker service update --image nginx:1.27 web        # rolling update
docker swarm leave --force

# Kubernetes equivalent idea
kubectl create deployment web --image=nginx --replicas=3
kubectl scale deployment web --replicas=5
```

---

## Q49. What happens when you run `docker run nginx`? Explain step by step.

**Say:**

1. The Docker **client** sends the request to the **daemon**.
2. The daemon looks for the image **locally**. If it is not there, it **pulls** it from the registry (Docker Hub), layer by layer.
3. It **creates the container**: a writable layer is added on top of the image layers (overlay2).
4. It sets up **namespaces and cgroups** for isolation and limits.
5. It sets up the **network**: a virtual ethernet pair (veth) connects the container to the `docker0` bridge, and it gets an IP address.
6. It **mounts volumes** if there are any.
7. **containerd and runc** start the main process as PID 1 inside the container.
8. Docker connects the output (logs) and returns the container ID.

**Commands:**

```bash
# terminal 1: watch the events
docker events

# terminal 2:
docker run -d --name web -p 8080:80 nginx
docker inspect web | head -50
docker inspect -f '{{.NetworkSettings.IPAddress}}' web
ip addr show docker0                                # the bridge on the host
```

---

## Q50. How do you move images and files around? `save/load` vs `export/import`, and why is `docker commit` not recommended?

**Say:** `docker save` writes an **image** (with all layers, tags, and history) to a tar file, and `docker load` reads it back. I use this to move images to a server **without internet**. `docker export` writes only the **filesystem of a container** (flat, without history or metadata), and `docker import` makes a new image from it. `docker commit` creates an image from a running container's changes. I avoid it, because it is **not repeatable** and nobody knows what was changed. A Dockerfile is the correct way.

**Commands:**

```bash
docker save -o myapp.tar myapp:1.0                  # image -> file
docker load -i myapp.tar                            # file -> image
docker export web > web-fs.tar                      # container filesystem -> file
docker import web-fs.tar web-imported:1.0
docker cp web:/etc/nginx/nginx.conf ./nginx.conf    # copy files out of a container
docker cp ./index.html web:/usr/share/nginx/html/   # copy files in
docker commit web web-snapshot:1.0                  # not recommended for real work
```

---

## Q51. What is copy-on-write and the overlay2 storage driver? Why is data lost when a container is removed?

**Say:** The image layers are **read-only** and shared. Each container gets one thin **writable layer** on top. **Copy-on-write** means that when a container changes a file from an image layer, Docker first **copies** the file up into the writable layer and changes the copy. Deleting a file only hides it. **overlay2** is the storage driver that joins the layers into one view. Because the writable layer is deleted when the container is removed, the data is lost. That is why important data goes into **volumes**. Writing a lot into the writable layer is also slower than using a volume.

**Commands:**

```bash
docker info | grep -i "storage driver"              # overlay2
docker run -it --name cow alpine sh
#   inside: echo "hello" > /new.txt ; rm /etc/hostname-not-real ; exit
docker diff cow                                     # A = added, C = changed, D = deleted
docker inspect -f '{{json .GraphDriver.Data}}' cow  # LowerDir (image), UpperDir (writable layer)
docker rm cow                                       # the writable layer and its data are gone
```

---

# Practice labs for `~/linuxCMD/docker-lab`

Do these once so that the commands feel natural:

1. **Basics:** run nginx with `-p 8080:80`, open `curl localhost:8080`, then use `logs`, `exec`, `inspect`, `stats`, and `docker events` (Q6, Q49).
2. **Dockerfile:** make a small Node app, write the Dockerfile from Q8, build it, and check `docker exec app whoami`. Then make it multi-stage and compare the sizes with `docker images` (Q9, Q10).
3. **Volumes:** start Postgres with a named volume, create a table, remove the container, start a new one with the same volume, and check that the data is still there (Q14, Q15).
4. **Networking:** create `appnet`, run two containers on it, and ping by name. Repeat on the default bridge and see that the name does not work (Q18, Q19).
5. **Compose:** write the API + MongoDB file from Q23. Run `docker compose up -d`, `ps`, `logs`, then `down` (Q23 to Q26).
6. **Break things on purpose and fix them:**
   - wrong command → exit code 127 (Q27)
   - `--memory 100m` with a memory hog → exit code 137 (Q29)
   - an app that exits with code 1 and `--restart always` → restart loop (Q28)
7. **rogue vs throttled:** run the two CPU containers and compare `docker stats` (Q30).
8. **Disk and logs:** run `docker system df`, then `docker system prune`, and set log rotation in `daemon.json` (Q31, Q32).

**Final tip for the interview:** for every Docker problem, say the same order: **check the status and exit code, read the logs, inspect the config, find the cause, fix it, and say how you prevent it** (limits, health checks, log rotation, scanning, and CI checks).
