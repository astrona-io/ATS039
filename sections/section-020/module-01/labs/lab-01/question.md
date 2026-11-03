# Question

Solve this question on: `terminal`

The `starfleet` namespace contains three workloads that do not work. Find the cause of each one from the evidence Kubernetes keeps, and fix it. Do not delete and recreate the Deployments.

1. The Deployment `beacon` is in `CrashLoopBackOff`. Read the log of the previous container and the exit code, and change the Deployment so that the process keeps running.

2. The pod of the Deployment `relay` never starts. Find out why from the pod events, and correct the reference so the pod becomes ready and the variable `ENDPOINT` has a value.

3. The Service `lookout` has pods that are ready, but requests to it fail. Find the reason and fix it, so the Service has endpoints.

At the end, `shuttle` must get HTTP 200 from `http://lookout.starfleet.svc.cluster.local/healthz`. `kubectl` already points at the cluster as the cluster administrator.
