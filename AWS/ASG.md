# Auto Scaling in AWS — Assignment

## Detailed Description: Elasticity in Cloud Computing

Elasticity is the ability of a cloud environment to automatically add or remove
compute resources in response to real-time demand. Instead of keeping a fixed
number of servers running at all times (sized for the worst-case peak), an
elastic system grows during busy periods and shrinks during quiet ones. This
keeps applications responsive under load while avoiding the cost of idle,
over-provisioned capacity during normal or low-traffic periods.

In AWS, elasticity is delivered mainly through **Auto Scaling Groups (ASGs)**,
which watch a metric (like CPU utilization) and launch or terminate EC2
instances based on rules you define.

---

## Concept Task: What is an Auto Scaling Launch Template?

A **Launch Template** is a reusable blueprint that tells an Auto Scaling
Group exactly how to create a new EC2 instance when it needs to scale out.
It bundles together everything an instance needs at launch time, including:

- **AMI (Amazon Machine Image)** — the OS/software baseline for the instance
- **Instance type** — e.g. t2.micro, t3.medium
- **Key pair** — for SSH access
- **Security group(s)** — controlling inbound/outbound traffic
- **IAM instance profile** — permissions the instance assumes
- **User data script** — commands that run automatically on first boot
  (e.g. installing a web server, pulling app code)
- **Storage configuration** — EBS volume size/type
- **Networking settings** — subnet placement (usually left to the ASG itself)

The Launch Template can also be **versioned** — you can update it (say, to
point to a newer AMI) without breaking the ASG, since the ASG can be told
which version to use. This is the modern replacement for the older "Launch
Configuration," which is immutable and cannot be edited once created.

**Why it matters:** without a Launch Template, an ASG has no way of knowing
what a new instance should look like. It's the single source of truth the
ASG references every time it decides to scale out.

---

## Hands-on Task: Simple ASG Scale-Out Policy (CPU > 70%)

**Goal:** configure an Auto Scaling Group so that if average CPU utilization
across the group exceeds 70%, one additional instance is launched.

### Steps

1. **Launch Template** — created/confirmed with a valid AMI, instance type,
   key pair, and security group.
2. **Auto Scaling Group** — created using that Launch Template, spread
   across 2+ subnets/AZs, with:
   - Desired capacity: `1`
   - Minimum: `1`
   - Maximum: `3`
3. **CloudWatch Alarm** — created on the ASG's `CPUUtilization` metric:
   - Threshold: **Greater than 70%**
   - Evaluation: 2 consecutive periods of 5 minutes (i.e. sustained high
     load, not a single spike)
4. **Simple Scaling Policy** — attached to the ASG:
   - Trigger: the CloudWatch alarm above
   - Action: **Add 1 instance**
   - Cooldown: 300 seconds (prevents repeated scale-out actions while the
     new instance is still warming up)

### Policy Parameter Descriptions

| Parameter | Value Used | Purpose |
|---|---|---|
| Metric | CPUUtilization (per ASG) | The signal the policy reacts to |
| Threshold | > 60% | The point at which the group is considered under load |
| Evaluation periods | 2 × 5 min | Avoids reacting to brief CPU spikes |
| Scaling adjustment | Add 1 instance | How much capacity is added per trigger |
| Cooldown | 300 sec | Pause before the policy can trigger again, letting the new instance stabilize |
| Min / Max capacity | 1 / 3 | Guardrails so scaling can't run away unbounded |

---

## Submission Requirements


