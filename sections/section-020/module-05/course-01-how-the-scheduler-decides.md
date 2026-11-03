---
draft: true
exam_objectives:
  - Debugging
---
# How The Scheduler Decides

The scheduler picks a node for each pod in two steps. It first filters out nodes that cannot run the pod, then scores the rest and takes the best. If the filter leaves no node, the pod stays `Pending` and the scheduler records a `FailedScheduling` event that counts why each node was rejected.

<!-- astrona:playground:renew -->

Create a pod that asks for more CPU than any node has:

```sh
kubectl -n outpost run big --image=busybox:1.37.0 --restart=Never --overrides='{"spec":{"containers":[{"name":"big","image":"busybox:1.37.0","command":["sleep","3600"],"resources":{"requests":{"cpu":"100"}}}]}}'
kubectl -n outpost get pod big
kubectl -n outpost describe pod big
```

The pod stays `Pending`. In the events, read a message of this form:

```text
0/N nodes are available: N Insufficient cpu.
```

The numbers and reasons depend on your cluster. Read the message as a list of reasons with a count of nodes for each one.

## Common reasons in the message

| Reason | Meaning |
| --- | --- |
| `Insufficient cpu`, `Insufficient memory` | Requests are larger than the free capacity of each node |
| `node(s) had untolerated taint` | Nodes have a taint the pod does not tolerate |
| `node(s) didn't match Pod's node affinity/selector` | A node selector or affinity rule excludes the node |
| `node(s) didn't have free ports` | A host port is already in use |
| `pod has unbound immediate PersistentVolumeClaims` | A volume claim is not bound |
| `Too many pods` | The node reached its pod limit |

## Requests, not use

The scheduler adds up the requests of the pods on a node, not their real use. A node can look idle in `kubectl top` and still be full, because requests reserve capacity. Check allocation:

```sh
kubectl describe node NODE_NAME
```

The section `Allocated resources` lists requests and limits as a share of capacity. Replace `NODE_NAME` with a name from `kubectl get nodes`. A pod with no request counts as zero and can be placed anywhere, which is also why such pods are the first to be evicted.

## Fixing

- Lower the request in the manifest, within what the application needs.
- Free capacity by removing or shrinking other workloads.
- Add nodes, or let the cluster autoscaler add them. The autoscaler reacts to `Pending` pods that would fit on a new node.

Delete the example when done:

```sh
kubectl -n outpost delete pod big
```

## Priority and preemption

Pods can have a priority class. A pending pod with a higher priority can cause lower priority pods to be evicted to make room, called preemption. The event says `Preempted`. A system pod with high priority can push out application pods.

## Common pitfalls

> [!WARNING]
> A pod can stay `Pending` for a long time without any visible error if events have expired, because events are kept for about an hour by default. Run `kubectl describe` soon after the failure, or recreate the pod to get a fresh event. Do not remove resource requests to make a pod schedule; the pod then has no guarantee and is first in line for eviction.
