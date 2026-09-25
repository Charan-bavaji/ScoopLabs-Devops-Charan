# RCA Report: RDS Multi-AZ Failover — High Availability Validation (L3)

**DB Instance:** `ha-multiaz-db`
**Engine:** MySQL
**Region:** ap-south-1 (Mumbai)
**Configuration:** Multi-AZ DB instance (Primary + Standby, 2 instances)

## 1. Objective
Validate that an RDS database configured for Multi-AZ can survive a simulated total AZ/data-center outage with a minimal Recovery Time Objective (RTO), and that the application reconnects **without any change to its connection string**, by triggering a manual failover and directly observing AWS's DNS-based recovery mechanism.

## 2. Architecture

- A **Primary** instance in `ap-south-1a` handles all reads/writes during normal operation.
- A **Standby** instance in `ap-south-1b` receives **synchronous replication** from the Primary continuously, but exposes **no endpoint of its own** — it cannot be queried directly and exists purely as a hot spare, ready to be promoted instantly.
- The application/client never talks to either instance by IP. It connects to a single stable **DNS endpoint** (`ha-multiaz-db.cnwcumo2et8s.ap-south-1.rds.amazonaws.com`), and AWS controls what that name resolves to behind the scenes.

## 3. Test Procedure
1. Connected to the DB via `mysql` CLI using the endpoint above and wrote a test row into a `ha_test` table, to have verifiable state before the disruption.
2. From the RDS Console: **Actions → Reboot → checked "Reboot with Failover?" → confirmed.**
3. Immediately re-ran `SELECT * FROM ha_test;` in a tight loop to capture the exact moment the connection dropped and the exact moment it recovered.
4. Cross-checked the client-observed timing against the RDS **Logs & Events** tab.

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
The client reconnected **using the exact same endpoint URL** — no code, driver, or config change — and the previously inserted row (`before failover test`) was intact, confirming the standby was promoted with data already fully in sync (zero data loss, consistent with synchronous replication).

**RDS Event Log (see `screenshots/event-log.png`):**
| Time (IST) | Event |
|---|---|
| 12:37 | The user requested a failover of the DB instance. |
| 12:37 | Multi-AZ instance failover started. |
| 12:37 | DB instance restarted |
| 12:37 | Multi-AZ instance failover completed |

## 5. RTO Calculation and Its Limitations

**A note on method:** "Reboot with Failover" is a single combined AWS action — it reboots the instance *and* forces promotion of the standby in the same operation, rather than triggering a "pure" failover with no restart involved. This is intentional for this test: a real disaster (AZ/hardware loss) would also cause a disruptive restart-like event, so this is a realistic worst-case simulation, not an artificially clean one.

**A note on precision:** AWS's console event log only records timestamps at **minute-level granularity**. "Started" and "completed" both show `12:37`, so the log by itself cannot prove sub-minute duration — it only confirms sequence and rough timing, not exact elapsed seconds.

Because of that, the console log's `started` → `completed` window and the more precise **client-observed downtime** are reported together:

| Measurement source | Value | Precision |
|---|---|---|
| RDS event log (started → completed) | Same minute (12:37) | ±60s (minute-level only) |
| Client-side stopwatch (first failed query → first successful reconnect) | **~1 min 27 sec** | Second-level |

**Reported RTO ≈ 1 min 27 sec**, consistent with both the event log window and AWS's documented typical Multi-AZ failover range of 60–120 seconds.

## 6. The DNS Swap Explained
RDS Multi-AZ does not use a load balancer or a virtual/floating IP. Instead, the DB endpoint is a **CNAME record** that AWS manages internally:
1. During normal operation, the CNAME resolves to the Primary's underlying IP.
2. On failover (manual, or automatic after a real AZ/hardware failure), the Standby is promoted to become the new Primary.
3. AWS updates the CNAME record's target to the (former) Standby's IP.
4. Any client that performs a fresh DNS lookup — which naturally happens on reconnect after a dropped TCP connection — is transparently routed to the new Primary, with no application-level awareness required.

This is why the application/client never needs to know or care which physical instance is "active" — it only ever needs the one stable endpoint, and DNS TTL (typically low, ~5s for RDS) is what keeps the re-resolution fast.

## 7. Production Recommendations
- **Connection pooling / retry logic:** application-side connection pools should implement retry-with-backoff on connection errors, since even a well-tuned Multi-AZ failover has a non-zero window (60-120s) where the DB is unreachable.
- **Avoid caching resolved IPs:** any driver or app-level code that caches the resolved IP instead of the hostname will not benefit from the DNS swap and would need a restart to recover — always connect by hostname and respect low TTLs.
- **Monitor, don't assume:** CloudWatch alarms on `FailoverCount` and RDS events (e.g. via EventBridge → SNS) give visibility into unplanned failovers in production, rather than relying on users reporting downtime.
- **Multi-AZ is not a backup strategy:** synchronous replication protects against infrastructure failure, not against application-level mistakes (e.g. an accidental `DROP TABLE`), which replicate to the standby just as fast. Automated snapshots/backups remain necessary alongside Multi-AZ.

## 8. Conclusion
The Multi-AZ configuration met the objective: the database survived a full instance failover (reboot + failover combined) with an observed RTO of ~1m27s, zero data loss, and zero manual intervention on the client/connection-string side. This satisfies the management requirement for automatic recovery from a data-center-level outage with minimal downtime, and the test also surfaced practical caveats (log granularity, DNS TTL dependency, retry-logic importance) worth carrying into a production rollout.

## Submission Contents

