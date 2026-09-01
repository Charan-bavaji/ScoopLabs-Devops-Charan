# Kubernetes Assignment - Services

## Concept Task: Compare ClusterIP, NodePort, and LoadBalancer

**ClusterIP** (default type)
Gives the Service a stable, internal-only IP, reachable only from inside the cluster. Used for backend-to-backend traffic that should never be exposed externally — e.g. an app talking to its own database. Not reachable from a browser outside the cluster.

**NodePort**
Opens a specific port (in the 30000-32767 range) on every node's own IP address, making the Service reachable from outside the cluster at `<node-ip>:<nodePort>`. Useful for quick testing, but clunky for real production use — you have to know a node's IP and a non-standard port number, and it doesn't scale well across many services.

**LoadBalancer**
Asks the cloud provider (AWS, GCP, etc.) to provision a real external load balancer in front of the Service, with a proper stable public IP/DNS name. This is the standard choice in production on a real cloud cluster like EKS. On a local cluster like Minikube, there's no real cloud to provision one, so it has to be simulated (e.g. `minikube tunnel`).

**Summary table**

| Type | Reachable from | Typical use |
|---|---|---|
| ClusterIP | Inside cluster only | Backend-to-backend traffic |
| NodePort | Outside cluster, via node IP + high port | Quick local/manual testing |
| LoadBalancer | Outside cluster, via a real cloud LB | Production external access |

All three ultimately rely on the same underlying mechanism: `kube-proxy` on each node watches the Service and its matching Pod endpoints, and routes traffic to a real, healthy Pod behind it.

## Hands-on Task: NodePort service for the Nginx Deployment

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  type: NodePort
  selector:
    app: nginx-demo
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

Apply it:
```
kubectl apply -f service.yaml
kubectl get svc
```

Access it in the browser:
```
minikube service nginx-nodeport --url
```
(On Minikube with the Docker driver, this prints a local tunnel URL — e.g. `http://127.0.0.1:32971` — since the node runs inside a Docker container and isn't directly reachable from the host. On a real cluster, this Service would be reachable directly at `<node-ip>:30080`, no tunnel needed.)


## Submission


