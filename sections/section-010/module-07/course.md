---
draft: true
exam_objectives:
  - Application Delivery
---
# Rollout Controls And Disruption Safety

A release replaces pods, and so do node maintenance, scaling and failures. Kubernetes has settings that decide how many pods may be missing at a time and how a pod ends. This module collects the controls of a Deployment rollout, explains PodDisruptionBudgets that protect an application from voluntary disruption, covers graceful shutdown so that requests are not cut off, and shows how spreading and capacity affect a rollout.

The module has four parts. The first covers the rollout settings of a Deployment. The second covers PodDisruptionBudgets and node drains. The third covers graceful shutdown. The fourth covers spreading, capacity and autoscaling during a rollout.

## Learning goals

After this module you can:

- Tune maxSurge, maxUnavailable, minReadySeconds and the deadline of a rollout.
- Explain what a PodDisruptionBudget protects and what it does not.
- Describe how a pod shuts down and configure it for graceful shutdown.
- Explain how spreading and capacity limits affect a rollout.

## Before you start

You need Deployments, ReplicaSets, readiness probes and the commands `kubectl rollout` and `kubectl drain`. A voluntary disruption is one that an operator or controller starts on purpose, such as a node drain. An involuntary disruption is a failure, such as a node crash.

The playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You create the example Deployments here |

Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->
