# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-01/labs/lab-01
```

## Step 1: Fix beacon

Look at the state, then read the log of the last terminated container and its exit code:

```sh
kubectl -n starfleet get pods
kubectl -n starfleet logs deployment/beacon --previous
kubectl -n starfleet get pods -l app=beacon -o jsonpath='{.items[0].status.containerStatuses[0].lastState.terminated}{"\n"}'
```

The log says that `MODE` must be `serve`, and the exit code is `3`. Set the variable:

```sh
kubectl -n starfleet set env deployment/beacon MODE=serve
kubectl -n starfleet rollout status deployment/beacon --timeout=120s
```

Check your work:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-01/labs/lab-01 --keep
```

## Step 2: Fix relay

The container never started, so there is no log. Read the events:

```sh
kubectl -n starfleet describe pod -l app=relay
kubectl -n starfleet get configmap relay-config -o yaml
```

The event reports that the key `endpoint` is missing in `relay-config`. The ConfigMap has the key `endpoint-url`. Correct the reference in the Deployment:

```sh
kubectl -n starfleet patch deployment relay --type json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/env/0/valueFrom/configMapKeyRef/key","value":"endpoint-url"}]'
kubectl -n starfleet rollout status deployment/relay --timeout=120s
```

Check your work with the same `astrona submit` command.

## Step 3: Fix lookout

Compare the Service selector with the pod labels, and look at the endpoints:

```sh
kubectl -n starfleet get service lookout -o jsonpath='{.spec.selector}{"\n"}'
kubectl -n starfleet get pods -l app=lookout --show-labels
kubectl -n starfleet get endpoints lookout
```

The selector is `app: lookout-api`, but the pods have `app: lookout`. Patch the Service:

```sh
kubectl -n starfleet patch service lookout -p '{"spec":{"selector":{"app":"lookout"}}}'
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' http://lookout.starfleet.svc.cluster.local/healthz
```

The request returns `200`. Submit once more and then clean up:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-039-lab-020-01
```
