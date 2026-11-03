---
draft: true
exam_objectives:
  - Debugging
---
# Taints, Tolerations And Node Selection

Placement rules are the second most common reason for a pending pod. A taint on a node repels pods. A toleration on a pod allows it to land on a tainted node. A node selector or affinity limits a pod to certain nodes.

<!-- astrona:playground:renew -->

## Taints

```sh
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
kubectl describe node NODE_NAME | grep -A3 Taints
```

A taint has a key, an optional value and an effect:

| Effect | What it does |
| --- | --- |
| `NoSchedule` | New pods without a toleration are not placed on the node |
| `PreferNoSchedule` | The scheduler avoids the node when it can |
| `NoExecute` | New pods are blocked and running pods without a toleration are evicted |

Control plane nodes usually carry the taint `node-role.kubernetes.io/control-plane:NoSchedule`, which is why ordinary pods do not land there. The cluster adds taints such as `node.kubernetes.io/not-ready` and `node.kubernetes.io/unreachable` to nodes that are unhealthy.

Add a taint to a node to test, replacing `NODE_NAME`:

```sh
kubectl taint nodes NODE_NAME team=blue:NoSchedule
```

On a cluster with one node this blocks new pods. Remove it again with a trailing dash:

```sh
kubectl taint nodes NODE_NAME team=blue:NoSchedule-
```

## Tolerations

A pod tolerates a taint with a matching entry:

```yaml
spec:
  tolerations:
    - key: team
      operator: Equal
      value: blue
      effect: NoSchedule
```

A toleration allows the pod to be placed on the node. It does not require it: the pod can still land on a node without the taint. To pin the pod to tainted nodes, combine the toleration with a node selector or affinity.

## Node selector and affinity

```yaml
spec:
  nodeSelector:
    disktype: ssd
```

The pod is placed only on nodes with the label `disktype=ssd`. If no node has the label, the event says `didn't match Pod's node affinity/selector`. Check labels with `kubectl get nodes --show-labels`. Add a label with `kubectl label node NODE_NAME disktype=ssd`.

Node affinity expresses the same with operators and with preferences:

- `requiredDuringSchedulingIgnoredDuringExecution` is a hard rule.
- `preferredDuringSchedulingIgnoredDuringExecution` is a weighted preference.

Pod anti-affinity spreads replicas across nodes or zones. With a hard rule and fewer nodes than replicas, the extra replicas stay pending. Topology spread constraints do the same with a limit on the difference, and `whenUnsatisfiable: DoNotSchedule` leaves pods pending when the limit cannot be met.

## Common pitfalls

> [!WARNING]
> A taint with `NoExecute` evicts running pods, so adding one to a live node removes workloads from it. Use `NoSchedule` first, or drain the node on purpose. A node selector label that is misspelled looks the same as a missing node. Compare the label key and value exactly. Never leave a test taint on a node after an exercise.
