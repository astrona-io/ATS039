---
draft: true
exam_objectives:
  - Debugging
---
# Summary

A pod in `Pending` has not been placed. Read the `FailedScheduling` event, which lists each reason with a count of nodes: not enough CPU or memory requests, a taint, a selector or affinity rule, a pod limit, or an unbound claim. The scheduler counts requests, not real use.

A taint repels pods and a toleration permits a pod to land on the node. A toleration does not pin a pod to the node. A node selector with a missing label leaves the pod pending.

A claim stays `Pending` when no class provisions the volume, the class does not exist, or no static volume matches. With `WaitForFirstConsumer` a pending claim is normal until a pod uses it. A ResourceQuota stops pod creation at the ReplicaSet, a LimitRange sets defaults and bounds, and node conditions such as `DiskPressure` block or evict pods.

- Describe soon: events expire.
- Do not remove requests to schedule a pod.
- Check the reclaim policy before deleting a claim.
- Quota increases belong to the namespace owner.

<!-- astrona:playground:destroy -->
