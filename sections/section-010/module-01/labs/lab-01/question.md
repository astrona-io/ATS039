# Question

Solve this question on: `terminal`

The `scout` release built as `build-1287` runs in the `starfleet` namespace, which is the staging environment. It passed its checks. The team must now promote exactly that release to production in the `outpost` namespace. Only the configuration may differ.

1. Create the ConfigMap `scout-config` in `outpost` with the key `PODINFO_UI_MESSAGE` set to `scout-production`.

2. Create the Deployment `scout` in `outpost` with 2 replicas and the exact image reference that the `scout` Deployment in `starfleet` uses. Do not use the `latest` tag. The container must read its environment from `scout-config` with `envFrom`, and the pod label `app: scout` must be set. Copy the annotations `release.astrona.io/source-revision` and `release.astrona.io/build-id` from the staging Deployment to the production Deployment.

3. Create the Service `scout` in `outpost` that sends port 80 to the container port of the `scout` pods. Wait until both replicas are available.

4. Create a Job named `release-check` in `outpost` that runs `curl -fsS` against `http://scout.outpost.svc.cluster.local/healthz` with the image `curlimages/curl:8.22.0`. The Job must complete.

Do not change the `starfleet` namespace. `kubectl` already points at the cluster as the cluster administrator.
