---
draft: true
exam_objectives:
  - Debugging
---
# Reproduce, Correct And Verify

After the gap between intent and observation is found, the repair needs discipline. Several changes at once make it impossible to know which one helped, and a repair without a check leaves the release in an unknown state. This part uses a cycle of three steps: reproduce the failure in a safe place, make one correction, and verify with evidence that can be observed.

## Reproduce outside the live workload

The goal of reproducing is to see the failure on demand, without risking users. For a failing probe, a copy of the Pod template in a separate Deployment is a safe place. Save this as `deployment-lookout-test.yaml`. It uses the same image and the same probe path that failed:

<!-- astrona:playground:renew -->

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lookout-test
  namespace: outpost
spec:
  replicas: 1
  progressDeadlineSeconds: 60
  selector:
    matchLabels:
      app: lookout-test
  template:
    metadata:
      labels:
        app: lookout-test
    spec:
      containers:
        - name: lookout
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          env:
            - name: PODINFO_UI_MESSAGE
              value: lookout-v2
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /missing
              port: http
```

Apply it:

```sh
kubectl apply -f deployment-lookout-test.yaml
kubectl -n outpost get pods -l app=lookout-test
```

The Pod stays `0/1`. The failure reproduced with no Service and no users involved. Now test the suspected cause directly, by asking the container for the path the probe uses. `kubectl port-forward` opens a local port to the Pod:

```sh
kubectl -n outpost port-forward deployment/lookout-test 9898:9898 &
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:9898/missing
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:9898/readyz
kill %1
```

The first request returns `404` and the second returns `200`. The application is healthy; the probe asks for the wrong path. That is a narrow diagnosis, and it was proven without changing the live release.

## Correct with one change

Change one thing: the probe path. Patch the test Deployment first:

```sh
kubectl -n outpost patch deployment lookout-test --type json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/readyz"}]'
kubectl -n outpost rollout status deployment/lookout-test --timeout=120s
```

If the corrected test Deployment becomes ready, the correction is proven. Only then apply the same change to the real release. A fix-forward means the Deployment gets a new template with the corrected value. Each template change creates a new revision, and the controller replaces the stalled Pods.

## Verify with observable evidence

A verification names what you expect to see and checks it. For a Deployment, three observations together are strong evidence:

```sh
kubectl -n outpost get deployment lookout-test -o jsonpath='desired={.spec.replicas} updated={.status.updatedReplicas} ready={.status.readyReplicas} available={.status.availableReplicas}{"\n"}'
kubectl -n outpost get deployment lookout-test -o jsonpath='{.status.conditions[?(@.type=="Progressing")].reason}{"\n"}'
kubectl -n outpost get pods -l app=lookout-test -o jsonpath='{.items[0].status.containerStatuses[0].ready}{"\n"}'
```

The counts are equal, the `Progressing` reason is `NewReplicaSetAvailable`, and the container is ready. The last check is behavior: send a request through the path users take. For a workload behind a Service, send it from a client Pod:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' http://scout.starfleet.svc.cluster.local/healthz
```

Record why the change was made. The annotation `kubernetes.io/change-cause` on a Deployment is shown in the revision history:

```sh
kubectl -n outpost annotate deployment lookout-test kubernetes.io/change-cause="fix readiness path to /readyz" --overwrite
kubectl -n outpost rollout history deployment/lookout-test
```

## Choose between fix-forward and rollback

`kubectl rollout undo` sets the Deployment back to the template of an earlier revision. It is fast and needs no new knowledge about the failure. It is the right choice when users are affected and the previous revision is known to work. Check four requirements first:

- The previous revision still exists in the history, which is limited by `revisionHistoryLimit` (default 10).
- The previous image still exists in the registry and can be pulled.
- The data written by the new version can be read by the old version. A rollback changes the Pod template only; it does not undo a database migration, a changed file format or messages already written to a queue.
- The configuration the old template refers to, such as ConfigMaps and Secrets, still exists and still has the keys it needs.

When one of these does not hold, fix forward with a corrected template. A rollback that does not meet them replaces one failure with another.

```sh
kubectl -n outpost rollout history deployment/lookout-test
kubectl -n outpost rollout undo deployment/lookout-test --to-revision=1
```

The history lists revision numbers, and `--to-revision` selects one. After an undo, the old template becomes a new, higher revision, so the revision number does not go back.

Clean up:

```sh
kubectl -n outpost delete deployment lookout-test
```

## Common pitfalls

> [!WARNING]
> Changing several values at once hides which one fixed the release. Restarting Pods before reading their events destroys the evidence. A rollback does not undo data changes. Verification must include behavior seen from a client, not only a green Deployment status.
