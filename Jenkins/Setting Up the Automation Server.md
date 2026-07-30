# Task 1: Setting Up the Automation Server

## Detailed Description
Setting up the automation server — installed Jenkins locally and completed the initial setup wizard.

## Concept Task

**What is a Continuous Integration server, and why is Jenkins popular?**

A Continuous Integration (CI) server is a tool that automatically builds, tests, and validates code every time a change is pushed to a repository. It removes the manual step of "build and test it yourself" and instead runs that process consistently, on every commit, catching integration errors early instead of letting them pile up.

Jenkins is one of the most popular CI servers because:
- **Open-source and free**, with a huge community and long track record (used across the industry for over a decade).
- **Massive plugin ecosystem** — integrates with Git, Docker, Kubernetes, Slack, cloud providers, testing tools, etc.
- **Highly extensible/configurable** — supports both simple jobs and complex, scripted pipelines (Declarative and Scripted Pipeline syntax).
- **Platform-agnostic** — runs on-prem, in containers, or in the cloud, and works with virtually any tech stack.
- **Master-agent architecture** — can distribute builds across multiple agents for scalability.

## Hands-on Task
- Installed Jenkins via [WAR file / Docker — *fill in whichever you used*].
- Started Jenkins and accessed it at `http://localhost:8080`.
- Unlocked Jenkins using the initial admin password from `/var/jenkins_home/secrets/initialAdminPassword` (Docker) or the path shown in the terminal output (WAR).
- Completed the setup wizard:
  - Installed suggested plugins.
  - Created the first admin user.
  - Confirmed the Jenkins URL.

## Submission
Screenshot of the Jenkins dashboard showing the logged-in admin user:
