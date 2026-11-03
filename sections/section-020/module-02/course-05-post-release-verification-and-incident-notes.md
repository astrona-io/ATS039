---
draft: true
exam_objectives:
  - Debugging
---
# Post-Release Verification And Incident Notes

A release is finished when the evidence says it works, not when the rollout command returns. After a fix, the team verifies the result, records what happened and keeps the facts that prevent a repeat. This part builds a smoke-test Job, lists the cluster facts to compare and describes the notes of a short incident review in plain terms.

## Verify with facts

A rollout that completed shows that the new pods are ready. It does not show that users succeed. A complete check compares four facts: the desired and available replicas, the image running in every pod, the Service endpoints and a request that goes through the Service.

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet get deployment scout -o jsonpath='{.spec.replicas} {.status.updatedReplicas} {.status.readyReplicas} {.status.availableReplicas}{"\n"}'
kubectl -n starfleet get pods -l app=scout -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.containers[0].image}{"\n"}{end}'
kubectl -n starfleet get endpoints scout
```

The first line prints four numbers: desired, updated, ready and available replicas. They should be equal. The second command lists the image of each pod, and all lines should show the same reference after a finished rollout. The endpoints list should have one address for each ready pod.

## A smoke test Job

A smoke test is a short request that checks the main function of the application. Run it as a Job from inside the cluster, so it uses the same path as other clients. Save this as `job-smoke-test.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: smoke-test
  namespace: starfleet
spec:
  backoffLimit: 1
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: check
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "curl -fsS http://scout.starfleet.svc.cluster.local/healthz && curl -fsS http://scout.starfleet.svc.cluster.local/version"]
```

Apply it:

```sh
kubectl apply -f job-smoke-test.yaml
```

Then check the result:

```sh
kubectl -n starfleet wait --for=condition=complete job/smoke-test --timeout=90s
kubectl -n starfleet logs job/smoke-test
```

The Job completes only if both requests return a success status. The log holds the response bodies. Delete the Job before the next run, because a Job name is unique: `kubectl -n starfleet delete job smoke-test`.

## Incident notes

A short review turns a failure into knowledge. Write it in plain facts, without blame. Five items are enough.

- Impact: what users saw and for how long.
- Timeline: the times of the change, the first symptom, the diagnosis and the fix.
- Cause: the specific condition, for example "the readiness probe path did not exist in the new image".
- Detection: which signal found it, and whether it was fast enough.
- Follow-up: concrete changes, such as "add a smoke test to the pipeline" or "pin the image by digest".

A cause that says "human error" is not a cause. Ask which check would have stopped the change, and add that check.

## Common pitfalls

> [!WARNING]
> A passing rollout does not prove a working application, and a smoke test that only checks the pod's own health endpoint does not prove the Service works. Keep the incident review about the system. Write the change cause while the facts are fresh.
