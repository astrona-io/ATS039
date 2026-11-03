---
draft: true
exam_objectives:
  - Debugging
---
# Rollback And Recovery

When a delivery breaks production, the first goal is to get back to a working state, and the second is to find the cause. This part covers how to roll back in each tool and how to leave a clear record.

<!-- astrona:playground:renew -->

## Roll back a Deployment

```sh
kubectl -n outpost rollout history deployment/web
kubectl -n outpost rollout undo deployment/web
kubectl -n outpost rollout undo deployment/web --to-revision=2
kubectl -n outpost rollout status deployment/web
```

`undo` returns the pod template to the previous revision or to the revision named. It does not undo changes outside the template, such as a changed replica count, and Service or ConfigMap changes stay as they are. With a GitOps tool, a manual undo is replaced at the next sync, so change the repository as well.

Show why a revision exists:

```sh
kubectl -n outpost annotate deployment/web kubernetes.io/change-cause="update image to 6.15.0" --overwrite
```

The annotation appears in `rollout history` as the change cause.

## Roll back a Helm release

```sh
helm history RELEASE -n NAMESPACE
helm rollback RELEASE REVISION -n NAMESPACE --wait
```

A rollback creates a new revision with the old content, so history keeps growing. If the cause was a bad value or a bad chart version, roll back first, then fix the files.

## Roll back in GitOps

Revert the commit in the repository, or move the pinned revision back, and let the tool sync. This leaves a history in the repository that shows who changed what. If the sync is paused or broken, pause automation, fix the repository, then resume.

## Diagnose after recovery

Collect the evidence before it expires:

1. Events: `kubectl get events -A --sort-by=.lastTimestamp`.
2. Logs of the failed pods: `kubectl logs POD --previous` for a container that restarted.
3. The rendered objects of the bad and good revisions, compared with a diff.
4. The status messages of the delivery tool.

Then answer in order: what changed, where it was rejected or failed, why the check did not catch it, and what check or test will catch it next time. A server-side dry run, a rendered diff in the pull request, a smoke test after the sync and readiness probes that reflect real use are the usual answers.

## Common pitfalls

> [!WARNING]
> A rollback restores the pod template and not the data. A schema migration that ran with the bad release stays in the database, so rolling back the application can fail on the new schema. Plan migrations to work with both versions. Do not roll back repeatedly while the cause is unknown; each change makes the evidence harder to read. Write down the revision numbers before you change anything.
