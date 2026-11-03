---
draft: true
exam_objectives:
  - Application Delivery
---
# Kustomize Bases, Overlays And Patches

Kustomize customizes plain Kubernetes manifests without templates. A base holds manifests that work on their own, and an overlay refers to the base and changes only what differs for one environment. Kubernetes includes Kustomize in kubectl, so no extra tool is needed. This module builds a base and two overlays, explains the patch types and generators, and shows how to review the result before it is applied.

The module has four parts. The first builds a base and renders it. The second adds overlays and patches. The third covers generators, name suffixes and transformers. The fourth covers components, review and the choice between Kustomize and Helm.

## Learning goals

After this module you can:

- Describe the roles of a base, an overlay and a kustomization file.
- Change an environment with transformers, strategic merge patches and JSON patches.
- Explain how generators and name suffix hashes trigger rollouts.
- Review a Kustomize result before applying it.

## Before you start

You need Deployments, Services, ConfigMaps and the commands `kubectl get` and `kubectl apply`. Kustomize is built into `kubectl`: `kubectl kustomize DIR` prints the result of a directory and `kubectl apply -k DIR` applies it. A kustomization is a directory with a file named `kustomization.yaml`.

The playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You apply the example overlays here |

Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->
