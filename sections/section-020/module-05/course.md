---
draft: true
exam_objectives:
  - Debugging
---
# Debugging Scheduling, Storage And Cluster Dependencies

A pod that stays in the `Pending` state never started, so it has no logs. The reason is in events: no node has enough resources, a taint blocks the pod, a volume cannot be bound, or a quota is full. This module shows how to read those messages and fix each cause.

The module has four parts. The first covers how the scheduler decides and what FailedScheduling means. The second covers taints, tolerations and node selection. The third covers PersistentVolumeClaims and storage. The fourth covers quotas, limit ranges and node conditions.

## Learning goals

After this module you can:

- Read FailedScheduling events and name the cause.
- Use taints, tolerations and node selectors to explain placement.
- Diagnose a PersistentVolumeClaim that stays Pending.
- Find quota, limit range and node condition problems.

## Before you start

You need Pods, Deployments and the commands `kubectl get`, `kubectl describe` and `kubectl get events`. The scheduler chooses a node for each new pod. If it finds none, the pod waits.

The playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You create the example resources here |

Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->
