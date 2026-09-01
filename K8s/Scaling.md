# Kubernetes Assignment - Scaling

## Concept Task: Define Horizontal Pod Autoscaler (HPA)

A Horizontal Pod Autoscaler automatically adjusts the number of Pod replicas in a Deployment (or ReplicaSet/StatefulSet) based on observed load — most commonly CPU or memory utilization, though it can also scale on custom metrics.

Instead of a fixed `replicas: 3` that never changes, HPA continuously watches real usage (via the Metrics Server) and compares it to a target you define — for example, "keep average CPU usage per Pod at 50%." If traffic spikes and CPU usage climbs above that target, HPA increases the replica count to spread the load. When traffic drops, it scales back down, within a min/max range you configure.

This is "horizontal" scaling — adding or removing whole Pods — as opposed to "vertical" scaling, which would mean giving a single Pod more CPU/memory instead. HPA is the mechanism that makes a Deployment's replica count dynamic rather than something a person has to manually change every time load shifts.

**Note**: what this assignment's hands-on task actually demonstrates is *manual* scaling with `kubectl scale` — not HPA itself. Manual scaling is what HPA does automatically, under the hood, on your behalf.

## Hands-on Task: Manually scale the Deployment from 3 replicas to 1

Command used:
```
kubectl scale deployment nginx-deployment --replicas=1
```

Then verify:
```
kubectl get pods
```

Since the Deployment currently has 3 replicas running, this command tells the ReplicaSet (managed by the Deployment) that the new desired state is 1 Pod. The ReplicaSet's reconciliation loop.

Run `kubectl get pods` right after the scale command (or add `-w` to watch it live) to catch the 2 extra Pods in `Terminating` status before they fully disappear.

## Submission
<img width="943" height="414" alt="Screenshot 2026-09-01 152410" src="https://github.com/user-attachments/assets/564886a2-8101-47c3-b86f-66e2e4e7400e" />

