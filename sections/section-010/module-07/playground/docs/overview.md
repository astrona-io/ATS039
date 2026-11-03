# Overview: Rollout Controls And Disruption Safety (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Change things, break things, `astrona destroy`, start over.

## What's in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You create the example Deployments here |

## Helpers

`pods` shows the pods of the `dock` example with their node and age, and `budget` shows the allowed disruptions.

```sh
pods() {
  kubectl -n outpost get pods -l app=dock -o wide
}
budget() {
  kubectl -n outpost get pdb
}
```

## Practice tasks

- Roll out `dock` with `maxSurge: 1` and `maxUnavailable: 0`, and watch the pods.
- Create a PodDisruptionBudget and read the allowed disruptions as pods change.
- Add a `preStop` sleep and delete a pod while you watch the endpoint slices.
- Run `kubectl drain` with `--dry-run=client` and read what it would evict.
