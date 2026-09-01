# Kubernetes Assignment - Architecture (L1)

## Concept Task: Roles of Kube-API Server, ETCD, Kubelet, and Kube-Proxy

**Kube-API Server**
The API server is the single entry point into the cluster. Every command — `kubectl`, dashboards, CI/CD pipelines, other internal components — goes through it. It validates requests, then reads from and writes to etcd on their behalf. No other component talks to etcd directly.

**ETCD**
A distributed key-value store that holds the entire cluster's state — every object's desired configuration and current status. It is effectively the cluster's memory. If etcd is lost or corrupted, the cluster loses track of everything it was managing.

**Kubelet**
An agent that runs on every worker node. It watches the API server for pods assigned to its own node, then makes sure those pods are actually running — pulling images, starting/stopping containers via the container runtime, and reporting node/pod health back to the API server.

**Kube-Proxy**
Runs on every node and handles networking for Services. It watches the API server for Services and their matching pod endpoints, then sets up networking rules (iptables/IPVS) so traffic sent to a Service's virtual IP gets correctly routed to a real, healthy pod backing that Service.

**One-line summary**: The API server is the front door, etcd is the memory, the scheduler and controller-manager (control plane) decide what should happen, and kubelet + kube-proxy (on every worker node) make it actually happen.

## Hands-on Task: Install Minikube and start a single-node cluster

Steps taken:

1. Installed `kubectl` via the official binary download, verified with `kubectl version --client`
2. Downloaded and installed Minikube (`minikube-linux-amd64`), verified with `minikube version`
3. Confirmed Docker was running (`docker ps`) since Minikube uses the Docker driver on WSL
4. Started the cluster: `minikube start --driver=docker`
5. Verified the node was ready: `kubectl get nodes`
6. Verified all control plane and system components were running: `kubectl get pods -n kube-system`

## Submission


