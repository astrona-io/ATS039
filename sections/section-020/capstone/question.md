# Question

Solve this question on: `terminal`

Three workloads in the namespace `starfleet` are broken. Find the cause of each failure from logs, events, conditions and status fields, and repair it. Repair each Deployment in place: do not delete and recreate `dispatch`, `beacon` or `relay`.

1. The Deployment `dispatch` was updated from `dispatch-v1` to `dispatch-v2` and the rollout is stalled. Fix it forward so that version two rolls out completely, with `updated`, `ready` and `available` replicas equal to the desired 2. Do not use `kubectl rollout undo`. Record the fix by setting the annotation `kubernetes.io/change-cause` on `dispatch` to a text that contains the new readiness path.

2. The Deployment `beacon` is in `CrashLoopBackOff`. Its process reads the variable `MODE` from the ConfigMap `beacon-config`. Correct the value in the ConfigMap, and make sure the container starts again with the corrected value. `beacon` must keep reading `MODE` from `beacon-config`.

3. The pods of `relay` are ready, but requests to the Service `relay` fail. Find the reason and fix it so the Service has endpoints.

At the end, `shuttle` must get HTTP 200 from `http://relay.starfleet.svc.cluster.local/healthz` and the message `dispatch-v2` from `http://dispatch.starfleet.svc.cluster.local/`. `kubectl` already points at the cluster as the cluster administrator.
