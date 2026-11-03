---
draft: true
exam_objectives:
  - Debugging
---
# GitOps Sync, Health And Drift

A GitOps tool compares the state in a repository with the state in the cluster and applies the difference. It reports two separate things: sync status and health. They are often confused.

<!-- astrona:playground:renew -->

## Sync and health

| Question | Name | Example values |
| --- | --- | --- |
| Does the cluster match the repository? | Sync status | Synced, OutOfSync |
| Are the running objects working? | Health | Healthy, Progressing, Degraded, Missing |

An application can be `Synced` and `Degraded`: the repository was applied exactly, and the pods crash. It can also be `OutOfSync` and `Healthy`: something differs but everything works. Look at both. Tools such as Argo CD and Flux show the same ideas under their own names. Argo CD uses `Synced` and `Healthy`. Flux reports conditions such as `Ready` with a reason and message on each Kustomization or HelmRelease.

## Where to look

- Argo CD: the application status, its sync result with the message per resource, the diff and the events of the application. With the command line tool, `argocd app get NAME` and `argocd app diff NAME`.
- Flux: `flux get kustomizations`, `flux get helmreleases -A` and `kubectl describe` on the object. The `Ready` condition carries the error text.

Common messages include a failure to fetch the repository, an invalid path, a failure to render, a rejected object, and a health check timeout.

## Failures before the cluster

- Source errors: the repository is not reachable, the credentials expired, the branch or tag does not exist, or the revision pinned is gone. The tool shows an old revision and does not apply anything new.
- Render errors: Helm or Kustomize fails to render. Render the same files locally.
- Ordering: an object that needs a CRD or namespace that is not there yet. Sync waves or dependencies solve it.

## Drift

Drift is a difference between the repository and the cluster that was not made through the repository. Typical causes are a manual `kubectl edit`, a controller that changes a field such as replicas, or an operator that adds annotations. Compare:

```sh
kubectl diff -f manifest.yaml
kubectl get deployment NAME -o yaml
```

With automated self-healing the tool undoes the manual change at the next sync, often within minutes. A change that keeps coming back is the sign of self-healing. Another controller writing the same field produces a loop of corrections: ignore that field in the comparison, or stop one of the two writers. A horizontal autoscaler and a fixed `replicas` in the repository are the classic case.

## Pruning

With pruning on, an object removed from the repository is deleted from the cluster. If a path changed by mistake, a whole set of objects can be pruned. Many tools show a list of what would be deleted in the diff before the sync.

## Common pitfalls

> [!WARNING]
> Do not fix an `OutOfSync` state by editing the cluster. The next sync will replace your change, and the repository is the source of truth. Fix the repository, then let the tool sync. Pausing automated sync during an investigation is fine, and it must be turned on again. A `Synced` and `Healthy` application can still be wrong if the repository holds the wrong value, so check the revision that was applied.
