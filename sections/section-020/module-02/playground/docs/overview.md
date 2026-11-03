# Overview: Debugging Failed Releases (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and waits. There is no task, no `astrona submit` and no pass or fail. Break things, read the evidence, `astrona destroy`, start over.

## What's in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe` (`go-httpbin`), `shuttle` |
| `outpost` | `drifter`, a `curl` client |

## Helpers

`rollout_gap` prints the desired, updated, ready and available counts of a Deployment. `rs_view` lists the ReplicaSets with their revision and ready counts.

```sh
rollout_gap() {
  kubectl -n "$1" get deployment "$2" -o jsonpath='desired={.spec.replicas} updated={.status.updatedReplicas} ready={.status.readyReplicas} available={.status.availableReplicas}{"\n"}'
}
rs_view() {
  kubectl -n "$1" get replicaset -l "app=$2" -o custom-columns=NAME:.metadata.name,REVISION:.metadata.annotations.deployment\\.kubernetes\\.io/revision,DESIRED:.spec.replicas,READY:.status.readyReplicas
}
```

## Practice tasks

- Release a template with an image tag that does not exist and compare the result with a bad readiness path.
- Set `maxUnavailable: 0` and `maxSurge: 1`, change the template, and watch the order of Pod creation.
- Set `progressDeadlineSeconds: 20` and read the `Progressing` condition on a stalled rollout.
- Roll back with `kubectl rollout undo --to-revision` and compare the revision numbers before and after.
