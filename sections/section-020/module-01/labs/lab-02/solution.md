# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-01/labs/lab-02
```

## Step 1: Read the three symptoms

```sh
kubectl -n outpost get pods
kubectl -n outpost get events --field-selector type=Warning
```

The `gauge` pod has restarts, the `ledger` pod shows `0/1` ready and the `harbor` pod shows an image pull status.

## Step 2: Correct the liveness probe of gauge

```sh
kubectl -n outpost patch deployment gauge --type json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/healthz"}]'
kubectl -n outpost rollout status deployment/gauge --timeout=180s
astrona submit --keep
```

## Step 3: Correct the readiness probe of ledger

```sh
kubectl -n outpost patch deployment ledger --type json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/readyz"}]'
kubectl -n outpost rollout status deployment/ledger --timeout=180s
kubectl -n outpost get endpoints ledger
astrona submit --keep
```

## Step 4: Correct the image of harbor

```sh
kubectl -n outpost set image deployment/harbor app=curlimages/curl:8.22.0
kubectl -n outpost rollout status deployment/harbor --timeout=180s
astrona submit
```
