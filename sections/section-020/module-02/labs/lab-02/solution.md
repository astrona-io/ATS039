# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-02/labs/lab-02
```

## Step 1: Read the evidence

```sh
kubectl -n outpost rollout history deployment/relay
kubectl -n outpost get pods -l app=relay
kubectl -n outpost get events --field-selector type=Warning
```

The new pod cannot pull its image, and the events say the tag was not found.

## Step 2: Roll back

```sh
kubectl -n outpost rollout undo deployment/relay
kubectl -n outpost rollout status deployment/relay --timeout=180s
kubectl -n outpost annotate deployment relay kubernetes.io/change-cause="rolled back: image tag not found" --overwrite
astrona submit --keep
```

## Step 3: Verify with a smoke test

Save this as `job-smoke-test.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: smoke-test
  namespace: outpost
spec:
  backoffLimit: 2
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: check
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "curl -fsS http://relay.outpost.svc.cluster.local/healthz"]
```

Apply it and wait:

```sh
kubectl apply -f job-smoke-test.yaml
kubectl -n outpost wait --for=condition=complete job/smoke-test --timeout=120s
astrona submit
```
