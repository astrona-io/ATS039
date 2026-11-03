# Overview: Kustomize Bases, Overlays And Patches (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Change things, break things, `astrona destroy`, start over.

## What's in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You apply the example overlays here |

## Helpers

`render` prints an overlay and counts its objects.

```sh
render() {
  kubectl kustomize "$1" | grep -E '^(kind|  name):'
}
```

## Practice tasks

- Build the `relay` base, render it, and apply it with `kubectl apply -k`.
- Add a production overlay with a prefix, three replicas and a memory limit patch.
- Change a literal in `configMapGenerator` and watch the new hash start a rollout.
- Run `kubectl diff -k` before an apply and read what it reports.
