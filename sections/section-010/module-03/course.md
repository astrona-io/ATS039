---
draft: true
exam_objectives:
  - Application Delivery
---
# Safe Application Releases

A release changes software that users already depend on. A safe release changes it in steps, watches evidence after each step and keeps a way back. This module shows how Kubernetes replaces pods during a rolling update, how probes decide whether a new pod may receive traffic, and how blue-green and canary strategies limit the damage of a bad version.

The module has two parts. The first part runs a rolling update, watches the old and new ReplicaSets, breaks a release with a failing readiness probe and rolls it back. The second part builds a blue-green switch and a canary with two Deployments behind one Service, and explains which evidence justifies promoting a release and what a rollback cannot undo.

## Learning goals

After this module you can:

- Explain rolling update behavior and how readiness gates it.
- Compare rolling, blue-green and canary strategies.
- Identify the evidence needed to promote or reverse a release.
- Explain the compatibility limits of a rollback.

## Before you start

You need Kubernetes basics: Deployments, ReplicaSets, Services, labels and selectors, and the commands `kubectl get`, `kubectl apply`, `kubectl patch` and `kubectl rollout`. A readiness probe is a check the kubelet runs against a container. While it fails, the pod is not ready and the Service sends it no traffic.

The playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You create the example releases here |

Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->
