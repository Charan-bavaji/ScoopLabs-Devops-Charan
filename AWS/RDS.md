# Relational Database Service (RDS) — Assignment

## Detailed Description: Relational Database Service

Amazon RDS is a **managed relational database service** that handles the
operational overhead of running a database — provisioning, patching, backups,
failover, and scaling — so you can focus on your schema and queries instead
of server administration. It supports engines like MySQL, PostgreSQL,
MariaDB, SQL Server, and Oracle, and forms the standard "durable data layer"
behind most cloud applications, sitting alongside EC2 (compute) and S3
(object storage).

---

## Concept Task: Why use Managed RDS instead of installing MySQL directly on an EC2 instance?

Running MySQL yourself on an EC2 instance means you own every layer: OS
patching, MySQL version upgrades, backup scheduling, replication setup,
failover logic, and security hardening. RDS takes most of that off your
plate:

| Concern | Self-managed MySQL on EC2 | Managed RDS |
|---|---|---|
| OS & DB patching | Manual, your responsibility | Automated maintenance windows |
| Backups | You script and schedule them | Automated daily snapshots + point-in-time recovery |
| High availability | You build Multi-AZ/replication yourself | One checkbox: Multi-AZ deployment |
| Scaling storage/compute | Manual resize, possible downtime | Few clicks, often with minimal downtime |
| Monitoring | You wire up CloudWatch yourself | Built-in RDS metrics (CPU, connections, storage, IOPS) |
| Security patching | You track and apply CVEs | AWS handles engine-level patches |
| Time to production | Slower — install, configure, tune | Faster — instance is ready to connect to in minutes |

**The trade-off:** RDS costs more per hour than a bare EC2 instance of
similar size, and you give up root/OS-level access to the database server
(no SSH into the DB host itself). For most production workloads, the
reduction in operational burden and risk outweighs that cost — which is why
RDS is the default choice unless there's a specific reason to self-host
(e.g. needing an unsupported engine version, custom OS-level tuning, or
extreme cost sensitivity at scale).

---

## Hands-on Task: Provision a Free-Tier MySQL RDS Instance

**Goal:** stand up a MySQL database using RDS's free-tier template and
record the connection endpoint.

### Steps taken

1. Opened RDS > Create database, chose **Standard create**.
2. Engine: **MySQL**, Template: **Free tier**.
3. Set DB instance identifier, master username, and master password.
4. Left instance class and storage at the free-tier defaults
   (db.t3.micro / db.t4g.micro, 20 GiB).
5. Configured connectivity: selected VPC, set Public access as appropriate,
   and restricted the security group to allow inbound **port 3306** only
   from the application/EC2 security group (not open to the internet).
6. Created the database and waited for status to move from
   **Creating → Available**.
7. Copied the **Endpoint URL** from the Connectivity & security tab:

   ```
   <db-identifier>.xxxxxxxxxx.<region>.rds.amazonaws.com
   ```

   (This endpoint plus port 3306 is what an application or EC2 instance
   uses to connect via a MySQL client.)

---

## Submission Requirements


