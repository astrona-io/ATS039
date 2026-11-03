# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-01/labs/lab-02
```

## Step 1: Run the gate Job

Save this as `job-gate-checks.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: gate-checks
  namespace: starfleet
spec:
  backoffLimit: 2
  template:
    spec:
      restartPolicy: Never
      initContainers:
        - name: build-check
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "echo build ok"]
        - name: smoke-check
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "curl -fsS http://scout.starfleet.svc.cluster.local/healthz"]
      containers:
        - name: report
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "echo gate passed"]
```

Apply it and wait:

```sh
kubectl apply -f job-gate-checks.yaml
kubectl -n starfleet wait --for=condition=complete job/gate-checks --timeout=120s
astrona submit --keep
```

## Step 2: Record the approval

```sh
kubectl -n starfleet annotate deployment scout release.astrona.io/approved-by=release-manager --overwrite
astrona submit --keep
```

## Step 3: Promote the release

Save this as `deployment-scout-production.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: outpost
  labels:
    app: scout
  annotations:
    release.astrona.io/approved-by: release-manager
    release.astrona.io/promoted-from: starfleet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      containers:
        - name: scout
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
```

Apply it and wait:

```sh
kubectl apply -f deployment-scout-production.yaml
kubectl -n outpost rollout status deployment/scout --timeout=180s
astrona submit
```
