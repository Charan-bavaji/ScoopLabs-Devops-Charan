# AWS Native Monitoring — Assignment

## Detailed Description: AWS Native Monitoring

CloudWatch is AWS's native monitoring and observability service. It
collects metrics (CPU, memory via custom metrics, disk, network, etc.),
logs, and events from AWS resources like EC2, RDS, and Lambda, then lets
you visualize them on dashboards and react to them automatically through
alarms. It's the backbone of "knowing what your infrastructure is doing"
without needing a third-party monitoring stack for basic use cases.

---

## Concept Task: What is a CloudWatch Alarm?

A **CloudWatch Alarm** watches a single metric (or a math expression built
from metrics) over a defined time window and compares it against a
threshold you set. When the metric breaches that threshold for the
configured number of evaluation periods, the alarm changes state and can
trigger an action — commonly:

- Sending a notification via **SNS** (email, SMS, Slack webhook, etc.)
- Triggering an **Auto Scaling** action (scale out/in)
- Stopping, terminating, or rebooting an EC2 instance
- Invoking a **Lambda function** for custom automation

An alarm has three possible states:
- **OK** — metric is within the defined threshold
- **ALARM** — metric has breached the threshold for the required duration
- **INSUFFICIENT_DATA** — not enough data to evaluate yet

**Why it matters:** alarms turn passive metric-watching into active
response. Instead of someone manually staring at a graph, the alarm does
the watching and fires off a reaction the moment a real problem (or
scaling need) shows up.

---

## Hands-on Task: View EC2 Metrics + Build a CPU Utilization Dashboard

**Goal:** confirm metrics are flowing for a running EC2 instance, and
build a basic CloudWatch dashboard visualizing CPU Utilization.

### Steps taken

1. Opened CloudWatch > Metrics, located the running EC2 instance under
   **EC2 > Per-Instance Metrics**, and confirmed `CPUUtilization` data
   was populating.
2. Verified alarm behavior end-to-end by observing a `CPUUtilization > 60`
   alarm (`high-cpu-alarm`) transition from **OK → ALARM** during a load
   test, then back to **OK** once load subsided — confirming metrics,
   thresholds, and evaluation periods were correctly wired.
3. Created a custom **CloudWatch Dashboard**, added a widget for
   `CPUUtilization` on the EC2 instance, and confirmed the graph renders
   with correct percentage scaling and a usable time range.

---

## Submission Requirements
<img width="1903" height="809" alt="Screenshot 2026-09-03 144433" src="https://github.com/user-attachments/assets/273eab3e-b810-4074-8815-ecaae0603c24" />


