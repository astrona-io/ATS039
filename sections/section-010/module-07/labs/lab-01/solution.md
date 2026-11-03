# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-07/labs/lab-01
```

## Step 1: Change the rollout settings

```sh
kubectl -n outpost patch deployment dock --type merge -p '{"spec":{"minReadySeconds":5,"strategy":{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'
astrona submit --keep
```

## Step 2: Create the budget

```sh
cat <<'EOF' | kubectl apply -f -
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: dock-pdb
  namespace: outpost
spec:
  minAvailable: 3
  selector:
    matchLabels:
      app: dock
EOF
astrona submit --keep
```

## Step 3: Prepare the shutdown

```sh
kubectl -n outpost patch deployment dock --type merge -p '{"spec":{"template":{"spec":{"terminationGracePeriodSeconds":20,"containers":[{"name":"dock","lifecycle":{"preStop":{"sleep":{"seconds":5}}}}]}}}}'
kubectl -n outpost rollout status deployment/dock --timeout=180s
astrona submit
```
