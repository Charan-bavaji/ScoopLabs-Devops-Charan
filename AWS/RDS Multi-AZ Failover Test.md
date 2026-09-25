# RCA Report: RDS Multi-AZ Failover Test

**DB Instance:** `ha-multiaz-db`
**Engine:** MySQL
**Region:** ap-south-1 (Mumbai)
**Configuration:** Multi-AZ DB instance (Primary + Standby, 2 instances)

## 1. Objective
Verify that the RDS database survives a simulated total AZ outage with minimal Recovery Time Objective (RTO), and that the application reconnects **without changing the connection string**, by triggering a manual failover and observing AWS's automatic DNS-based recovery.

## 2. Architecture



- A **Primary** instance in `ap-south-1a` handles all reads/writes.
- A **Standby** instance in `ap-south-1b` receives **synchronous replication** from the Primary at all times, but has **no endpoint of its own** — it cannot be queried directly and exists purely as a hot spare.
- The application/client never talks to either instance directly. It connects to a single **DNS endpoint** (`ha-multiaz-db.cnwcumo2et8s.ap-south-1.rds.amazonaws.com`). AWS controls what that DNS name resolves to behind the scenes.

## 3. Test Procedure
1. Connected to the DB via `mysql` CLI using the endpoint above and wrote a test row into a `ha_test` table.
2. From the RDS Console: **Actions → Reboot → checked "Reboot with failover?" → confirmed.**
3. Immediately re-ran `SELECT * FROM ha_test;` in a loop to observe the exact moment the connection dropped and recovered.

## 4. Observed Behavior

**Client-side (mysql CLI):**
```
ERROR 2013 (HY000): Lost connection to MySQL server during query
No connection. Trying to reconnect...
ERROR 2003 (HY000): Can't connect to MySQL server on 'ha-multiaz-db.....rds.amazonaws.com:3306' (111)
...
No connection. Trying to reconnect...
Connection id:    8
Current database: testdb
+----+----------------------+---------------------+
| id | message              | created_at          |
+----+----------------------+---------------------+
|  1 | before failover test | 2026-09-24 07:05:22 |
+----+----------------------+---------------------+
```
The client reconnected **using the exact same endpoint URL** — no code or config change — and the previously inserted row (`before failover test`) was intact, confirming the standby was promoted with the data already in sync.

**RDS Event Log (see `screenshots/event-log.png`):**
| Time (IST) | Event |
|---|---|
| 12:37 | The user requested a failover of the DB instance. |
| 12:37 | Multi-AZ instance failover started. |
| 12:37 | DB instance restarted |
| 12:37 | Multi-AZ instance failover completed |

## 5. RTO Calculation

AWS's console event log only records timestamps at **minute-level granularity**, so "started" and "completed" both show `12:37` — the log alone cannot show sub-minute duration.

The more accurate measurement is the **client-observed downtime**: the connection was unavailable for approximately **1 minute 27 seconds** between the first failed query and the first successful reconnect.

**Observed RTO ≈ 1 min 27 sec**, which falls within AWS's typical documented Multi-AZ failover window of 60–120 seconds.

## 6. The DNS Swap Explained
RDS Multi-AZ does not use a load balancer or a virtual IP. Instead, the DB endpoint is a **CNAME record** that AWS manages internally. During normal operation, that CNAME resolves to the Primary's underlying IP. When a failover is triggered (manually, or automatically after a real AZ/hardware failure):
1. The Standby is promoted to become the new Primary.
2. AWS updates the CNAME record's target to the (former) Standby's IP.
3. Any client that does a fresh DNS lookup — which is what happens on reconnect after a dropped connection — is transparently routed to the new Primary.

This is why the application/client never needs to know or care which physical instance is "active" — it only ever needs the one stable endpoint.

## 7. Conclusion
The Multi-AZ configuration met the objective: the database survived a full instance failover with an observed RTO of ~1m27s and zero manual intervention on the client/connection-string side. This satisfies the management requirement for automatic recovery from a data-center-level outage with minimal downtime.

## Submission Contents

