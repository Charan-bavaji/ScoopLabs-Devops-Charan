# CI Trigger Setup

## Objective
Integrate GitHub with the local Jenkins server using a webhook, so pushing code to the repository automatically triggers the pipeline — true Continuous Integration, without manually clicking "Build Now".

## Repository
[`NodeJsApp`](https://github.com/Charan-bavaji/NodeJsApp)

## Setup

### 1. Expose local Jenkins to the internet via ngrok
Jenkins was running locally on WSL (`http://localhost:8080`), which GitHub cannot reach directly. Used ngrok to create a public HTTPS tunnel:
```bash
ngrok http 8080
```
This produced a public forwarding URL:
```
https://chief-thrill-audience.ngrok-free.dev -> http://localhost:8080
```
Note: ngrok also runs a local inspection dashboard at `http://127.0.0.1:4040` — that's only for viewing/replaying incoming requests locally, and is not the URL to give GitHub.

### 2. Enable the trigger on the Jenkins job
Job → Configure → **Build Triggers** → checked **"GitHub hook trigger for GITScm polling"** → Save.

Pipeline script path was pointed at `Jenkinsfile.webhook`, which includes the pipeline-as-code equivalent of this setting:
```groovy
triggers {
    githubPush()
}
```

### 3. Add the webhook on GitHub
Repo → Settings → Webhooks → Add webhook:
- Payload URL: `https://chief-thrill-audience.ngrok-free.dev/github-webhook/` (trailing slash required)
- Content type: `application/json`
- Events: Just the push event

GitHub sent an initial ping immediately on save — confirmed via a `200` response in the webhook's **Recent Deliveries** tab.

### 4. Live test
Pushed a small commit to the repository and switched to the Jenkins dashboard — the job triggered automatically without manually clicking "Build Now", confirming the webhook → Jenkins integration works end-to-end.

