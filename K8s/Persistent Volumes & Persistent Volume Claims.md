# Kubernetes Assignment - Persistent Volumes & Persistent Volume Claims

## Concept Task: Relationship between a PV and a PVC

Containers have a temporary filesystem — any data written inside a container disappears if the Pod is restarted or replaced. A PersistentVolume and PersistentVolumeClaim exist to give Pods real, durable storage that survives beyond a single Pod's lifetime.

**PersistentVolume (PV)**: an actual piece of storage available to the cluster — this could be a disk on a node, or in the cloud, something like an AWS EBS volume. A PV exists independently of any specific Pod; it's a cluster-level resource, provisioned either manually by an admin or automatically.

**PersistentVolumeClaim (PVC)**: a request for storage made by a user or a Pod. A PVC says "I need X amount of storage, with these access requirements" — it doesn't know or care exactly which physical disk it gets, only that its requirements are met.

**The relationship**: a PVC is bound to a matching PV. Kubernetes looks for a PV that satisfies the PVC's request (enough capacity, compatible access mode) and binds the two together. Once bound, that PV is reserved exclusively for that PVC — no other PVC can claim it. A Pod then references the PVC (not the PV directly) in its spec, and mounts that storage as a volume.

This separation exists so that Pods (and the people writing Pod specs) don't need to know the low-level details of the underlying storage — they just ask for what they need via a PVC, and Kubernetes handles matching it to real storage. In most modern clusters, this matching happens automatically and dynamically: a **StorageClass** tells Kubernetes how to create a new PV on demand whenever a PVC requests storage that no existing PV can satisfy, rather than requiring an admin to pre-create PVs manually.

**In short**: PV = the actual storage that exists. PVC = a request for storage. Kubernetes binds a PVC to a matching PV, and a Pod uses the PVC to access that storage without needing to know the underlying details.

## Hands-on Task: PVC requesting 1GB of storage

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: qa-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

Apply it:
```
kubectl apply -f pvc.yaml
kubectl get pvc
```

The `STATUS` column should show `Bound` shortly after applying — meaning the cluster's default StorageClass automatically provisioned a matching PersistentVolume and bound it to this claim, with no manual PV creation needed.

## Submission
<img width="1918" height="327" alt="Screenshot 2026-09-01 153450" src="https://github.com/user-attachments/assets/9d40b778-7df4-4706-8bc4-3773a34fc4eb" />

