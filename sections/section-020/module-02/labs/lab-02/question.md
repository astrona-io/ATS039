# Question

Solve this question on: `terminal`

The `relay` Deployment in `outpost` was updated to an image tag that does not exist. The rollout is stuck, and the previous version is still serving. Decide on the move that fits the evidence and complete it.

1. Roll the `relay` Deployment back to its previous revision and wait until both replicas are available. The image must be `ghcr.io/stefanprodan/podinfo:6.15.0` again.

2. Set the annotation `kubernetes.io/change-cause` on the Deployment to `rolled back: image tag not found`.

3. Verify the release: create a Job named `smoke-test` in `outpost` with the image `curlimages/curl:8.22.0` that runs `curl -fsS http://relay.outpost.svc.cluster.local/healthz`. The Job must complete.

`kubectl` already points at the cluster as the cluster administrator.
