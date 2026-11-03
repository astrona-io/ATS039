---
draft: true
exam_objectives:
  - Debugging
---
# Rollback Decisions And Fix-Forward

When a release is broken, the team must pick one of two moves: go back to the previous version, or ship a fix. Both are valid, and the right choice depends on evidence. This part shows how to read the revision history, how to roll back in Kubernetes, and a decision procedure that a team can follow under pressure.

## Read the revisions

A Deployment keeps one ReplicaSet for each revision. The ReplicaSets carry the annotation `deployment.kubernetes.io/revision`.

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet rollout history deployment/scout
kubectl -n starfleet get replicaset -l app=scout -o custom-columns=NAME:.metadata.name,REVISION:.metadata.annotations.deployment\\.kubernetes\\.io/revision,DESIRED:.spec.replicas
```

The history lists revision numbers and the `CHANGE-CAUSE` text from the annotation `kubernetes.io/change-cause`. The second command shows which ReplicaSet is active: the one with a non-zero `DESIRED`. To see what one revision contained, run `kubectl -n starfleet rollout history deployment/scout --revision=1` with a number from the list.

## Roll back

`kubectl rollout undo deployment/<name>` returns to the previous revision. `--to-revision=<N>` returns to a chosen one. The command edits the pod template of the Deployment, and the Deployment controller scales the matching ReplicaSet up and the current one down. Afterwards the old revision becomes a new, higher revision number.

```sh
kubectl -n starfleet rollout undo deployment/scout --dry-run=server
```

The dry run with `--dry-run=server` asks the API server to process the undo without storing it. Run the real command only when you decide to roll back.

## Decide: roll back or fix forward

Ask four questions in order.

1. Did the new version change state that the old version cannot read, such as a database schema? If yes, rolling back may break the application, so fix forward.
2. Is the cause known and the fix small? If yes, fix forward is fast, and it keeps the history honest.
3. Is the cause unknown and users are affected? Roll back first to stop the damage, then investigate.
4. Is the previous revision still available and healthy? If its ReplicaSet was pruned by `revisionHistoryLimit`, or it depended on a configuration that has changed, roll back is not possible, and you must fix forward.

## Record the decision

Whichever move you choose, write the reason into the change cause, so the history explains itself:

```sh
kubectl -n starfleet annotate deployment scout kubernetes.io/change-cause="rollback after failed readiness: build-1290" --overwrite
```

Annotating the Deployment does not create a new revision, because the annotation is not part of the pod template, but the next revision stores the cause text. Check the history after the next change.

## Common pitfalls

> [!WARNING]
> `rollout undo` restores the pod template only. It does not undo ConfigMap, Secret, Service or data changes. A rollback while a rollout is still in progress returns to the revision before the stuck one. In GitOps, an undo made with `kubectl` is reverted by the controller at the next sync, so revert the commit instead.
