---
draft: true
exam_objectives:
  - Application Delivery
---
# Rollout Settings Of A Deployment

A Deployment rollout has several settings. Together they decide how fast a release goes, how much capacity it keeps and when Kubernetes calls it failed. This part lists them and tries the ones that change behavior the most.

## The settings

| Field | Meaning | Default |
| --- | --- | --- |
| `strategy.rollingUpdate.maxSurge` | Pods allowed above the desired count during a rollout | 25 percent |
| `strategy.rollingUpdate.maxUnavailable` | Pods allowed below the desired count | 25 percent |
| `minReadySeconds` | Time a new pod must be ready before it counts as available | 0 |
| `progressDeadlineSeconds` | Time without progress before the rollout is reported as failed | 600 |
| `revisionHistoryLimit` | Old ReplicaSets kept for rollback | 10 |

A percentage rounds up for `maxSurge` and down for `maxUnavailable`. With four replicas, 25 percent gives one extra pod and one missing pod. Both cannot be zero at the same time, because the rollout could not move.

<!-- astrona:playground:renew -->

Save this as `deployment-dock.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dock
  namespace: outpost
spec:
  replicas: 4
  minReadySeconds: 5
  progressDeadlineSeconds: 120
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: dock
  template:
    metadata:
      labels:
        app: dock
    spec:
      containers:
        - name: dock
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
```

Apply it and trigger a rollout:

```sh
kubectl apply -f deployment-dock.yaml
kubectl -n outpost rollout status deployment/dock --timeout=120s
kubectl -n outpost set env deployment/dock PODINFO_UI_MESSAGE=v2
kubectl -n outpost get pods -l app=dock -w
```

With `maxUnavailable: 0` and `maxSurge: 1`, the controller starts one new pod, waits until it is ready for 5 seconds, and only then stops an old pod. Capacity never drops below four. The price is that the cluster must have room for one extra pod.

## Pause and resume

A rollout can be paused to batch several changes into one revision:

```sh
kubectl -n outpost rollout pause deployment/dock
kubectl -n outpost set image deployment/dock dock=ghcr.io/stefanprodan/podinfo:6.15.0
kubectl -n outpost set env deployment/dock PODINFO_UI_COLOR='#336699'
kubectl -n outpost rollout resume deployment/dock
```

While paused, template changes are recorded but no new ReplicaSet is created. On resume, one rollout applies all changes.

## Speed against safety

A fast rollout (large `maxSurge`) finds a defect later in the fleet, because many pods are replaced before the first one has served traffic. A slow rollout (small values and a long `minReadySeconds`) catches defects that appear after warm-up. Choose `minReadySeconds` longer than the time an application needs to show a crash after it starts.

## Common pitfalls

> [!WARNING]
> `progressDeadlineSeconds` only marks the rollout as failed in the status. It does not stop or undo it. A readiness probe that always passes defeats every setting here, because the controller then believes each new pod is healthy. Check that the probe tests something that fails when the application is broken.
