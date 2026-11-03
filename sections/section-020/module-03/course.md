---
draft: true
exam_objectives:
  - Debugging
---
# Debugging Inside Pods With kubectl

Logs and events show what a pod reports. Some faults show only when you look from inside the pod: a file that is missing, a process that cannot write, a container with no shell. This module covers the kubectl tools that run commands in a pod, attach a temporary debug container, read resource use and exit reasons, and check files and permissions.

The module has four parts. The first covers exec, copy and port-forward. The second covers ephemeral containers and the debug command. The third covers resources, out-of-memory kills and limits. The fourth covers files, permissions and security contexts.

## Learning goals

After this module you can:

- Run commands, copy files and forward ports to reach a pod.
- Attach an ephemeral debug container to a pod that has no shell.
- Recognise out-of-memory kills and resource limit problems.
- Diagnose permission and read-only filesystem failures.

## Before you start

You need Pods, containers and the commands `kubectl get`, `kubectl describe` and `kubectl logs`. A container image often holds only the application and no tools. That is good for security and size, and it limits what you can do inside.

The playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You create the example pods here |

Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->
