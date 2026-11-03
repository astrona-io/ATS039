---
draft: true
exam_objectives:
  - Application Delivery
---
# Rollback Limits And Compatible Changes

Rollback is the usual answer to a bad release, and it works only when the old version can still run against the current state. State lives outside the image: in databases, queues, caches and files. This part explains what a Kubernetes rollback restores, what it cannot, and how teams design changes so that a rollback stays safe.

## What rollback restores

A Deployment keeps old ReplicaSets, one per revision, up to `spec.revisionHistoryLimit`, whose default is 10. `kubectl rollout undo` changes the pod template of the Deployment back to the previous revision, and the Deployment controller scales the old ReplicaSet up. It restores the pod template: image, environment, probes and resource settings in the template. It does not restore a ConfigMap that changed, a Service, a database or a message already sent.

<!-- astrona:playground:renew -->

Read the revision history and the number of stored ReplicaSets of `scout`:

```sh
kubectl -n starfleet rollout history deployment/scout
kubectl -n starfleet get replicaset -l app=scout
kubectl -n starfleet get deployment scout -o jsonpath='{.spec.revisionHistoryLimit}{"\n"}'
```

The history lists revisions with the change cause. The ReplicaSet list shows one row for each stored revision. If `revisionHistoryLimit` is `0`, the history is empty and `rollout undo` has nothing to go back to. An empty jsonpath result means the field uses the default of 10. To inspect one revision in detail run `kubectl -n starfleet rollout history deployment/scout --revision=1`, using a revision number from the first command.

## Compatibility is the real limit

If version 2 writes data that version 1 cannot read, rolling back to version 1 breaks the application even though the pods start. Teams avoid this with backward-compatible changes. A change is backward compatible when the old version works with the new state, and forward compatible when the new version works with the old state. A safe release needs both during the overlap, because rolling updates and canaries run two versions together.

## Expand and contract

The expand and contract pattern (also called parallel change) splits an incompatible change into compatible steps. To rename a database column, the team does not rename it in one release.

1. Expand. Add the new column. Both versions still work, because the old version ignores the new column.
2. Migrate. Deploy code that writes both columns and reads the new one. Copy old data across.
3. Contract. After the old code is gone and rollback to it is no longer needed, remove the old column.

At every step, a rollback to the previous step works. The same idea applies to API fields, message formats and configuration keys.

## Roll back configuration and images separately

An image rollback does not undo a ConfigMap change. If a release changed the image and a ConfigMap together, the team must reverse both. In GitOps, reverting the commit reverts both, because both live in the repository. With `kubectl`, a ConfigMap is not versioned. This is one reason to generate ConfigMaps with a content hash in the name, so each version is a separate object and the pod template points at one of them.

## Roll forward

Sometimes rollback is unsafe or impossible, for example after a destructive migration. The team then rolls forward: it ships a fix as a new release. Rolling forward needs a fast pipeline and good evidence. The decision between the two uses the same facts: what state the new version changed, whether the old version can read it, and how long the fix takes.

## Common pitfalls

> [!WARNING]
> `rollout undo` restores only the pod template. A low `revisionHistoryLimit` removes the revisions you may need. Destructive migrations, such as dropping a column in the same release that stops using it, remove the way back. Test a rollback before you need one.
