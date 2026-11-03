# Overview: GitOps And Deployment Configuration (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and waits. There is no task, no `astrona submit` and no pass or fail. Create drift, correct it, render manifests, `astrona destroy`, start over.

## What's in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator. `helm` runs on your machine.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas), `probe`, `shuttle` |
| `outpost` | `drifter` |

No `gitops-repo` namespace exists at the start. Create it when you need a stand-in repository: `kubectl create namespace gitops-repo`.

## Helpers

`live_replicas` prints the replica count of a Deployment. `repo_manifest` prints a manifest stored in the stand-in repository.

```sh
live_replicas() {
  kubectl -n "$1" get deployment "$2" -o jsonpath='{.spec.replicas}{"\n"}'
}
repo_manifest() {
  kubectl -n gitops-repo get configmap desired-state -o jsonpath="{.data.$1}"
}
```

## Practice tasks

- Change the replica count of `scout` in `starfleet` by hand. Predict what `kubectl diff` prints for a manifest that says two replicas.
- Run `kubectl get deployment scout -n starfleet --show-managed-fields -o yaml` and find which manager owns `spec.replicas`.
- Render an overlay with `kubectl kustomize` and compare it with `helm template` for the same replica count.
- Run `helm upgrade` with a changed value and list the release Secrets with `kubectl -n outpost get secrets -l owner=helm`.
