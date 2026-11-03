# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-02/labs/lab-01
```

## Step 1: Find the cause

Compare the desired and observed counts, then read the conditions, the ReplicaSets and the Pod events:

```sh
kubectl -n starfleet get deployment lookout -o jsonpath='desired={.spec.replicas} updated={.status.updatedReplicas} ready={.status.readyReplicas} available={.status.availableReplicas}{"\n"}'
kubectl -n starfleet get deployment lookout -o jsonpath='{range .status.conditions[*]}{.type}={.status} reason={.reason}{"\n"}{end}'
kubectl -n starfleet get replicaset -l app=lookout
kubectl -n starfleet describe pod -l app=lookout
```

The new Pod is running but not ready. The event `Readiness probe failed` reports HTTP status 404. The probe path in the template is `/missing`. The application answers on `/readyz`.

## Step 2: Fix forward

Change the path in the template. This creates a new revision and replaces the stuck Pods:

```sh
kubectl -n starfleet patch deployment lookout --type json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/readyz"}]'
kubectl -n starfleet rollout status deployment/lookout --timeout=180s
```

Do not run `kubectl rollout undo`: it returns to the version one template, and the lab requires `lookout-v2`.

## Step 3: Record the change

```sh
kubectl -n starfleet annotate deployment lookout kubernetes.io/change-cause="fix readiness path to /readyz" --overwrite
kubectl -n starfleet rollout history deployment/lookout
```

Check your work:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-02/labs/lab-01
```

## Step 4: Check from the client side

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s http://lookout.starfleet.svc.cluster.local/
```

The response contains `lookout-v2`. Clean up:

```sh
astrona destroy ats-039-lab-020-02
```
