# Kubernetes Assignment - Pods

## Concept Task: Why Kubernetes schedules Pods instead of individual containers

Kubernetes doesn't schedule containers directly — it schedules Pods, which are a wrapper around one or more containers. A few reasons this matters:

1. **Shared context for tightly coupled containers**: Sometimes an app needs a helper container running alongside the main one — for example, a log-shipping sidecar next to a web server. Containers in the same Pod share the same network namespace (same IP, can talk via `localhost`) and can share storage volumes. If Kubernetes scheduled containers individually, there would be no clean way to guarantee two related containers always land on the same node together with shared networking.

2. **Atomic unit of scheduling**: A Pod is scheduled to a node as one unit. All containers in it start together, live together, and get replaced together. This makes scaling simple and predictable — "3 replicas" means 3 identical Pods, not some confusing partial mix of containers.

3. **Consistent lifecycle management**: Health checks (probes), resource limits, restart policies, and networking are all defined at the Pod level. This gives Kubernetes one clear unit to monitor and heal, instead of tracking many independent containers with unclear relationships to each other.

**In short**: most real Pods only ever run one container, but Kubernetes still wraps every container in a Pod so it has a consistent, shared-context unit to schedule, network, and manage — with room to add a tightly-coupled helper container later without changing the model.

## Hands-on Task: Nginx Pod YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx-basic
spec:
  containers:
    - name: nginx
      image: nginx:1.25
      ports:
        - containerPort: 80
```

Apply it:
```
kubectl apply -f pod.yaml
kubectl get pods
```

## Submission

