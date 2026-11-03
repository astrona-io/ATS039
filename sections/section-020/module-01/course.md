---
draft: true
exam_objectives:
  - Debugging
---
# Diagnosing Application Failures

When an application stops working, the first job is to find out which kind of failure it is. Either the process does not run correctly, or the process runs and its answers are wrong. The two kinds need different evidence and different fixes. This module teaches how to read that evidence in Kubernetes: logs, exit codes, pod and container states, events, endpoints and HTTP status codes.

The module has two parts. The first part creates a crashing container and reads its logs, exit code and restart behavior, and compares the failure states `CrashLoopBackOff`, `ImagePullBackOff` and `CreateContainerConfigError`. The second part follows configuration references and dependency access, reads HTTP status codes, correlates a request with a request identifier and shows how to reproduce a failing request without changing the live workload.

## Learning goals

After this module you can:

- Distinguish a process failure from an application response failure.
- Use logs, exit codes and termination evidence to form a diagnosis.
- Relate configuration and dependency access to application behavior.
- Explain correlation and the safe reproduction of a failing request.

## Before you start

You need Kubernetes basics: pods, Deployments, Services, ConfigMaps and the commands `kubectl get`, `kubectl describe` and `kubectl logs`. A log is the text that a process writes to standard output and standard error; the container runtime stores it and `kubectl logs` reads it. An exit code is the number a process returns when it ends; `0` means success and any other number means failure.

The playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe` (`go-httpbin`), `shuttle` (a `curl` client) |
| `outpost` | `drifter`, a `curl` client. You create the failing examples here |

Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->
