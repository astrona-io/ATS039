# Question

Solve this question on: `terminal`

In `outpost`, the Deployment `crew` asks for five replicas but fewer pods exist. The pod `wanderer` stays `Pending`.

1. Find out why `crew` has fewer pods than expected. Read the events of its ReplicaSet and the quota in the namespace.

2. Raise the pod limit of the ResourceQuota `small` so that all five `crew` replicas are available. Keep the quota.

3. Find out why `wanderer` is pending. Recreate it as a pod with the same name, the image `busybox:1.37.0` and the command `sleep 3600`, without the node selector, and wait until it runs.

4. Record the finding for the shortage of pods: set the annotation `debug/finding` on the Deployment `crew` to `exceeded quota`.

`kubectl` already points at the cluster as the cluster administrator.
