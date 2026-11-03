# Question

Solve this question on: `terminal`

The `scout` release `build-1287` runs in the `starfleet` namespace, the staging environment. Before it goes to production in `outpost`, the release manager needs gate evidence.

1. Create a Job named `gate-checks` in `starfleet`. It must have two init containers named `build-check` and `smoke-check`, in that order, and one main container. The `build-check` container runs `echo build ok`. The `smoke-check` container runs `curl -fsS http://scout.starfleet.svc.cluster.local/healthz`. Use the image `curlimages/curl:8.22.0` for all containers. The Job must complete.

2. After the Job completes, annotate the `scout` Deployment in `starfleet` with `release.astrona.io/approved-by=release-manager`.

3. Create the Deployment `scout` in `outpost` with 1 replica, the exact image reference of the staging Deployment and the pod label `app: scout`. Copy the annotation `release.astrona.io/approved-by` from staging and add the annotation `release.astrona.io/promoted-from=starfleet`. Wait until the replica is available.

Do not change anything else in `starfleet`.
