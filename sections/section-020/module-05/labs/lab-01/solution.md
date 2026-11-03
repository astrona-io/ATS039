# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-05/labs/lab-01
```

## Step 1: Find the causes

```sh
kubectl -n outpost get pods
kubectl -n outpost get replicaset
kubectl -n outpost describe replicaset -l app=crew
kubectl -n outpost describe resourcequota small
kubectl -n outpost describe pod wanderer
```

The ReplicaSet events show `exceeded quota`, and the pod `wanderer` shows `didn't match Pod's node affinity/selector`.

## Step 2: Raise the quota

```sh
kubectl -n outpost patch resourcequota small --type merge -p '{"spec":{"hard":{"pods":"10"}}}'
kubectl -n outpost rollout status deployment/crew --timeout=180s
astrona submit --keep
```

## Step 3: Recreate the pod

```sh
kubectl -n outpost delete pod wanderer
kubectl -n outpost run wanderer --image=busybox:1.37.0 --restart=Never -- sleep 3600
kubectl -n outpost wait --for=condition=Ready pod/wanderer --timeout=180s
```

## Step 4: Record the finding

```sh
kubectl -n outpost annotate deployment crew debug/finding="exceeded quota" --overwrite
astrona submit
```
