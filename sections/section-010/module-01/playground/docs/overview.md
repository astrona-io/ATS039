# Overview: Build And Release Pipelines (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Run Jobs, change annotations, break things, `astrona destroy`, start over.

## What's in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe` (`go-httpbin`), `shuttle` (a `curl` client). Plays the staging environment |
| `outpost` | `drifter`, a `curl` client. Plays the production environment |

## Helpers

Paste these once in each terminal. `image_of` prints the image reference of a Deployment. `job_state` prints the condition type of a Job.

```sh
image_of() {
  kubectl -n "$1" get deployment "$2" -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
}
job_state() {
  kubectl -n "$1" get job "$2" -o jsonpath='{.status.conditions[*].type}{"\n"}'
}
```

## Practice tasks

- Run a Job whose command exits with code `1` and one that exits with code `0`. Compare `job_state` for both.
- Read `image_of starfleet scout`, then print the `imageID` of a `scout` pod and compare the two values.
- Annotate `scout` with a source revision and a change cause, then read `kubectl rollout history`.
- Promote `scout` to `outpost` with the same image reference and a different ConfigMap value.
