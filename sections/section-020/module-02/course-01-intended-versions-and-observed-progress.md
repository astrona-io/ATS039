---
draft: true
exam_objectives:
  - Debugging
---
# Intended Versions And Observed Progress

The team requests version two of `scout`, but users still receive version one responses. A release declaration describes intent; the live replica set, images and traffic path show what users can actually reach. A rollout can be partially complete while old and new versions coexist.

Compare the desired Pod template with observed replicas and their artifact identities. A mutable tag can hide differences between containers whose image strings match. A digest provides stronger artifact identity. Labels help identify versions, but a label alone does not prove which bytes are running.

Read availability and rollout conditions with events and probe evidence. A new Pod that cannot schedule contributes no new serving capacity. A new container that starts but fails readiness can leave old replicas serving traffic. A failed startup or liveness check may produce repeated restarts instead.

The traffic configuration can also send users to the wrong workload. A Service selector that matches only old Pods or a route pointing to a previous backend can preserve old behavior after new Pods become healthy. Deployment status and traffic destination therefore need separate checks.

A progress deadline signals that expected progress has not occurred. It does not identify every possible cause or establish that an automatic rollback happened. Check the controller's observed state and the release system's actual actions.

For a stale-version symptom, follow the chain from declared artifact to created replicas, readiness, endpoint selection and response behavior. If the new replicas are not ready, repair their startup or configuration. If they are ready but receive no traffic, examine selection and routing rather than rebuilding the same image blindly.

## Reconciling The Release Record With User Traffic

The release record states digest A, the Deployment template requests it, and new Pods report the expected artifact. These observations establish increasingly concrete evidence of version selection. The final question is whether the user's request reaches those Pods and receives their intended behavior.

A Service selector can still target old labels. A gateway can still reference an earlier backend. A client can retain an old connection while replacement progresses. A complete diagnosis follows the actual traffic path instead of equating new Pod creation with universal exposure.

Conversely, mixed responses during a rolling update can be expected because old and new replicas coexist. The application should support that overlap, and the release observer should compare against the current rollout phase. Mixed responses after the old replicas and routes are gone suggest a different source, such as caching or another environment.

## Probe Failures And False Confidence

A readiness check hitting the wrong port can block healthy application instances. A readiness endpoint that returns success without verifying critical behavior can admit unhealthy ones. Both are configuration or design issues, but their symptoms point in opposite directions. Diagnose what the check actually measures before changing its threshold.

If a new container is repeatedly restarted by liveness, the rollout may never gain stable availability. A slow initialization protected by startup behavior has a different contract. A failed probe is therefore meaningful only with its type, target and triggering action.

Track the latest template generation, observed controller progress, replica population and routing evidence. An old event can explain a past failure but not the current revision. These details help establish whether the release is still blocked, has recovered or completed with an application-level regression that requires further correction.

## Common pitfalls

> [!WARNING]
> Labels and desired image strings do not prove the served version. A failed progress condition is evidence of a stalled rollout, not proof of an automatic rollback.
