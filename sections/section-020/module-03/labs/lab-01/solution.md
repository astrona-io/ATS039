# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-03/labs/lab-01
```

## Step 1: Find the cause

```sh
kubectl -n outpost get pods
kubectl -n outpost logs deployment/mill
kubectl -n outpost get deployment mill -o yaml
```

The log shows that the shell cannot create the file in `/data`, and the manifest shows `readOnlyRootFilesystem: true` with no volume.

## Step 2: Add the volume

```sh
kubectl -n outpost patch deployment mill --type merge -p '{"spec":{"template":{"spec":{"volumes":[{"name":"data","emptyDir":{}}],"containers":[{"name":"mill","volumeMounts":[{"name":"data","mountPath":"/data"}]}]}}}}'
kubectl -n outpost rollout status deployment/mill --timeout=180s
astrona submit --keep
```

## Step 3: Attach the debug container

```sh
kubectl -n outpost debug sleeper --image=busybox:1.37.0 --container=inspector --target=sleeper -- sleep 3600
```

## Step 4: Record the finding

```sh
kubectl -n outpost annotate deployment mill debug/finding="read-only root filesystem" --overwrite
astrona submit
```
