# Docker Assignment 4 — Dockerfile

## Detailed Description
Building custom images.

## Concept Task
**Describe the purpose of the FROM, COPY, and CMD instructions.**

- **FROM** — sets the base image the new image builds on top of (e.g. `python:3.11-slim`). Every Dockerfile starts with this; it pulls in the OS layer + runtime you need instead of building from scratch.
- **COPY** — copies files/directories from the build context (host machine) into the image's filesystem. Used to bring in source code, scripts, or config files.
- **CMD** — specifies the default command that runs when a container starts from the image. Only one CMD takes effect (the last one wins if multiple are present); it can be overridden at `docker run` time by passing a command after the image name.

**Summary:** `FROM` sets the base layer, `COPY` brings application files into the image, and `CMD` defines the default process the container runs — together they turn a generic base image into a custom application image.

## Hands-on Task
Wrote a Dockerfile that takes a base Python image, copies a "Hello World" Python script into it, and runs the script on container start.

### hello.py
```python
print("Hello World from inside a Docker container!")
```

### Dockerfile
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY hello.py .

CMD ["python", "hello.py"]
```

### Build
```bash
docker build -t hello-python .
```

### Run
```bash
docker run hello-python
```

**Expected output:**
```
Hello World from inside a Docker container!
```

## Submission 
- [x] Dockerfile code (above)
- [x] Python script (above)

<img width="1920" height="1080" alt="Screenshot (40)" src="https://github.com/user-attachments/assets/17919fa5-78d6-4f16-939c-c2e6343b84ae" />


## Notes
- `WORKDIR /app` sets the working directory inside the image so `COPY hello.py .` lands at `/app/hello.py`.
- Used `python:3.11-slim` instead of the full `python:3.11` image to keep image size smaller — worth mentioning if asked about image optimization in interviews.
