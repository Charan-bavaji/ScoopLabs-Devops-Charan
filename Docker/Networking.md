# Docker Assignment 6 — Networking

## Detailed Description
Allowing containers to communicate.

## Concept Task
**Explain the default "bridge" network in Docker.**

When Docker is installed, it creates a default network called `bridge`. Any container started without specifying `--network` connects to it automatically.

- It's a private internal network on the host — containers get their own IP in a subnet (typically `172.17.0.0/16`)
- Containers on the default bridge can reach each other only by IP, not by container name — Docker's embedded DNS resolution doesn't work on the default bridge, only on user-defined bridge networks
- Containers reach the outside world (internet) via NAT through the host
- This is why in practice, a custom/user-defined bridge network is created for multi-container apps — it gives automatic DNS-based service discovery by container name.

**Summary:** The default bridge network lets containers talk to each other by IP and to the outside world via NAT, but it lacks built-in DNS resolution — which is why user-defined bridge networks are preferred, since Docker gives automatic name-based service discovery on those.

## Hands-on Task
Created a custom Docker bridge network, ran two Ubuntu containers on it, and confirmed they could communicate via container name.

### Commands
```bash
# Create a custom bridge network
docker network create my-bridge-net

# Run two Ubuntu containers on that network, keep them alive with sleep
docker run -dit --name ubuntu1 --network my-bridge-net ubuntu sleep infinity
docker run -dit --name ubuntu2 --network my-bridge-net ubuntu sleep infinity

# Install ping utility (not included in base ubuntu image)
docker exec -it ubuntu1 bash -c "apt-get update && apt-get install -y iputils-ping"

# From inside ubuntu1, ping ubuntu2 by container name
docker exec -it ubuntu1 ping -c 4 ubuntu2
```

**Result:** Successful ping replies from `ubuntu2`, confirming DNS-based name resolution works on the custom bridge network — this would fail on the default `bridge` network, which lacks embedded DNS.

## Submission Requirements
- [x] Networking commands used (above)
- [ ] Screenshot of the successful `ping` output from inside `ubuntu1`

## Notes
- The base `ubuntu` image doesn't ship with `ping` — `iputils-ping` needs to be installed manually via `apt-get`.
