# Question

Solve this question on: `terminal`

The ConfigMap `delivery-repo` in the namespace `delivery-repo` stands in for a Git repository. The key `base-deployment.yaml` holds a base Deployment `scout` and the key `base-service.yaml` holds a base Service `scout`. Release `scout` to production in the namespace `outpost` in three steps. Work in any empty directory, and do not edit the ConfigMap `delivery-repo`.

1. Stable release. Build a Kustomize overlay on top of both base files and apply it with `kubectl apply -k`. The result in `outpost` must be the Deployment `scout` with 3 replicas, the image `ghcr.io/stefanprodan/podinfo:6.15.0`, the label `env: production` on the Deployment and on its pod template (not on the selector), and the Service `scout`. Wait until all 3 replicas are available.

2. Canary release. Create a second Deployment `scout-canary` in `outpost` with 1 replica of the same image. Its pods must carry the labels `app: scout` and `track: canary`, and the environment variable `PODINFO_UI_MESSAGE` set to `scout-canary`. The Service `scout` must then have 4 endpoints: three stable and one canary, a 3:1 split.

3. Release check. Create a Job `release-check` in `outpost` with the image `curlimages/curl:8.22.0`. It requests `http://scout.outpost.svc.cluster.local/healthz`, prints the HTTP status code, and exits with an error unless the code is 200. Wait until the Job is complete.

4. Evidence. Set the annotation `kubernetes.io/change-cause` on the Deployment `scout` in `outpost` to a text that contains the word `canary`.

`kubectl` already points at the cluster as the cluster administrator.
