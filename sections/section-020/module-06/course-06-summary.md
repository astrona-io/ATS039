---
draft: true
exam_objectives:
  - Debugging
---
# Summary

A Helm release has a status and a history. `failed` and `pending-upgrade` point at the operation that stopped, and the text in `helm history` carries the cluster error. With `--wait`, a failed release often means pods that did not become ready, so move to events and logs.

Render before you apply. `helm lint`, `helm template --debug`, a server-side dry run and `kubectl kustomize` show template, values and schema faults. A misspelled value key is ignored without an error, and the last of several value sources wins.

A GitOps tool reports sync status and health separately. `Synced` and `Degraded` means the repository was applied and the pods fail. Drift comes from manual edits and from other controllers; the repository is the source of truth. Rollback restores the pod template, not data. Use `rollout undo`, `helm rollback` or a revert in the repository, then find the cause.

- Remove `--atomic` while investigating.
- Never delete the Helm release Secrets.
- Do not edit the cluster to fix `OutOfSync`.
- Record revision numbers before changes.

<!-- astrona:playground:destroy -->
