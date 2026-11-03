---
draft: true
exam_objectives:
  - Application Delivery
---
# ConfigMaps And How Pods Read Them

Software reads its settings at start or while it runs. Kubernetes keeps settings in a ConfigMap, so the container image stays the same in every environment. This part creates a ConfigMap and reads it in the three ways Kubernetes offers.

<!-- astrona:playground:renew -->

Create a ConfigMap with two keys and a file-like key:

```sh
kubectl -n outpost create configmap settings --from-literal=LEVEL=info --from-literal=REGION=alpha
kubectl -n outpost get configmap settings -o yaml
```

## Three ways to read it

| Method | How the pod sees it | Updates reach a running pod |
| --- | --- | --- |
| `env` with `configMapKeyRef` | One environment variable | No |
| `envFrom` with `configMapRef` | All keys as environment variables | No |
| `volumes` with `configMap` | Files in a directory | Yes, after a delay |

Environment variables are read once, when the container starts. A change to the ConfigMap does not change them until the pod is replaced. A mounted ConfigMap is a directory in which each key is a file. The kubelet refreshes the files when the ConfigMap changes, which takes up to a minute or more, and the application must re-read the files. One exception: a volume mounted with `subPath` is never refreshed.

Save this as `reader.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: reader
  namespace: outpost
spec:
  containers:
    - name: reader
      image: busybox:1.37.0
      command: ["sh", "-c", "sleep 3600"]
      env:
        - name: LEVEL
          valueFrom:
            configMapKeyRef:
              name: settings
              key: LEVEL
      volumeMounts:
        - name: settings
          mountPath: /etc/settings
  volumes:
    - name: settings
      configMap:
        name: settings
```

Apply it, then read the values:

```sh
kubectl apply -f reader.yaml
kubectl -n outpost wait --for=condition=Ready pod/reader --timeout=120s
kubectl -n outpost exec reader -- sh -c 'echo $LEVEL; cat /etc/settings/REGION'
```

Now change the ConfigMap and read again after about a minute:

```sh
kubectl -n outpost patch configmap settings --type merge -p '{"data":{"LEVEL":"debug","REGION":"beta"}}'
kubectl -n outpost exec reader -- sh -c 'echo $LEVEL; cat /etc/settings/REGION'
```

The variable still shows `info`. The file shows `beta` once the kubelet has refreshed it. The same behavior applies to a Secret.

## Missing references

A pod that refers to a missing ConfigMap or key does not start and shows the status `CreateContainerConfigError`. Setting `optional: true` on the reference lets the pod start without it. Use that only when the application has a safe default.

## Limits

A ConfigMap can hold at most 1 MiB. Keep binary data in `binaryData`, and large data outside of Kubernetes.

## Common pitfalls

> [!WARNING]
> A changed ConfigMap does not restart the pods that read it through environment variables, so a Deployment can run mixed values until the next rollout. Do not rely on a volume refresh for a setting that must change at one moment for all replicas, because the refresh time differs per pod.
