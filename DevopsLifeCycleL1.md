# DevOps Lifecycle — L1 Assignment

---

## Concept Task: The 8 Stages of DevOps Lifecycle

| Stage | Definition |
|-------|------------|
| **1. Plan** | Define what to build — gather requirements, create user stories, and prioritize tasks using tools like Jira. |
| **2. Code** | Developers write the application code and push it to a version control system like Git/GitHub. |
| **3. Build** | The committed code is compiled and packaged into a deployable artifact (e.g., a JAR file using Maven). |
| **4. Test** | Automated tests run against the build to catch bugs before they reach production. |
| **5. Release** | The tested build is approved and versioned, ready to be pushed to the deployment pipeline. |
| **6. Deploy** | The release is automatically pushed to the target environment (staging or production) via CI/CD tools like Jenkins. |
| **7. Operate** | The running application is managed — scaling, configuration, and uptime are handled by the ops team or automation. |
| **8. Monitor** | Application performance, errors, and infrastructure health are tracked using tools like Prometheus and Grafana. |

> **Key idea:** After Monitor, insights feed back into Plan — making it a continuous loop, never a one-time process.

---

## Hands-on Task: Infinity Loop Diagram

<img width="1303" height="631" alt="image" src="https://github.com/user-attachments/assets/c6b0cbe3-a6c9-4d21-936b-16e675686089" />


---

## One-Sentence Descriptions (per stage)

1. **Plan** — Decide *what* to build by gathering requirements and breaking work into trackable tasks.
2. **Code** — Write and version-control the application source code collaboratively.
3. **Build** — Compile the code into a runnable artifact automatically on every commit.
4. **Test** — Validate the build through automated unit, integration, and regression tests.
5. **Release** — Mark the passing build as production-ready with a version tag.
6. **Deploy** — Push the release to the live environment automatically through a pipeline.
7. **Operate** — Keep the deployed application running smoothly with proper configuration and scaling.
8. **Monitor** — Continuously observe system health and feed insights back to the planning stage.
