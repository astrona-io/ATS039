# Overview: Debugging Services, DNS And Ingress (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Change things, break things, `astrona destroy`, start over.

## What's in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`, port 9898), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You create the example resources here |

## Helpers

`ep` shows the endpoints of a Service and `fromhere` runs curl in a client pod.

```sh
ep() {
  kubectl -n outpost get endpointslices -l kubernetes.io/service-name="$1"
}
fromhere() {
  kubectl -n outpost exec curl -- curl -s -m 5 "$1"
}
```

## Practice tasks

- Create a Service with a selector typo and find the empty endpoints.
- Test a cluster name and an outside name from a pod and read the resolver file.
- Read a NetworkPolicy with `describe` and add a label that the policy allows.
- Read Ingress or Gateway status fields on an object you apply.
