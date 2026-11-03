---
draft: true
exam_objectives:
  - Application Delivery
---
# Bases And Kustomization Files

Kustomize works on directories. The file `kustomization.yaml` lists the resources of the directory and the changes to apply to them. The input stays valid Kubernetes YAML, and the output is also plain YAML. This part builds a base and renders it.

<!-- astrona:playground:renew -->

Create the directory `relay/base` and save this as `relay/base/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay
spec:
  replicas: 1
  selector:
    matchLabels:
      app: relay
  template:
    metadata:
      labels:
        app: relay
    spec:
      containers:
        - name: relay
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          ports:
            - name: http
              containerPort: 9898
```

Save this as `relay/base/service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: relay
spec:
  selector:
    app: relay
  ports:
    - name: http
      port: 80
      targetPort: http
```

Save this as `relay/base/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
```

Render the base:

```sh
kubectl kustomize relay/base
```

The output is the two manifests joined into one stream. Nothing has been sent to the cluster. The command is a safe way to look at a result.

## Transformers

A transformer changes every matching resource. The most used ones are fields of the kustomization file:

| Field | Effect |
| --- | --- |
| `namespace` | Sets the namespace of every resource |
| `namePrefix`, `nameSuffix` | Adds text to every name and updates references |
| `labels` | Adds labels, and with `includeSelectors: true` also to selectors |
| `images` | Changes an image name, tag or digest without editing the Deployment |
| `replicas` | Sets the replica count of a named workload |

Add this to the end of `relay/base/kustomization.yaml`, render again and read the result:

```yaml
namespace: outpost
labels:
  - pairs:
      team: starfleet
    includeSelectors: true
```

Every resource now has the namespace `outpost` and the label `team: starfleet`, and the selector of the Service and the Deployment contain it. The older field `commonLabels` does the same but is deprecated.

Apply the base with the `-k` flag and look at the result:

```sh
kubectl apply -k relay/base
kubectl -n outpost get deploy,svc -l team=starfleet
```

## Common pitfalls

> [!WARNING]
> Adding a label to selectors changes an immutable field of an existing Deployment. Applying the change to a running workload fails with an error about the selector. Add selector labels when the workload is first created, or leave `includeSelectors` off. Also remember that `kubectl kustomize` renders but never applies, and that a path in `resources` is relative to the kustomization file.
