---
draft: true
exam_objectives:
  - Application Delivery
---
# Summary

A rolling update is tuned with `maxSurge`, `maxUnavailable`, `minReadySeconds`, `progressDeadlineSeconds` and `revisionHistoryLimit`. Setting `maxUnavailable: 0` keeps full capacity and needs room for the surge pods. A paused rollout batches several changes into one revision. The deadline only reports a failure and never undoes the rollout.

A PodDisruptionBudget limits voluntary disruption, such as a node drain, through the eviction API. It does not stop crashes or a rollout and it does not stop `kubectl delete`. A budget that allows no disruption blocks node maintenance.

A pod ends with endpoint removal, the `preStop` hook, SIGTERM and, after the grace period, SIGKILL. A short `preStop` pause, SIGTERM handling and a long enough grace period avoid dropped requests. Spread constraints, quotas and requests decide whether surge pods can be scheduled, and an autoscaler and a fixed `replicas` field in Git conflict.

- Readiness must reflect real health, or every setting here fails.
- The eviction API respects budgets; a rollout does not use it.
- The grace period includes the `preStop` time.
- Leave capacity free for the surge.

<!-- astrona:playground:destroy -->
