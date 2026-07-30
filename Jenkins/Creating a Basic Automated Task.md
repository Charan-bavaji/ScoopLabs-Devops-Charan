# Task 2: Creating a Basic Automated Task

## Detailed Description
Creating a basic automated task — set up a Freestyle job in Jenkins that pulls source code and runs a simple shell step.

## Concept Task

**Describe the limitations of a Freestyle job compared to a Pipeline job.**

Freestyle jobs are Jenkins' original, UI-driven job type — configured by clicking through forms rather than writing code. While simple to set up, they have real limitations compared to Pipeline jobs:

- **No version control for the job config.** Freestyle job settings live only in Jenkins' internal config (config.xml on disk), not as code in your repo. There's no easy diff/history/rollback of "what changed in the job" the way there is with a Jenkinsfile.
- **Limited flow control.** Freestyle can't natively express sequential stages, parallel execution, conditional logic, or retries — you're stuck chaining "build steps" linearly with no real branching logic.
- **No built-in support for complex workflows** like manual approval gates, multi-stage promotion (dev → test → prod), or fan-out/fan-in parallel jobs. These require workarounds (e.g. chaining multiple Freestyle jobs with the "Build other projects" trigger) instead of being expressed directly.
- **Harder to reuse/share logic.** Pipelines support Shared Libraries so common logic (e.g. notification steps, deployment logic) can be reused across many pipelines. Freestyle has no equivalent — you end up copy-pasting config across jobs.
- **No pause/resume or restart-from-stage.** Pipelines can survive a Jenkins restart mid-run and can be restarted from a specific stage. Freestyle jobs simply fail and must be re-run from scratch.
- **Weaker visualization.** Pipelines get stage-view/Blue Ocean visualizations showing exactly where a build is or failed. Freestyle just shows a linear console log.
- **Not "Configuration as Code" friendly.** Freestyle jobs are harder to template, version, and code-review as part of a GitOps-style workflow; Pipelines (as Jenkinsfiles) live in the repo alongside the application code.

In short: Freestyle is fine for quick, simple, one-off automation, but doesn't scale well to real CI/CD workflows with multiple stages, approvals, parallelism, or shared logic — which is exactly what Pipeline jobs are built for.

## Hands-on Task
- Created a new **Freestyle project** in Jenkins.
- Configured **Source Code Management** to clone a public GitHub repository.
- Added a **Build Step → Execute shell** with a simple command:
  ```bash
  echo "Build Started"
  ```
- Ran the job and confirmed it built successfully.

## Submission
Screenshot of the successful Console Output:
<img width="1920" height="1080" alt="Screenshot (22)" src="https://github.com/user-attachments/assets/3158e4c1-165e-45ec-a2ca-d96e5dfb8048" />
