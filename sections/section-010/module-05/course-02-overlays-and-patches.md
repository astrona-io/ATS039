---
draft: true
exam_objectives:
  - Application Delivery
---
# Overlays And Patches

One base can serve many environments. An overlay is another kustomization directory that lists the base as a resource and adds changes. The base is not edited, so a fix in the base reaches every environment.

<!-- astrona:playground:renew -->

Create `relay/overlays/production` and save this as `relay/overlays/production/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
namePrefix: prod-
replicas:
  - name: relay
    count: 3
images:
  - name: ghcr.io/stefanprodan/podinfo
    newTag: 6.15.0
```

Render it and compare it with the base:

```sh
kubectl kustomize relay/overlays/production
```

The Deployment is called `prod-relay`, has three replicas, and the Service selector still matches, because Kustomize rewrites references when it changes names.

## Strategic merge patches

A patch changes a field the transformers do not cover. A strategic merge patch is a partial manifest. Kustomize finds the resource by kind and name and merges the patch into it, using the knowledge of Kubernetes types. A list of containers is merged by the container name, so the patch can set one field of one container.

Save this as `relay/overlays/production/limits.yaml`:

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

Add this to the overlay kustomization:

```yaml
patches:
  - path: limits.yaml
```

The name in the patch is the name in the base, `relay`, not the prefixed name. Render again and read the resource limit in the container.

## JSON 6902 patches

A JSON patch is a list of operations such as `add`, `replace` and `remove` on a path. It is exact and can change a list item by position, which a merge patch cannot. It needs a `target` that selects the resource:

```yaml
patches:
  - target:
      kind: Deployment
      name: relay
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/ports/0/containerPort
        value: 9898
```

Use the strategic merge patch for ordinary field changes and the JSON patch for removals and list positions. A `target` can also select by label selector or by group and version, which patches many resources at once.

## Common pitfalls

> [!WARNING]
> A patch whose name does not match any resource does nothing in some versions and fails in others, so read the rendered output instead of trusting the patch. A JSON patch path counts list items from zero and breaks silently when the base reorders its containers. Keep overlays small: an overlay that rewrites most of the base is a sign that the base is wrong.
