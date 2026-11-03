---
draft: true
exam_objectives:
  - Debugging
---
# Summary

A failed release is a gap between the intended Pod template and the observed ReplicaSets, Pods and traffic. The Deployment records intent and a revision number. ReplicaSets, Pod readiness and image identity show what runs. A rollout is complete only when `updated`, `ready` and `available` equal `desired`.

A failing readiness probe keeps new Pods out of service and stalls the rollout, while old Pods keep serving. The condition `Progressing` with the reason `ProgressDeadlineExceeded` shows the stall, and the Pod events show the probe failure and its HTTP status. The Deployment does not roll back by itself. A tag does not prove image content; `imageID` identifies the image a container runs.

Repair with a cycle: reproduce the failure outside the live workload, change one thing, and verify with counts, conditions and a request from a client. Choose a rollback when the previous revision exists, its image can be pulled, its configuration still exists and the data written by the new version stays readable. Otherwise fix forward.

- Compare the template with ReplicaSets, Pods and `imageID`.
- Read conditions for the stall and events for the cause.
- Change one thing and verify from the client side.
- A rollback does not undo data changes.

<!-- astrona:playground:destroy -->
