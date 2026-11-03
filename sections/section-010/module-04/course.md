---
draft: true
exam_objectives:
  - Application Delivery
---
# Helm Charts And Releases

Raw manifests describe one environment well and many environments badly. Helm packages a set of Kubernetes manifests as a chart, fills in the differences from values and tracks every installation as a numbered release. This module explains the parts of a chart, how templates become manifests, how an installation is upgraded and rolled back, and how values from several sources are merged.

The module has four parts. The first builds a small chart and renders it. The second installs, upgrades and rolls back a release and shows where Helm stores its state. The third covers values, their precedence and checks before an install. The fourth covers repositories, OCI registries, dependencies, hooks and the choice between Helm and plain manifests.

## Learning goals

After this module you can:

- Describe the files of a Helm chart and how templates use values.
- Install, upgrade, inspect and roll back a release.
- Predict which value wins when several sources set the same key.
- Explain what chart repositories, dependencies and hooks add.

## Before you start

You need Deployments and Services, and the commands `kubectl get` and `kubectl apply`. The `helm` command-line tool, version 3 or 4, must be installed on your computer. Helm talks to the cluster with the same kubeconfig as `kubectl`. A chart is a directory of files; a release is one installation of a chart in a namespace.

The playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You install the example chart here |

Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->
