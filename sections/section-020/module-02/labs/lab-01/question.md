# Question

Solve this question on: `terminal`

The Deployment `lookout` in the namespace `starfleet` was updated from version one (`PODINFO_UI_MESSAGE` set to `lookout-v1`) to version two (`lookout-v2`). The rollout does not finish. Users of the Service `lookout` still get version one.

1. Find out why the rollout is stalled. Use the Deployment status and conditions, the ReplicaSets and the events of the new pods.

2. Fix the release forward: correct the cause in the Deployment so that version two rolls out completely. Version two must stay released, so do not use `kubectl rollout undo`. When you finish, `updated`, `ready` and `available` replicas must equal the desired 2.

3. Record the reason for the change by setting the annotation `kubernetes.io/change-cause` on the Deployment `lookout` to a text that contains the new readiness path.

At the end, `shuttle` must get HTTP 200 and the message `lookout-v2` from `http://lookout.starfleet.svc.cluster.local/`. `kubectl` already points at the cluster as the cluster administrator.
