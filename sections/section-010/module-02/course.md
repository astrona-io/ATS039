---
draft: true
exam_objectives:
  - Application Delivery
---
# GitOps And Deployment Configuration

GitOps is a way to deliver applications in which a version-controlled repository holds the desired state of the system, and a software agent inside the cluster keeps the live state equal to it. The team changes the repository, and the agent applies the change. This module shows what desired state is, how a pull-based reconciliation loop finds and corrects drift, and how Helm and Kustomize produce the manifests that the repository holds.

The module has two parts. The first part builds a small reconciliation step by hand with `kubectl diff` and `kubectl apply`, creates drift on purpose and corrects it, and explains what such a controller cannot know. The second part renders the same application with Kustomize overlays and with a Helm chart, and compares the two approaches.

## Learning goals

After this module you can:

- Explain declarative, versioned desired state.
- Describe pull-based reconciliation and how drift is detected and corrected.
- Compare Helm templating with Kustomize overlays.
- Identify what a GitOps controller cannot infer from repository state.

## Before you start

You need Kubernetes basics: namespaces, Deployments, ConfigMaps, labels and the commands `kubectl get`, `kubectl apply` and `kubectl scale`. Real GitOps controllers, such as Argo CD and Flux, read a Git repository. The playground has no Git server, so a ConfigMap in a namespace called `gitops-repo` stands in for the repository. The reconciliation step you write reads manifests from that ConfigMap. The mechanism is the same: read the desired state, compare it with the live state, apply the difference.

The playground is a single-node `kind` cluster running Kubernetes 1.35. It also needs `helm` on your machine for the second part.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout`, `probe` and `shuttle` |
| `outpost` | `drifter`. You deploy the examples of this module here |

Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->
