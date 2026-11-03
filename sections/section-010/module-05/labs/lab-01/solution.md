# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown here, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-05/labs/lab-01
```

## Step 1: Write the patch file

Save this as `/tmp/ats039-lab/kustomize/overlays/production/limits.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay
spec:
  template:
    spec:
      containers:
        - name: relay
          resources:
            limits:
              memory: 128Mi
```

## Step 2: Write the overlay

Save this as `/tmp/ats039-lab/kustomize/overlays/production/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
namespace: outpost
namePrefix: prod-
replicas:
  - name: relay
    count: 3
configMapGenerator:
  - name: relay-config
    behavior: merge
    literals:
      - MESSAGE=production
patches:
  - path: limits.yaml
```

## Step 3: Review and apply

```sh
kubectl kustomize /tmp/ats039-lab/kustomize/overlays/production
kubectl apply -k /tmp/ats039-lab/kustomize/overlays/production
kubectl -n outpost rollout status deployment/prod-relay --timeout=180s
astrona submit
```
