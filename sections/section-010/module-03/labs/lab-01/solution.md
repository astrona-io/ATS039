# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-03/labs/lab-01
```

## Step 1: Confirm that green is ready

The Deployment must report all replicas ready before it gets traffic:

```sh
kubectl -n starfleet get deployments
kubectl -n starfleet rollout status deployment/scout-green --timeout=120s
```

## Step 2: Switch the Service to green

The selector of the Service decides which pods receive traffic. Save this as `service-patch.yaml`:

```yaml
metadata:
  annotations:
    kubernetes.io/change-cause: switched to green after readiness check
spec:
  selector:
    app: scout
    version: green
```

Apply it as a patch, then ask the Service:

```sh
kubectl -n starfleet patch service scout --patch-file service-patch.yaml
kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet.svc.cluster.local/ | grep message
astrona submit --keep
```

The answer holds `scout-green`. The checks `service-on-green`, `blue-kept` and `cutover-recorded` pass.

## Step 3: Find out why probe is stuck

Compare the ReplicaSets and the pods of `probe`:

```sh
kubectl -n starfleet get replicaset -l app=probe
kubectl -n starfleet get pods -l app=probe
kubectl -n starfleet rollout history deployment/probe
```

The new ReplicaSet has pods that run but are not ready, because the readiness probe asks for the path `/missing`. The old ReplicaSet still serves.

## Step 4: Roll back

```sh
kubectl -n starfleet rollout undo deployment/probe
kubectl -n starfleet rollout status deployment/probe --timeout=180s
astrona submit
```

The undo copies the previous pod template back, so the readiness path is `/status/200` again. All five checks pass.
