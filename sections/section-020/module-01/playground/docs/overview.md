# Overview: Diagnosing Application Failures (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and waits. There is no task, no `astrona submit` and no pass or fail. Break things, read the evidence, `astrona destroy`, start over.

## What's in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe` (`go-httpbin`, answers any status code at `/status/<code>`), `shuttle` |
| `outpost` | `drifter`, a `curl` client |

## Helpers

`last_exit` prints the last termination record of the first container of the first pod with a label. `why_not_ready` prints the waiting reason of that container.

```sh
last_exit() {
  kubectl -n "$1" get pods -l "app=$2" -o jsonpath='{.items[0].status.containerStatuses[0].lastState.terminated}{"\n"}'
}
why_not_ready() {
  kubectl -n "$1" get pods -l "app=$2" -o jsonpath='{.items[0].status.containerStatuses[0].state.waiting.reason}{"\n"}'
}
```

## Practice tasks

- Start a container that exits with code `1` and one that exits with code `127`, and compare `last_exit` for both.
- Give a container a memory limit of `8Mi` and a command that allocates more, then read the reason.
- Create a Deployment that refers to a missing Secret and read the event.
- Ask `probe` for `/status/404` and `/status/500` and compare what you would check for each.
