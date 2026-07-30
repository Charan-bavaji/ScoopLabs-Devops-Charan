# Task 3: Automating the Start of a Pipeline

## Detailed Description
Automating the start of a pipeline — configured a Jenkins job to trigger builds automatically on a schedule.

## Concept Task

**Explain the difference between "Poll SCM" and a "GitHub Webhook".**

Both are ways to trigger a Jenkins build automatically when code changes, but they work very differently:

**Poll SCM (pull-based):**
- Jenkins periodically checks the repository on a cron-style schedule (e.g. `H/5 * * * *` = every ~5 minutes) to see if there are new commits.
- If changes are found, it triggers a build; if not, the poll does nothing.
- **Downsides:** wastes resources checking even when nothing changed, and introduces delay — a change might not be picked up until the next poll interval (so it's never truly "instant").
- Useful when Jenkins isn't reachable from the outside world (no public IP/webhook access), e.g. in a locked-down internal network.

**GitHub Webhook (push-based):**
- GitHub itself notifies Jenkins the instant a push happens, by sending an HTTP POST to a Jenkins endpoint.
- Jenkins triggers the build immediately — no polling delay, no wasted checks.
- **Requires** Jenkins to be reachable from GitHub (a public URL or a tunnel like ngrok for local setups), and a webhook configured in the GitHub repo settings pointing at Jenkins.
- Far more efficient and near-real-time compared to polling.

**In short:** Poll SCM = Jenkins repeatedly asks "did anything change?" on a timer. Webhook = GitHub proactively tells Jenkins "something changed, right now." Webhooks are the preferred approach whenever Jenkins is network-accessible; Poll SCM is the fallback when it isn't.

## Hands-on Task
- Opened the job's **Configure** page.
- Under **Build Triggers**, enabled **Build periodically**.
- Set the schedule using cron syntax to run every hour:
  ```
  H * * * *
  ```
- Saved the configuration and confirmed the job triggered automatically on schedule.

## Submission
Screenshot of the configured Build Trigger section:

<img width="1920" height="1080" alt="Screenshot (23)" src="https://github.com/user-attachments/assets/b7f88ae8-1474-4dfd-a6df-6fa097640fc6" />



Screenshot of the corresponding build history:

<img width="1917" height="1020" alt="Screenshot 2026-07-28 121027" src="https://github.com/user-attachments/assets/61ecd431-122c-4948-8845-8dad8cc15044" />


