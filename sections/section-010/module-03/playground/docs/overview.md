# Overview: Safe Application Releases (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and waits. There is no task, no `astrona submit` and no pass or fail. Release, break, roll back, `astrona destroy`, start over.

## What's in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`, readiness probe on `/readyz`), `probe`, `shuttle` |
| `outpost` | `drifter`, a `curl` client |

## Helpers

`rs_state` lists the ReplicaSets of an application with their desired and ready counts. `ask` prints the message a Service answers.

```sh
rs_state() {
  kubectl -n "$1" get replicaset -l "app=$2"
}
ask() {
  kubectl -n outpost exec deploy/drifter -- curl -s "http://$1.outpost.svc.cluster.local/" | grep message
}
```

## Practice tasks

- Change the message of `scout` with `kubectl set env` and watch `rs_state starfleet scout` during the rollout.
- Set `maxUnavailable: 1` and `maxSurge: 0` and compare the pod order with `maxSurge: 1` and `maxUnavailable: 0`.
- Break the readiness path of `scout`, read the Deployment conditions after the deadline and run `kubectl rollout undo`.
- Build a blue-green pair and a canary, then move traffic back with one command.
