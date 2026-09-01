# AWS Assignment: Virtual Private Cloud (VPC) Networking

## Detailed Description
A Virtual Private Cloud (VPC) is your own isolated, private network inside AWS. Within it, you create subnets, route tables, and gateways to control how traffic flows in and out of your resources.

---

## Concept Task: Public Subnet vs Private Subnet

**Public Subnet**
- Has a route table entry pointing `0.0.0.0/0` to an **Internet Gateway (IGW)**.
- Resources here (e.g. EC2 instances with a public IP) can be reached directly from the internet.
- Typically used for: load balancers, bastion/jump hosts, NAT gateways, public-facing web servers.

**Private Subnet**
- Has **no direct route** to an Internet Gateway.
- Resources here cannot be reached from the internet, and cannot reach the internet directly either.
- If outbound internet access is needed (e.g. for updates), traffic is routed through a **NAT Gateway** sitting in a public subnet — this allows outbound-only access, no inbound connections from the internet.
- Typically used for: databases, application/backend servers, internal services.

**Key difference (one line)**
A public subnet's route table sends internet traffic to an Internet Gateway; a private subnet's does not — it routes outbound traffic (if any) through a NAT Gateway instead.

**Why it matters (least privilege applied to networking)**
Keeping databases and backend servers in a private subnet means they're never directly exposed to the internet, even if someone misconfigures a security group — the network layer itself blocks inbound access.

---

## Hands-on Task: Architecture List — IGW → VPC → Public Subnet

**Components**

1. **VPC** — e.g. `10.0.0.0/16`
2. **Internet Gateway (IGW)** — attached to the VPC, provides the path in/out to the internet
3. **Public Subnet** — e.g. `10.0.1.0/24`, inside the VPC
4. **Route Table (Public)** — associated with the public subnet
   - Local route: `10.0.0.0/16` → `local`
   - Internet route: `0.0.0.0/0` → `Internet Gateway`
5. **EC2 Instance** — launched in the public subnet, with a public IP (or Elastic IP) assigned
6. **Security Group** — attached to the EC2 instance, allowing inbound traffic on required ports (e.g. 22 for SSH, 80/443 for web)

**Traffic flow**
```
Internet
   │
   ▼
Internet Gateway (IGW)
   │
   ▼
VPC (10.0.0.0/16)
   │
   ▼
Public Route Table  (0.0.0.0/0 → IGW)
   │
   ▼
Public Subnet (10.0.1.0/24)
   │
   ▼
EC2 Instance (public IP + Security Group)
```

---

## Submission Requirements
- The diagram or text-based architecture list above, showing IGW → VPC → Public Subnet routing.
