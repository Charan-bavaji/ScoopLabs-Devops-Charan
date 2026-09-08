# RCA: Private Subnet EC2 Instance Cannot Reach the Internet

## Summary

A junior engineer deployed an EC2 instance into a private subnet for security purposes. The instance could not run `sudo yum update` or reach any external host — commands hung and eventually timed out. This document walks through recreating the issue, the root cause analysis, the fix, and verification.

## Environment

| Resource | Details |
|---|---|
| VPC | `RCA-VPC` (10.0.0.0/16) |
| Public Subnet | `Rca-public` — ap-south-1a |
| Private Subnet | `Rca-Private` — ap-south-1c |
| Bastion Host | `RCA-Public-Server` (public IP, in Rca-public) |
| Private Instance | `RCA-Private-Server` (no public IP, in Rca-Private) |
| Internet Gateway | `charan-igw` |
| NAT Gateway | `RCA-Nat` (placed in Rca-public, with an Elastic IP) |

## Step 1: Recreating the Broken Architecture

- Created a VPC with a public subnet (`Rca-public`) and a private subnet (`Rca-Private`).
- Attached an Internet Gateway (`charan-igw`) to the VPC.
- Launched `RCA-Public-Server` (bastion) in the public subnet with a public IP.
- Launched `RCA-Private-Server` in the private subnet with **no public IP**.
- SSH'd into the bastion, then attempted to SSH into the private instance and run `ping google.com`.

**Result:** The ping hung indefinitely with no replies — confirming the broken state.

**Screenshot:** `screenshots/ping-before-fix.png`

## Step 2: Architectural Analysis

### Root Cause #1 (intended lab scenario): Missing NAT Gateway

The private subnet's route table only had the default `local` route — no route to `0.0.0.0/0`. Private instances (no public IP) cannot use an Internet Gateway directly, because an IGW only enables two-way routing for resources that have a public IP. To reach the internet outbound while remaining unreachable from it, a private subnet needs a **NAT Gateway** placed in a public subnet to proxy that traffic.

### Root Cause #2 (encountered during setup): Public subnet wired to the wrong route table

While reproducing the scenario, `Rca-public` was found to be associated with `Private-RT` instead of `Public-RT`, despite its name. A subnet's public/private status is determined entirely by its route table association, not its name — so this subnet had no path to the IGW even though it was intended to be public. This was caught via the "Instance is not in public subnet" warning from EC2 Instance Connect and confirmed on the VPC resource map.

**Fix:** Re-associated `Rca-public` with `Public-RT` (which has a `0.0.0.0/0 → charan-igw` route).

### Root Cause #3 (encountered during setup): Bastion outbound rule missing

The bastion's Security Group was missing an outbound rule, which blocked it from forwarding SSH traffic on to the private instance, making the connection attempt hang in a way that looked identical to a routing failure. Restoring the bastion's outbound rule (allow all outbound) resolved this.

## Step 3: Implementing the Fix

1. Created a NAT Gateway (`RCA-Nat`) in the **public subnet** (`Rca-public`), with a newly allocated Elastic IP.
2. Edited the private subnet's route table (`Private-RT`) to add a route: `0.0.0.0/0 → RCA-Nat`.
3. Corrected the `Rca-public` subnet's route table association to `Public-RT`.
4. Restored the bastion's Security Group outbound rule to allow all outbound traffic.

**Screenshot:** `screenshots/nat-gateway-created.png`
**Screenshot:** `screenshots/private-rt-nat-route.png`

## Step 4: Verification

SSH'd from the bastion into the private instance (`10.0.1.94`) and ran:

```bash
ping google.com
```

**Result:** Successful replies from Google's servers, confirming outbound internet access now works via the NAT Gateway.

**Screenshot:** `screenshots/ping-after-fix.png`

## Why NAT Gateways (Not IGWs) for Private Subnets

| | Internet Gateway (IGW) | NAT Gateway |
|---|---|---|
| Direction | Two-way (inbound + outbound) | Outbound only |
| Requires public IP on instance | Yes | No |
| Exposes instance to inbound internet traffic | Yes | No |
| Use case | Public-facing resources (web servers, bastions) | Private resources needing outbound access only (updates, API calls) |

An IGW performs 1:1 NAT between a public IP and the instance's private IP in both directions — meaning the instance is directly reachable from the internet, which defeats the purpose of placing it in a private subnet. A NAT Gateway instead performs **source NAT** for outbound traffic only: it translates the private instance's IP to its own Elastic IP for outgoing requests, and only allows the corresponding return traffic back in. There is no way to *initiate* a connection into the private instance from the internet through a NAT Gateway — preserving the subnet's isolation while still allowing it to fetch OS updates, packages, or call external APIs.

## Conclusion

The instance's original inability to reach the internet was correctly diagnosed as a missing NAT Gateway — the expected root cause for this scenario. Two additional issues (a misconfigured subnet association and a missing bastion outbound rule) were found and resolved along the way, both are documented above since they produced similar symptoms and are common real-world misconfigurations worth recognizing.
