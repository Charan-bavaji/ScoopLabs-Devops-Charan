# Docker Assignment 2 — Images and Containers

## Detailed Description
The relationship between blueprints and running instances.

## Concept Task
**Define what a Docker Image is versus a Docker Container.**

**Docker Image**
- A read-only template/blueprint — built in layers, contains the app code, dependencies, runtime, and instructions for what to run
- Stored on disk (or a registry like Docker Hub), immutable — you don't "run" an image directly, you run an instance of it
- Analogy: like a class in programming, or a recipe

**Docker Container**
- A running (or stopped) instance of an image — has its own writable layer on top of the image's read-only layers
- Has state: a process ID, network interfaces, its own filesystem changes
- Analogy: like an object instantiated from a class, or the dish cooked from the recipe

**Summary:** An image is the immutable blueprint; a container is a running instance of that image with its own writable layer — multiple containers can be spun up from the same image, each isolated from the other.

## Hands-on Task
Pulled the official nginx image from Docker Hub and started a container using it in detached mode.

### Commands
```bash
# Pull the official nginx image
docker pull nginx

# Run it in detached mode, map port 8080 on host to 80 in container
docker run -d --name my-nginx -p 8080:80 nginx

# Verify the image is present
docker images

# Verify the container is running
docker ps
```

Verified by browsing to `http://localhost:8080` and seeing the Nginx welcome page.

<img width="1920" height="1080" alt="Screenshot (38)" src="https://github.com/user-attachments/assets/59c96864-a06e-451c-85e8-854836a62c1d" />
