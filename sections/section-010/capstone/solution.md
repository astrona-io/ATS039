# Solution

Solve this capstone on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/capstone
```

## Step 1: Stable release with an overlay

Extract the base files from the stand-in repository:

```sh
mkdir work && cd work
kubectl -n delivery-repo get configmap delivery-repo -o jsonpath='{.data.base-deployment\.yaml}' > base-deployment.yaml
kubectl -n delivery-repo get configmap delivery-repo -o jsonpath='{.data.base-service\.yaml}' > base-service.yaml
```

Save this as `kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: outpost
resources:
  - base-deployment.yaml
  - base-service.yaml
replicas:
  - name: scout
    count: 3
images:
  - name: ghcr.io/stefanprodan/podinfo
    newTag: 6.15.0
labels:
  - pairs:
      env: production
    includeSelectors: false
    includeTemplates: true
```

Render it to review the result, then apply it:

```sh
kubectl kustomize .
kubectl apply -k .
kubectl -n outpost rollout status deployment/scout --timeout=180s
```

Check your work:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/capstone --keep
```

## Step 2: Canary

Save this as `canary.yaml`. The pod labels `app: scout` make the Service select the pods, and `track: canary` keeps the selector of this Deployment apart from the stable one:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout-canary
  namespace: outpost
  labels:
    app: scout
    track: canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scout
      track: canary
  template:
    metadata:
      labels:
        app: scout
        track: canary
    spec:
      containers:
        - name: scout
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          env:
            - name: PODINFO_UI_MESSAGE
              value: scout-canary
          ports:
            - name: http
              containerPort: 9898
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
```

```sh
kubectl apply -f canary.yaml
kubectl -n outpost rollout status deployment/scout-canary --timeout=180s
kubectl -n outpost get endpoints scout
```

The endpoints list four addresses.

## Step 3: Release check

Save this as `release-check.yaml`:

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
          command:
            - sh
            - -c
            - 'code=$(curl -s -o /dev/null -m 5 -w "%{http_code}" http://scout.outpost.svc.cluster.local/healthz); echo "status $code"; [ "$code" = "200" ]'
```

```sh
kubectl apply -f release-check.yaml
kubectl -n outpost wait --for=condition=complete job/release-check --timeout=180s
kubectl -n outpost logs job/release-check
```

## Step 4: Record the evidence

```sh
kubectl -n outpost annotate deployment scout kubernetes.io/change-cause="production overlay with canary scout-canary at 3:1, release-check passed" --overwrite
```

Submit and clean up:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/capstone
astrona destroy ats-039-capstone-010
```
