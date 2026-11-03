---
draft: true
exam_objectives:
  - Application Delivery
---
# Spreading, Capacity And Autoscaling During Rollouts

A rollout creates extra pods, a drain moves pods to other nodes, and an autoscaler changes the pod count. Whether these succeed depends on where pods can run and on the capacity that is left. This part covers the settings that spread pods and the limits that block rollouts.

## Spreading pods

Two replicas on the same node are lost together when the node fails. The scheduler can spread them:

| Setting | What it does |
| --- | --- |
| `topologySpreadConstraints` | Keeps the pod count per zone or node within a skew |
| `podAntiAffinity` | Avoids nodes or zones that already run a matching pod |

A constraint looks like this in the pod template:

```yaml
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: kubernetes.io/hostname
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels:
        app: dock
```

`maxSkew: 1` allows a difference of one pod between the nodes with the most and the fewest pods. `DoNotSchedule` as the value of `whenUnsatisfiable` makes the constraint hard, which can leave a pod unscheduled during a rollout. `ScheduleAnyway` treats it as a preference. The playground has one node, so the constraint has no effect there; the field is accepted and the pods still schedule.

## Capacity and surge

A surge needs room. A new pod that cannot be scheduled stays `Pending`, and the rollout stalls without any application fault. Three limits cause it:

- Resource requests larger than the free capacity of the nodes.
- A ResourceQuota in the namespace that the surge exceeds.
- A node selector or taint that few nodes satisfy.

<!-- astrona:playground:renew -->

```sh
kubectl -n outpost describe resourcequota
kubectl describe nodes | grep -A8 "Allocated resources"
kubectl -n outpost get events --field-selector reason=FailedScheduling
```

The first command lists quotas of the namespace and the used amounts. The second shows the requests already placed on the node. The third lists scheduling failures, which name the reason, such as `Insufficient memory`.

## Requests, limits and rollouts

The scheduler uses requests, not limits. A pod without requests is scheduled almost anywhere and can starve its neighbors. A pod with requests far above its use wastes capacity and blocks surges. Set requests near the typical use and limits to protect the node. For memory, a limit below the real need ends in out-of-memory kills during warm-up, which looks like a bad release.

## Autoscaling and rollouts

The HorizontalPodAutoscaler changes the replica count of a Deployment from a metric such as CPU use. If the Deployment manifest also sets `replicas`, every apply resets the count. Leave `replicas` out of the manifest, or out of the repository, when an autoscaler owns it. During a rollout the autoscaler looks at the pods of the new and the old ReplicaSet together. New pods that are still warming up can show high use and cause a scale-up that the application does not need, so the metric should ignore pods that are not ready.

## Common pitfalls

> [!WARNING]
> A hard spread constraint plus a PodDisruptionBudget plus `maxUnavailable: 0` can deadlock a rollout when the cluster has no free node for the surge pod. Leave slack in the cluster capacity for a surge. A manifest in Git with `replicas` set fights an autoscaler on every sync.
