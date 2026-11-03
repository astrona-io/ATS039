# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-04/labs/lab-01
```

## Step 1: Find the cause

```sh
kubectl -n outpost get service web -o yaml
kubectl -n outpost get endpointslices -l kubernetes.io/service-name=web
kubectl -n outpost get pods --show-labels
```

The selector asks for `app=webb`, the pods have `app=web`, and `targetPort` is 9999.

## Step 2: Fix selector and port

```sh
kubectl -n outpost patch service web --type merge -p '{"spec":{"selector":{"app":"web"},"ports":[{"port":80,"targetPort":9898}]}}'
kubectl -n outpost get endpointslices -l kubernetes.io/service-name=web
astrona submit --keep
```

## Step 3: Record the name

```sh
kubectl -n outpost annotate service web debug/dns="web.outpost.svc.cluster.local" --overwrite
astrona submit
```
