# Question

Solve this question on: `terminal`

Three workloads in the `outpost` namespace are unhealthy. Find the cause of each one from the pod status, the events and the probe settings, and correct it without deleting the Deployments.

1. The pod of the Deployment `gauge` restarts again and again. Its liveness probe asks for a path that the application does not serve. Correct the probe so that it uses the path `/healthz`.

2. The Deployment `ledger` has a pod that runs but is never ready, so the Service `ledger` has no endpoints. Correct the readiness probe so that it uses the path `/readyz`, and make sure the Service lists an endpoint.

3. The Deployment `harbor` cannot start because its image tag does not exist. Correct the tag so that the image is `curlimages/curl:8.22.0`.

`kubectl` already points at the cluster as the cluster administrator.
