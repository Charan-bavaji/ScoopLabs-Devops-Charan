# Jenkins Pipeline Creation - L2

## Objective
Write a Declarative Jenkins Pipeline for a simple Node.js application that automatically checks out code, installs dependencies, runs unit tests, builds, and archives artifacts.

## Repository
[`NodeJsApp`](https://github.com/Charan-bavaji/NodeJsApp) — minimal Node.js app with a Mocha/Chai test suite.

## Pipeline Stages
1. **Checkout** — pulls code from GitHub via `checkout scm`
2. **Install Dependencies** — `npm install`
3. **Run Tests** — `npm test`
4. **Build** — `npm run build`
5. **Post → Archive Artifacts** — archives `dist/**/*` on success, excluding `node_modules`

## Issues Faced & Resolutions

### Issue 1: `npm: not found` on a containerized Jenkins
Initially ran Jenkins as a Docker container (`jenkins/jenkins:lts` image). The official Jenkins image only ships Java + git — no Node.js. The `Install Dependencies` stage failed immediately with:
```
npm: not found
```
**Fix attempt:** Installed the Jenkins **NodeJS plugin** and configured a NodeJS tool installation to auto-download Node into the job's workspace, avoiding the need to bake Node into the container image.

### Issue 2: `libatomic.so.1: cannot open shared object file` after installing Node via the plugin
With the NodeJS plugin auto-installing the latest Node (v26.x), the pipeline failed at `npm install` with:
```
node: error while loading shared libraries: libatomic.so.1: cannot open shared object file: No such file or directory
```
Root cause: the Jenkins container's base image (minimal Debian) was missing system libraries that the prebuilt Node v26 binary depends on. This is not a Docker-specific bug — it's the tradeoff of using a stripped-down container base image versus a full OS install; a native Linux install typically has these libraries present already.

**Decision:** Rather than patching the container image (`apt-get install libatomic1` inside the container, or maintaining a custom Dockerfile), switched to running Jenkins natively via `jenkins.war` on a local WSL (Ubuntu) environment. This matches this assignment's scope better — the goal is to demonstrate pipeline mechanics, not debug container base-image library gaps — and keeps the more interesting container-specific issues (like the Docker socket permission problem) for the assignment that's actually about that.

### Issue 3: Java version mismatch running `jenkins.war` locally
```
Running with Java 17 from /usr/lib/jvm/java-17-openjdk-amd64, which is older than the minimum required version (Java 21).
Supported Java versions are: [21, 25]
```
**Fix:** Installed OpenJDK 21 (`sudo apt install -y openjdk-21-jdk`) and re-ran `java -jar jenkins.war --httpPort=8080`.

### Issue 4: Node tool version pinning
After switching to the local Jenkins, configured a fresh **NodeJS installation** (Manage Jenkins → Tools → NodeJS installations) named `NodeJS-20`, pinned to a Node 20.x LTS release instead of the latest major version, to avoid repeating the shared-library issue from Issue 2. Jenkinsfile references this tool via:
```groovy
tools {
    nodejs 'NodeJS-20'
}
```

## Result
Pipeline runs end-to-end successfully: Checkout → Install Dependencies → Run Tests → Build → Archive Artifacts, with a green build in Blue Ocean.

