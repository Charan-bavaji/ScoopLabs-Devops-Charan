# Kubernetes Assignment - Namespaces

## Concept Task: Why are namespaces useful in a multi-tenant environment?

A namespace is a way to logically divide a single Kubernetes cluster into separate virtual sections. Resources inside one namespace are isolated from resources in another, even though they're all running on the same physical cluster.

In a multi-tenant environment (multiple teams, or multiple environments like dev/staging/prod, sharing one cluster), namespaces are useful for several reasons:

1. **Name collisions avoided**: Two teams can each deploy a resource named `nginx-deployment` without conflict, as long as they're in different namespaces. Resource names only need to be unique within a namespace, not across the whole cluster.

2. **Access control boundaries**: RBAC (Role-Based Access Control) can be scoped to a namespace — a team can be given permissions only within their own namespace, without being able to see or modify another team's resources.

3. **Resource quotas**: Limits on CPU, memory, or object counts can be applied per namespace, preventing one team or environment from consuming all the cluster's resources and starving the others.

4. **Organizational clarity**: Grouping related resources together (e.g. everything for a `qa` environment) makes the cluster easier to reason about, especially as the number of deployed objects grows.

Kubernetes already uses this pattern internally — the `kube-system` namespace keeps all control plane and system components separate from the `default` namespace where user workloads normally run, so they don't get mixed together or accidentally modified.

**In short**: namespaces let multiple teams or environments safely share one physical cluster, with clear boundaries for naming, access, and resource usage.

## Hands-on Task: Create the qa-env namespace and deploy a pod into it

Create the namespace:
```
kubectl create namespace qa-env
```

Deploy a pod strictly within it — either imperatively:
```
kubectl run nginx-qa --image=nginx:1.25 -n qa-env
```

Or declaratively, with `namespace: qa-env` set in the manifest:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-qa
  namespace: qa-env
spec:
  containers:
    - name: nginx
      image: nginx:1.25
      ports:
        - containerPort: 80
```
```
kubectl apply -f pod.yaml
```

Verify it landed in the correct namespace (and nowhere else):
```
kubectl get pods -n qa-env
kubectl get pods
```
The second command (no `-n` flag, defaults to the `default` namespace) should NOT show `nginx-qa` — confirming the pod is strictly isolated to `qa-env`.

## Submission
<img width="953" height="678" alt="Screenshot 2026-09-01 153136" src="https://github.com/user-attachments/assets/12d19d0e-d477-4972-b1d4-0feac2fc08a5" />

