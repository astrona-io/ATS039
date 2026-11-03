---
draft: true
exam_objectives:
  - Application Delivery
---
# Summary

A rolling update replaces the pods of a Deployment a few at a time by scaling a new ReplicaSet up and the old one down. The fields `maxSurge` and `maxUnavailable` set the pace. The readiness probe is the health gate: a new pod that never becomes ready stalls the rollout while the old pods keep serving. The controller reports the stall after `progressDeadlineSeconds` and does not roll back by itself.

Blue-green runs two complete versions and switches all traffic at once by changing the Service selector. A canary sends a small share of traffic to the new version, for example through a replica ratio, and widens the share while the evidence stays good. Blue-green costs double capacity, and a canary through pod counts is approximate.

Promotion needs evidence: readiness, error rate, latency and logs of the new version under real traffic, judged against thresholds set before the release. A rollback restores the pod template or the traffic path, and it does not restore changed ConfigMaps, written data or run migrations.

- Only a pod template change starts a rollout.
- Readiness decides which pods receive traffic.
- A Service selector is the switch for blue-green.
- Rollback is safe only when the old version works with the current data.

<!-- astrona:playground:destroy -->
