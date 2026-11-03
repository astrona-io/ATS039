# Solution

Solve this capstone on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/capstone
```

## Step 1: Get an overview

```sh
kubectl -n starfleet get pods
kubectl -n starfleet get deployments
kubectl -n starfleet get endpoints
```

`dispatch` has pods that are not ready, `beacon` is in `CrashLoopBackOff`, and `relay` has no endpoints.

## Step 2: Fix dispatch forward

```sh
kubectl -n starfleet get deployment dispatch -o jsonpath='{range .status.conditions[*]}{.type}={.status} reason={.reason}{"\n"}{end}'
kubectl -n starfleet describe pod -l app=dispatch
```

The event `Readiness probe failed` reports HTTP status 404 for the path `/missing`. Change the path in the template and record the change:

```sh
kubectl -n starfleet patch deployment dispatch --type json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/readyz"}]'
kubectl -n starfleet rollout status deployment/dispatch --timeout=180s
kubectl -n starfleet annotate deployment dispatch kubernetes.io/change-cause="fix readiness path to /readyz" --overwrite
```

## Step 3: Fix beacon

```sh
kubectl -n starfleet logs deployment/beacon --previous
kubectl -n starfleet get configmap beacon-config -o yaml
```

The log says that `MODE` must be `serve`, and the ConfigMap holds `debug`. Correct the ConfigMap and restart the Deployment so the container starts with the new value:

```sh
kubectl -n starfleet patch configmap beacon-config --type merge -p '{"data":{"mode":"serve"}}'
kubectl -n starfleet rollout restart deployment/beacon
kubectl -n starfleet rollout status deployment/beacon --timeout=180s
```

## Step 4: Fix relay

```sh
kubectl -n starfleet get service relay -o jsonpath='{.spec.selector}{"\n"}'
kubectl -n starfleet get pods -l app=relay --show-labels
```

The selector is `app: relay-api`, but the pods have `app: relay`:

```sh
kubectl -n starfleet patch service relay -p '{"spec":{"selector":{"app":"relay"}}}'
kubectl -n starfleet get endpoints relay
```

## Step 5: Verify and submit

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' http://relay.starfleet.svc.cluster.local/healthz
kubectl -n starfleet exec deploy/shuttle -- curl -s http://dispatch.starfleet.svc.cluster.local/
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/capstone
astrona destroy ats-039-capstone-020
```
