# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Command output is not shown, because this lab has not been run yet.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS039.git -c sections/section-010/module-02/labs/lab-01
```

## Step 1: Find the drift

Write the manifest from the repository to a file and compare it with the live cluster:

```sh
kubectl -n gitops-repo get configmap desired-state -o jsonpath='{.data.scout\.yaml}' > scout.yaml
kubectl diff -f scout.yaml
```

The diff shows two changes: `replicas` is `1` instead of `2`, and `PODINFO_UI_MESSAGE` is `scout-hotfix` instead of `scout-v1`.

## Step 2: Correct the cluster

Applying the manifest from the repository writes both fields back:

```sh
kubectl apply -f scout.yaml
kubectl -n starfleet rollout status deployment/scout --timeout=180s
astrona submit --keep
```

The check `live-matches-repository` passes.

## Step 3: Remove the unmanaged Deployment

List the Deployments in `starfleet`. `debug-tools` is not in the repository:

```sh
kubectl -n starfleet get deployments
kubectl -n starfleet delete deployment debug-tools
astrona submit --keep
```

## Step 4: Build the overlay

Save the base from the repository. Create the directories first:

```sh
mkdir -p base overlays/production
kubectl -n gitops-repo get configmap desired-state -o jsonpath='{.data.base-deployment\.yaml}' > base/deployment.yaml
```

Save this as `base/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
```

Save this as `overlays/production/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: outpost
resources:
  - ../../base
replicas:
  - name: scout
    count: 2
images:
  - name: ghcr.io/stefanprodan/podinfo
    newTag: 6.15.0
labels:
  - pairs:
      env: production
    includeTemplates: true
```

Render it first, then apply it:

```sh
kubectl kustomize overlays/production
kubectl apply -k overlays/production
kubectl -n outpost rollout status deployment/scout --timeout=180s
astrona submit
```

All four checks pass.
