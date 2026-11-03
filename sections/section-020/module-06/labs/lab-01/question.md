# Question

Solve this question on: `terminal`

In `outpost`, the Deployment `beacon` was updated and its new pods do not start. The Deployment `ledger` has more replicas than it declares in its annotation `gitops/desired-replicas`.

1. Find out why the new `beacon` pods fail, with `kubectl get pods`, `kubectl describe pod` and `kubectl rollout history`.

2. Recover `beacon` with a rollback so that two replicas are available with the original image tag. Do not set a new tag by guessing.

3. Fix the drift on `ledger`: scale it to the value in its annotation.

4. Record the finding: set the annotation `debug/finding` on the Deployment `beacon` to `bad image tag`.

`kubectl` already points at the cluster as the cluster administrator.
