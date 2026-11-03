---
draft: true
exam_objectives:
  - Debugging
---
# Quotas, Limit Ranges And Node Conditions

Even when nodes have room, an administrator can limit what a namespace may use. A ResourceQuota limits the total in a namespace. A LimitRange sets defaults and bounds for single pods. A node with a bad condition stops accepting or running pods.

<!-- astrona:playground:renew -->

## ResourceQuota

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: small
  namespace: outpost
spec:
  hard:
    pods: "2"
    requests.cpu: "500m"
```

Apply it and read it:

```sh
kubectl apply -f quota.yaml
kubectl -n outpost describe resourcequota small
```

The output lists `Used` and `Hard` for each item. When a Deployment needs more than the quota allows, the Deployment is created and the ReplicaSet cannot create pods. The pods do not exist, so `kubectl get pods` shows fewer than expected. The reason is in the ReplicaSet events:

```sh
kubectl -n outpost get replicaset
kubectl -n outpost describe replicaset REPLICASET_NAME
```

The event reads `forbidden: exceeded quota: small, requested: pods=1, used: pods=2, limited: pods=2`. A quota on `requests.cpu` also makes every pod without a CPU request fail with `must specify requests.cpu`, unless a LimitRange sets a default.

## LimitRange

```sh
kubectl -n outpost get limitrange
kubectl -n outpost describe limitrange
```

A LimitRange gives defaults for requests and limits and sets minimum and maximum values for a container. A pod outside the range is rejected when created, with a message that names the bound. A default limit that is lower than the application needs is a hidden cause of out-of-memory kills.

## Node conditions

```sh
kubectl get nodes
kubectl describe node NODE_NAME
```

In the `Conditions` section, read these entries:

| Condition | Healthy value | If wrong |
| --- | --- | --- |
| `Ready` | `True` | The node cannot run pods; pods are evicted after a delay |
| `MemoryPressure` | `False` | Pods are evicted and new ones are not placed |
| `DiskPressure` | `False` | Image pulls fail and pods are evicted |
| `PIDPressure` | `False` | The node has too many processes |
| `NetworkUnavailable` | `False` | The network plugin is not set up |

A `NotReady` node gets a taint, and pods tolerate it for a default 300 seconds before eviction. Look at the kubelet on the node and at the container runtime when you have node access.

## Cluster dependencies

Pods can also wait on things outside the pod: an admission webhook that rejects or delays creation, a CNI plugin that is not ready, a missing image pull Secret, a registry that is slow. Check `kubectl get events -A --sort-by=.lastTimestamp` for the newest events across namespaces and `kubectl -n kube-system get pods` for the health of system components. A webhook failure shows in the error on `kubectl apply`, with the webhook name.

## Common pitfalls

> [!WARNING]
> Raising a quota is a decision for the owner of the namespace, not a quick fix. Check what uses the quota first with `kubectl describe resourcequota`. Do not cordon, drain or restart a node during an investigation unless you know what runs on it; a drain evicts pods. Events are short-lived, so copy the message you need before it expires.
