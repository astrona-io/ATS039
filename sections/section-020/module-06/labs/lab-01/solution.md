# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-06/labs/lab-01
```

## Step 1: Find the cause

```sh
kubectl -n outpost get pods
kubectl -n outpost describe pod -l app=beacon
kubectl -n outpost rollout history deployment/beacon
```

The events show that the image pull fails for the tag that does not exist.

## Step 2: Roll back

```sh
kubectl -n outpost rollout undo deployment/beacon
kubectl -n outpost rollout status deployment/beacon --timeout=180s
astrona submit --keep
```

## Step 3: Fix the drift

```sh
kubectl -n outpost get deployment ledger -o jsonpath='{.metadata.annotations.gitops/desired-replicas}'
kubectl -n outpost scale deployment/ledger --replicas=2
```

## Step 4: Record the finding

```sh
kubectl -n outpost annotate deployment beacon debug/finding="bad image tag" --overwrite
astrona submit
```
