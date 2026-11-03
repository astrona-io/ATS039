# Overview: Helm Charts And Releases (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Change things, break things, `astrona destroy`, start over.

## What's in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You install the example chart here |

## Helpers

`rel` lists the releases and the Helm Secrets of a namespace.

```sh
rel() {
  helm list --namespace "$1"
  kubectl -n "$1" get secrets -l owner=helm
}
```

## Practice tasks

- Build the `beacon` chart, render it with `helm template` and change values with `-f` and `--set`.
- Install it into `outpost`, upgrade it twice, read `helm history` and roll back.
- Look at the Helm Secrets with `kubectl get secrets -l owner=helm` and compare them with `helm history`.
- Run `helm get values beacon --all` before and after an upgrade without `--reuse-values`.
