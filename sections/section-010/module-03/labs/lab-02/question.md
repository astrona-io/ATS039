# Question

Solve this question on: `terminal`

The `relay` Deployment in `outpost` was released twice. The second release (`MODE=v2`) is stuck because its readiness probe fails. The first release (`MODE=v1`) was healthy.

1. Change the update strategy of `relay` to `Recreate`.

2. Set `revisionHistoryLimit` to `5`.

3. Roll the Deployment back to the revision that sets `MODE=v1`, and wait until both replicas are available.

4. Record the reason: set the annotation `kubernetes.io/change-cause` on the Deployment to `rolled back to v1`.

`kubectl` already points at the cluster as the cluster administrator.
