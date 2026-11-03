# Question

Solve this question on: `terminal`

The `dock` Deployment in `outpost` runs four replicas with the default rollout settings and no PodDisruptionBudget.

1. Change the rolling update so that no pod may be unavailable and one extra pod may be created: `maxSurge` is `1` and `maxUnavailable` is `0`. Set `minReadySeconds` to `5`.

2. Create a PodDisruptionBudget named `dock-pdb` in `outpost` that selects pods with the label `app=dock` and keeps at least `3` pods available.

3. Prepare a graceful shutdown: set `terminationGracePeriodSeconds` to `20` and add a `preStop` hook that uses the `sleep` action for `5` seconds.

4. Wait until all four replicas are available.

`kubectl` already points at the cluster as the cluster administrator.
