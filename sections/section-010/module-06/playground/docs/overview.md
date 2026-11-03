# Overview: Configuration And Secrets In Delivery (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Change things, break things, `astrona destroy`, start over.

## What's in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You create the example ConfigMaps and Secrets here |

## Helpers

`cfg` prints the ConfigMap data and the Secret keys of a namespace.

```sh
cfg() {
  kubectl -n "$1" get configmap -o custom-columns=NAME:.metadata.name,KEYS:.data
  kubectl -n "$1" get secret -o custom-columns=NAME:.metadata.name,TYPE:.type
}
```

## Practice tasks

- Read a ConfigMap as an environment variable and as a file, change it and compare both.
- Create a Secret, decode it with `base64 -d` and mount it with `defaultMode: 0400`.
- Create an immutable ConfigMap and try to change it.
- Use `kubectl rollout restart` after a ConfigMap change and read the history.
