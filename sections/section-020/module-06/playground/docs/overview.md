# Overview: Debugging Helm And GitOps Delivery Failures (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Change things, break things, `astrona destroy`, start over.

## What's in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You create the example resources here |

## Helpers

`hist` shows the rollout history of a Deployment and `back` rolls it back.

```sh
hist() {
  kubectl -n outpost rollout history deployment/"$1"
}
back() {
  kubectl -n outpost rollout undo deployment/"$1"
}
```

## Practice tasks

- Create a Deployment, update it to an image tag that does not exist and read the failure.
- Use `rollout history` and `rollout undo` to recover.
- Render a chart or an overlay and compare it with the live object.
- Compare a manifest with the live object using `kubectl diff`.
