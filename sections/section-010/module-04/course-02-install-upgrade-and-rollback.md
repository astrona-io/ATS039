---
draft: true
exam_objectives:
  - Application Delivery
---
# Installing, Upgrading And Rolling Back Releases

The previous part rendered a chart. This part installs it and shows what Helm keeps afterwards. An installed chart is a release. Each change to the release creates a new numbered revision, and Helm can return to an earlier revision.

<!-- astrona:playground:renew -->

Install the chart from the previous part into the `outpost` namespace:

```sh
helm install beacon ./beacon --namespace outpost
kubectl -n outpost rollout status deployment/beacon --timeout=120s
helm list --namespace outpost
```

`helm list` shows the release `beacon` at revision 1 with the status `deployed`. The first argument to `helm install` is the release name, and it becomes `.Release.Name` in the templates.

## Where Helm keeps its state

Helm 3 and later store each revision as a Secret in the namespace of the release. The Secret has the type `helm.sh/release.v1`, the name `sh.helm.release.v1.beacon.v1`, and labels for the release name, the owner, the status and the revision number.

```sh
kubectl -n outpost get secrets -l owner=helm
```

The Secret holds the chart, the values and the rendered manifest in a compressed form. No server component runs in the cluster. Because the history lives in the cluster, a different computer with access to it sees the same releases.

## Upgrade

Change a value and upgrade:

```sh
helm upgrade beacon ./beacon --namespace outpost --set replicaCount=2 --set ui.message=second --wait
helm history beacon --namespace outpost
```

The history lists revision 1 as `superseded` and revision 2 as `deployed`. The flag `--wait` makes Helm wait until the Deployment is ready before it reports success. Helm compares the old manifest, the new manifest and the live objects, then applies a three-way merge patch. A field that someone changed by hand and that neither manifest mentions is kept.

By default `helm upgrade` resets every value that is not set again to the chart default. Add `--reuse-values` to start from the values of the last revision, or pass the same values file every time. The second way is easier to review.

## Roll back

```sh
helm rollback beacon 1 --namespace outpost --wait
helm history beacon --namespace outpost
```

The rollback creates revision 3 with the content of revision 1. History is not erased: it only grows, up to the limit set by `--history-max`, which defaults to 10 revisions. As with a Deployment rollback, Helm restores Kubernetes objects and does not restore data or run reversed migrations.

## Inspect and remove

| Command | Shows |
| --- | --- |
| `helm status beacon -n outpost` | State and notes of the latest revision |
| `helm get values beacon -n outpost` | Values you supplied |
| `helm get values beacon -n outpost --all` | Supplied values merged with chart defaults |
| `helm get manifest beacon -n outpost` | Manifests that were applied |
| `helm uninstall beacon -n outpost` | Removes the release and its objects |

## Common pitfalls

> [!WARNING]
> `helm upgrade` without `--reuse-values` or a values file silently returns every unset value to its default, which can scale a service down or change its image. Always pass the full set of values. Do not edit objects of a release with `kubectl` and expect the change to last, because the next upgrade can overwrite it. `helm uninstall` deletes every object of the release, including a PersistentVolumeClaim the chart created.
