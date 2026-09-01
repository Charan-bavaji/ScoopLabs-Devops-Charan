# Kubernetes Assignment - Deployments

## Concept Task: How does a Deployment differ from just running a Pod?

A bare Pod has no controller watching over it. If it crashes or gets deleted, nothing replaces it — it's just gone. 

A Deployment fixes this by creating and managing a **ReplicaSet**, which is the actual component responsible for keeping a fixed number of identical Pods running at all times. The ReplicaSet constantly compares "how many Pods should exist" against "how many actually exist," and creates or deletes Pods to close any gap. Delete a Pod that's managed by a Deployment, and a replacement appears within seconds — I verified this too, in Phase 2.

On top of what a ReplicaSet alone does, a Deployment adds:
- **Rolling updates**: when the Pod image or spec changes, it replaces Pods gradually (a few at a time), so the app never goes fully down during an update.
- **Rollback**: it keeps a revision history, so a bad rollout can be reverted to the previous working version with one command.

**The real chain**: Deployment → manages a ReplicaSet → which manages the Pods. You almost never create a ReplicaSet directly — you create a Deployment, and it creates the ReplicaSet and Pods underneath automatically.

**In short**: a bare Pod is a one-time, unmanaged unit. A Deployment turns that into a self-healing, safely-updatable, scalable set of identical Pods.

## Hands-on Task: deployment.yaml with 3 replicas

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-demo
  template:
    metadata:
      labels:
        app: nginx-demo
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
```

Apply it:
```
kubectl apply -f deployment.yaml
kubectl get deployments
```

## Submission


