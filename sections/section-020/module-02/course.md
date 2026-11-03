---
draft: true
exam_objectives:
  - Debugging
---
# Debugging Failed Releases

A release can fail while everything looks fine on the surface: the new version was requested, the command returned success, and users still see the old behavior. This module teaches how to compare what was requested with what is running, how to read rollout progress and probe failures, and how to repair a release with a controlled cycle of reproducing, correcting and verifying.

The module has two parts. The first part compares the desired Pod template with the observed ReplicaSets, Pods and image identities, and relates a failing readiness probe to a stalled rollout. The second part reproduces a failure outside the live workload, corrects it with one change, verifies the result with observable evidence, and explains when a rollback is the right choice and when it is not.

## Learning goals

After this module you can:

- Compare intended release identity with observed replicas and artifacts.
- Relate failed probes to rollout progress.
- Design a focused reproduce, correct and verify cycle.
- Choose a rollback only when its compatibility requirements hold.

## Before you start

You need Kubernetes basics: Deployments, ReplicaSets, Pods, Services and the commands `kubectl get`, `kubectl describe`, `kubectl patch` and `kubectl rollout`. A ReplicaSet is the object that keeps a number of identical Pods running; a Deployment creates one ReplicaSet for each version of its Pod template.

The playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe` (`go-httpbin`), `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You create the example releases here |

Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->
