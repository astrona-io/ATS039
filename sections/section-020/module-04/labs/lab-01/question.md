# Question

Solve this question on: `terminal`

In `outpost`, the Deployment `web` runs two pods that listen on port 9898, but the Service `web` does not send traffic to them.

1. Find the cause. Look at the endpoints of the Service with `kubectl get endpointslices` and compare the selector with the pod labels.

2. Fix the Service so that it has two endpoint addresses. Do not change the Deployment.

3. Fix the port so that the Service on port 80 sends traffic to port 9898 in the container.

4. Record the full cluster DNS name of the Service: set the annotation `debug/dns` on the Service `web` to the name in the form `SERVICE.NAMESPACE.svc.cluster.local`.

`kubectl` already points at the cluster as the cluster administrator.
