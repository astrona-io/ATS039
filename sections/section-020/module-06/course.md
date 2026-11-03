---
draft: true
exam_objectives:
  - Debugging
---
# Debugging Helm And GitOps Delivery Failures

Delivery adds a layer between your files and the cluster. A release can fail before any pod starts, a chart can render something you did not expect, a tool can report a healthy sync while pods crash, and a manual change can be undone without notice. This module shows how to find which layer failed.

The module has four parts. The first covers failed Helm releases and their history. The second covers chart rendering and values problems. The third covers GitOps sync status, health and drift. The fourth covers rollback and recovery.

## Learning goals

After this module you can:

- Read Helm release status, history and failure messages.
- Render a chart locally to find a template or values fault.
- Tell sync status from health and find drift in a GitOps tool.
- Roll back safely and record what failed.

## Before you start

You need the delivery ideas from the Helm, Kustomize and rollout modules: a release is a versioned install of a chart, and a GitOps tool applies the state in a repository to the cluster. Helm commands need the `helm` program on your computer.

The playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You create the example resources here |

Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->
