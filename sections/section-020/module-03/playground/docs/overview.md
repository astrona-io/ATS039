# Overview: Debugging Inside Pods With kubectl (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Change things, break things, `astrona destroy`, start over.

## What's in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You create the example pods here |

## Helpers

`inside` runs a command in a pod and `debugger` attaches a temporary container.

```sh
inside() {
  kubectl -n outpost exec "$1" -- "${@:2}"
}
debugger() {
  kubectl -n outpost debug -it "$1" --image=busybox:1.37.0 --target="$1" -- sh
}
```

## Practice tasks

- Start a pod with a shell, use `exec`, `cp` and `port-forward`.
- Attach an ephemeral container to a pod from the `podinfo` image and list its processes.
- Create a pod that exceeds its memory limit and read the `OOMKilled` state.
- Run a container with a read-only root filesystem, then add an `emptyDir` volume.
