# AWS Assignment: Load Balancer - L1

## Detailed Description
A Load Balancer distributes incoming traffic across multiple targets (like EC2 instances) so no single server gets overwhelmed, and traffic keeps flowing even if one target fails.

---

## Concept Task: ALB vs NLB

**Application Load Balancer (ALB)**
- Operates at **Layer 7** (application layer — HTTP/HTTPS)
- Understands the content of requests: can route based on URL path, hostname, headers, etc.
- Good for: web applications, microservices, container-based apps needing smart routing (e.g. `/api` → one target group, `/images` → another)
- Supports host-based and path-based routing, redirects, and fixed responses

**Network Load Balancer (NLB)**
- Operates at **Layer 4** (transport layer — TCP/UDP)
- Just forwards traffic based on IP and port, no inspection of request content
- Handles extremely high throughput with ultra-low latency
- Good for: performance-critical apps, gaming, IoT, or when you need a static IP for the load balancer

**Key difference (one line)**
ALB is "smart" and content-aware (routes based on what's in the request), NLB is "fast" and just forwards raw TCP/UDP traffic without looking inside it.

**Quick comparison table**

| Feature | ALB | NLB |
|---|---|---|
| OSI Layer | 7 (Application) | 4 (Transport) |
| Protocol | HTTP/HTTPS | TCP/UDP/TLS |
| Routing | Path/host/header-based | IP + port only |
| Speed | Slightly slower (inspects requests) | Extremely fast, low latency |
| Static IP | No (uses DNS) | Yes (per subnet) |
| Use case | Web apps, microservices | High-performance, low-latency apps |

---

## Hands-on Task: Create a Target Group (Port 80)

**Goal:** Create a Target Group intended to hold web servers running on port 80.

### Steps
1. Go to the **EC2 Console** → **Target Groups** (under Load Balancing) → **Create target group**.
2. Choose target type: **Instances** (or IP addresses / Lambda, depending on your setup — instances is standard for EC2 web servers).
3. Enter a name, e.g. `web-servers-tg`.
4. Set **Protocol: HTTP**, **Port: 80**.
5. Select the **VPC** your web servers are running in.
6. Configure the health check:
   - Protocol: HTTP
   - Path: `/` (or a specific health check endpoint if your app has one)
7. Click **Next**, then register your EC2 instances (web servers) as targets on port 80.
8. Click **Create target group**.
9. Confirm the target group appears in the console with your instances listed as healthy targets.

---

## Submission Requirements
- Screenshot of the created Target Group in the AWS console, showing:
  - Target group name
  - Protocol/Port (HTTP : 80)
  - Registered targets and their health status
  <img width="1917" height="833" alt="Screenshot 2026-08-14 120958" src="https://github.com/user-attachments/assets/81a888e4-dd77-4298-8ee0-f6ca214d204d" />

