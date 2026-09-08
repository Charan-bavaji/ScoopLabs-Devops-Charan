# AWS Deployment (High Availability) — L2

## Overview

This project demonstrates a highly available web architecture on AWS. Two EC2 instances are deployed in **different Availability Zones**, each running a basic web server. An **Application Load Balancer (ALB)** sits in front of them and distributes incoming traffic across both instances via a **Target Group**, so the application stays online even if one Availability Zone fails.

## Architecture

```
                        Internet
                           |
                  Application Load Balancer
                     (Internet-facing)
                           |
              -------------------------
              |                       |
        Target Group (Port 80, Health Check: /)
              |                       |
      EC2: Web-Server-A       EC2: Web-Server-B
      AZ: us-east-1a          AZ: us-east-1b
      Apache + index.html     Apache + index.html
      "Hello from Server A"   "Hello from Server B"
```

## Steps Performed

### Step 1: Provisioning the Compute Layer

- Launched an EC2 instance in the default VPC, in subnet `us-east-1a`, named **Web-Server-A**.
- Installed Apache and set up `index.html` on the instance:

  ```bash
  sudo yum update -y
  sudo yum install -y httpd
  sudo systemctl start httpd
  sudo systemctl enable httpd
  echo "Hello from Server A" | sudo tee /var/www/html/index.html
  ```

- Launched a second EC2 instance in subnet `us-east-1b`, named **Web-Server-B**, and repeated the same setup with:

  ```bash
  echo "Hello from Server B" | sudo tee /var/www/html/index.html
  ```

### Step 2: Security Group Configuration

- Verified the Security Group attached to both instances allows inbound **HTTP (port 80)** traffic from `0.0.0.0/0`.

### Step 3: Creating the Target Group

- Created a Target Group of type **Instances**, protocol **HTTP**, port **80**.
- Left the health check path as `/`.
- Registered both **Web-Server-A** and **Web-Server-B**.
- Confirmed both instances showed as **Healthy**.

**Screenshot:** `screenshots/target-group-healthy.png`
*(Both instances registered and marked Healthy)*

### Step 4: The Application Load Balancer (ALB)

- Created an **Application Load Balancer**, set to **Internet-facing**.
- Mapped it to the same two Availability Zones (`us-east-1a`, `us-east-1b`) where the EC2 instances live.
- Configured a listener on **port 80** forwarding to the Target Group created in Step 3.
- Waited for the ALB state to become **Active**.

**Screenshot:** `screenshots/alb-active.png`
*(ALB showing state: Active, with DNS name visible)*

### Step 5: Execution and Verification

- Copied the ALB's DNS name (e.g. `my-alb-1234.us-east-1.elb.amazonaws.com`) and opened it in a browser.
- Confirmed the page loads and displays either **"Hello from Server A"** or **"Hello from Server B"**.
- Hard-refreshed the page multiple times and confirmed the response alternates between both servers, proving the ALB is balancing traffic across both Availability Zones.

**Screenshots:**
- `screenshots/server-a-response.png` — "Hello from Server A"
- `screenshots/server-b-response.png` — "Hello from Server B"

## Result

The ALB successfully distributes traffic across two EC2 instances in separate Availability Zones. If one AZ or instance becomes unavailable, the Target Group's health checks would mark it unhealthy and the ALB would route all traffic to the remaining healthy instance — eliminating the single point of failure.

## Tech Stack

- AWS EC2 (Amazon Linux)
- Apache HTTP Server
- AWS Application Load Balancer (ALB)
- AWS Target Groups
- AWS VPC (default) — Multi-AZ subnets
