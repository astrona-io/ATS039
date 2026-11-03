# Overview: Debugging Scheduling, Storage And Cluster Dependencies (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Change things, break things, `astrona destroy`, start over.

## What's in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You create the example resources here |

## Helpers

`why` shows the newest events of a pod and `alloc` shows node allocation.

```sh
why() {
  kubectl -n outpost describe pod "$1" | sed -n '/Events:/,$p'
}
alloc() {
  kubectl describe node "$1" | sed -n '/Allocated resources/,/Events/p'
}
```

## Practice tasks

- Create a pod with an unreachable CPU request and read the FailedScheduling event.
- List node taints and labels, then use a node selector that matches no node.
- Create a claim and a pod and read the claim state.
- Create a ResourceQuota that is too small and read the ReplicaSet event.
