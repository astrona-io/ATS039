---
draft: true
exam_objectives:
  - Application Delivery
---
# PodDisruptionBudgets And Node Drains

A rollout is not the only thing that removes pods. An operator drains a node for maintenance, the cluster autoscaler removes an idle node, and an upgrade restarts nodes one after another. These are voluntary disruptions, and a PodDisruptionBudget (PDB) limits them.

## Voluntary and involuntary disruption

| Kind | Examples | PDB applies |
| --- | --- | --- |
| Voluntary | Node drain, autoscaler scale-down, pod eviction | Yes |
| Involuntary | Node crash, out-of-memory kill, network partition | No |

A budget cannot prevent a crash. It makes sure that deliberate actions do not remove too many pods at once.

<!-- astrona:playground:renew -->

Save this as `pdb-dock.yaml`:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: dock
  namespace: outpost
spec:
  minAvailable: 3
  selector:
    matchLabels:
      app: dock
```

Apply it and read its status:

```sh
kubectl apply -f pdb-dock.yaml
kubectl -n outpost get pdb dock
```

The output shows `ALLOWED DISRUPTIONS`: the number of pods that may be evicted now. With four ready pods and `minAvailable: 3`, the value is 1. Use either `minAvailable` or `maxUnavailable` in one budget, and each accepts a number or a percentage.

## How eviction uses the budget

Draining a node calls the eviction API for each pod. The API server accepts the eviction only if the budget still allows it. Otherwise it answers with the status 429 and the drain retries. A budget with `minAvailable` equal to the replica count, or `maxUnavailable: 0`, blocks every drain of the nodes that run those pods. The drain then waits without end.

```sh
kubectl get nodes
kubectl drain NODE --ignore-daemonsets --delete-emptydir-data --dry-run=client
```

Replace `NODE` with a node name. The dry run only lists what a drain would evict. In the single-node playground a real drain would evict everything on the only node, so do not run it without the dry run. Remove the cordon later with `kubectl uncordon NODE`.

## Rollouts and budgets

A Deployment rolling update does not use the eviction API, so a PDB does not slow a rollout. The rollout limits come from `maxUnavailable`. A budget does protect the application while a rollout and a node drain happen at once, because the drain still has to respect the budget.

## Choosing a value

| Application | Budget idea |
| --- | --- |
| Stateless web service, 4 replicas | `maxUnavailable: 1` |
| Quorum system, 3 replicas | `minAvailable: 2` |
| Single replica | No useful budget; run more replicas |

Percentages scale with the replica count, which suits a workload that is autoscaled.

## Common pitfalls

> [!WARNING]
> A budget that allows zero disruptions stops node maintenance and cluster upgrades, because drains wait for it. A selector that matches no pods protects nothing and shows zero expected pods. A PDB does not protect against deleting a Deployment or a pod with `kubectl delete`; only eviction respects it.
