---
draft: true
exam_objectives:
  - Debugging
---
# Failed Helm Releases And History

A Helm release has a status and a history. When an install or upgrade fails, the status says where it stopped, and the history lists each revision. Check these before you look at pods.

<!-- astrona:playground:renew -->

## Status and history

```sh
helm list -A
helm status RELEASE -n NAMESPACE
helm history RELEASE -n NAMESPACE
```

Replace `RELEASE` and `NAMESPACE` with the names from `helm list`. The list shows the status of each release. The ones that matter in a failure are:

| Status | Meaning |
| --- | --- |
| `deployed` | The last revision was applied |
| `failed` | The last install or upgrade did not finish |
| `pending-install`, `pending-upgrade` | An operation is running or was interrupted |
| `superseded` | An older revision replaced by a newer one |
| `uninstalling` | A removal is in progress |

`helm history` lists the revisions with a description such as `Upgrade complete` or `Upgrade "web" failed: ...`. The text after the colon is the error from the cluster, for example a rejected object or a timeout.

## Why an upgrade fails

- The cluster rejected an object: invalid field, a resource that already exists and belongs to another release, or an admission webhook denial.
- The wait timed out. With `--wait`, Helm waits for pods to become ready and fails when they do not. The failure then is a pod problem, so go to the pods and read events and logs. The release is `failed` although objects exist.
- A hook job failed. Hooks run at defined points, and a failed one stops the release.
- A previous operation was interrupted and the release stays `pending-upgrade`. A new upgrade then reports that another operation is in progress.

## Read what is in the cluster

```sh
helm get manifest RELEASE -n NAMESPACE
helm get values RELEASE -n NAMESPACE
helm get values RELEASE -n NAMESPACE --all
kubectl -n NAMESPACE get all -l app.kubernetes.io/instance=RELEASE
```

`get manifest` shows the objects Helm applied. `get values` shows the values you supplied, and `--all` includes the chart defaults. Compare these with the live objects to see differences.

Release data is stored as a Secret named `sh.helm.release.v1.RELEASE.vN` in the namespace of the release, one per revision. Do not edit these by hand.

## Stuck in pending

If a release is `pending-upgrade` and no helm process is running, try a rollback to the last good revision:

```sh
helm rollback RELEASE REVISION -n NAMESPACE
```

This creates a new revision with the old content. Check the revision number in `helm history`.

## Common pitfalls

> [!WARNING]
> `helm upgrade --install` with `--atomic` rolls back automatically on failure, which can hide the failed pods. Remove `--atomic` while investigating, or read events before the rollback runs. Do not use `--force` to get past a conflict until you know which object owns the resource; it can delete and recreate objects. Never delete the release Secrets to unstick a release, because the history is lost and Helm no longer knows the objects.
