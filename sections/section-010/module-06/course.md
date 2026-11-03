---
draft: true
exam_objectives:
  - Application Delivery
---
# Configuration And Secrets In Delivery

A release delivers code and also configuration: settings, feature values and credentials. Kubernetes keeps them in ConfigMaps and Secrets, and a delivery process has to move them between environments without leaking secrets and without leaving pods on stale values. This module explains how pods read configuration, what a Secret protects and what it does not, how to keep secrets out of Git, and how a configuration change becomes a safe rollout.

The module has four parts. The first covers ConfigMaps and the three ways a pod reads them. The second covers Secrets and their limits. The third covers delivering secrets through Git workflows. The fourth covers configuration rollouts, immutability and rotation.

## Learning goals

After this module you can:

- Compare environment variables and mounted files as ways to read configuration.
- Explain what a Secret protects and what protects it further.
- Choose a method to deliver secrets with a GitOps workflow.
- Make a configuration change roll out in a controlled way.

## Before you start

You need Pods, Deployments and the commands `kubectl get`, `kubectl apply` and `kubectl rollout`. A ConfigMap holds non-secret settings as key-value pairs. A Secret has the same shape but is meant for credentials. Both are namespaced objects that a pod can read.

The playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You create the example ConfigMaps and Secrets here |

Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->
