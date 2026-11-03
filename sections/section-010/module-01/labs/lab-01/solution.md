# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-01/labs/lab-01
```

## Step 1: Read the staging release

The image reference and the annotations are what you promote:

```sh
kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl -n starfleet get deployment scout -o jsonpath='{.metadata.annotations}{"\n"}'
```

The image is `ghcr.io/stefanprodan/podinfo:6.15.0`. The annotations are `release.astrona.io/source-revision: 4f2a9c1` and `release.astrona.io/build-id: build-1287`.

## Step 2: Create the production configuration

Save this as `scout-production-config.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: scout-config
  namespace: outpost
data:
  PODINFO_UI_MESSAGE: scout-production
```

Apply it:

```sh
kubectl apply -f scout-production-config.yaml
astrona submit --keep
```

The check `production-config` still fails because the Deployment does not exist yet.

## Step 3: Create the Deployment and the Service

Save this as `scout-production.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: outpost
  labels:
    app: scout
  annotations:
    release.astrona.io/source-revision: 4f2a9c1
    release.astrona.io/build-id: build-1287
    kubernetes.io/change-cause: promoted build-1287 from staging
spec:
  replicas: 2
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
          envFrom:
            - configMapRef:
                name: scout-config
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
---
apiVersion: v1
kind: Service
metadata:
  name: scout
  namespace: outpost
spec:
  selector:
    app: scout
  ports:
    - name: http
      port: 80
      targetPort: http
```

Apply it and wait:

```sh
kubectl apply -f scout-production.yaml
kubectl -n outpost rollout status deployment/scout --timeout=180s
astrona submit --keep
```

The checks for the image, the annotations, the configuration and the replicas pass now.

## Step 4: Run the check Job

Save this as `job-release-check.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: release-check
  namespace: outpost
spec:
  backoffLimit: 2
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: check
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "curl -fsS http://scout.outpost.svc.cluster.local/healthz"]
```

Apply it and wait for completion:

```sh
kubectl apply -f job-release-check.yaml
kubectl -n outpost wait --for=condition=complete job/release-check --timeout=120s
astrona submit
```

All five checks pass.
