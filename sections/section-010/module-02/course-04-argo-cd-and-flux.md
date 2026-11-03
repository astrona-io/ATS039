---
draft: true
exam_objectives:
  - Application Delivery
---
# Argo CD And Flux

Two CNCF graduated projects implement pull delivery for Kubernetes: Argo CD and Flux. Both run as controllers in the cluster, read a source and apply it. The exam asks what they do and how they differ from a pipeline. This part describes the resources each one adds to Kubernetes, the settings that decide what a sync does, and how to read their status. The playground does not install them, so the YAML here is for reading.

## Argo CD

Argo CD is a declarative GitOps controller with a web interface and a command-line tool, `argocd`. It adds custom resource definitions (CRDs), which are extensions to the Kubernetes API that add new object kinds. The main kind is `Application`. An `Application` links a source (a repository path) to a destination (a cluster and namespace):

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://git.example.com/starfleet/delivery.git
    targetRevision: main
    path: apps/scout/overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: outpost
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

The `path` can hold plain manifests, a Kustomize directory or a Helm chart, and Argo CD renders it. A sync is the act of applying the rendered manifests to the cluster. Without `automated`, a person starts each sync. With `automated`, the controller syncs when the repository changes. `prune: true` deletes objects that the repository no longer lists. `selfHeal: true` reverts manual changes to the cluster.

Argo CD reports two separate statuses. The sync status says whether the live state matches the repository: `Synced` or `OutOfSync`. The health status says whether the objects work: `Healthy`, `Progressing`, `Degraded`, `Suspended`, `Missing` or `Unknown`. An application can be `Synced` and `Degraded` at once, for example when the manifests match but the pods crash. Sync waves, set with the annotation `argocd.argoproj.io/sync-wave`, order the apply: lower numbers first.

## Flux

Flux is a set of controllers, called the GitOps Toolkit, with a command-line tool `flux`. Each controller owns one job and one set of CRDs.

| Controller | Resource kinds | Job |
| --- | --- | --- |
| Source controller | `GitRepository`, `OCIRepository`, `HelmRepository` | Fetch the source and keep a copy |
| Kustomize controller | `Kustomization` | Build a path with Kustomize and apply it |
| Helm controller | `HelmRelease` | Install and upgrade a Helm chart |
| Notification controller | `Provider`, `Alert` | Send events to chat or Git hosts |

A minimal pair of Flux objects looks like this:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: delivery
  namespace: flux-system
spec:
  interval: 1m
  url: https://git.example.com/starfleet/delivery.git
  ref:
    branch: main
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: scout
  namespace: flux-system
spec:
  interval: 10m
  path: ./apps/scout/overlays/production
  prune: true
  sourceRef:
    kind: GitRepository
    name: delivery
```

The `interval` says how often the controller reconciles. The `Kustomization` here is the Flux kind, which is different from the `kustomization.yaml` file that Kustomize reads. Flux has no built-in web interface.

## Compare the two

Both tools pull from Git, apply with a prune option and correct drift. Argo CD centres on the `Application` and a user interface, and it can manage many clusters from one place. Flux centres on small controllers that you compose, and it is configured only with Kubernetes objects. Neither builds images. A pipeline builds the image and changes the repository, and the controller deploys it.

## Check what is installed

You can ask any cluster which of these CRDs exist. Run this in the playground:

<!-- astrona:playground:renew -->

```sh
kubectl api-resources --api-group=argoproj.io
kubectl api-resources --api-group=kustomize.toolkit.fluxcd.io
kubectl get crd
```

The playground has neither tool, so the first two commands list no resource kinds. The third command lists only the CRDs that exist. On a cluster with Argo CD installed, `Application` appears in the first list. This is the first check to make when an exam question asks which controller a cluster runs.

## Common pitfalls

> [!WARNING]
> `Synced` does not mean healthy. `prune: true` deletes what the repository does not list, so a wrong path can delete a workload. `selfHeal` undoes an emergency fix made with `kubectl`, so make emergency fixes in the repository. The Flux `Kustomization` kind and the Kustomize `kustomization.yaml` file are different things.
