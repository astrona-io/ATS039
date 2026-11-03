---
draft: true
exam_objectives:
  - Application Delivery
---
# Secrets And Their Limits

A Secret holds data that must not be public: passwords, tokens and keys. It has the same structure as a ConfigMap, and pods read it in the same ways. What differs is how Kubernetes treats it, and that is less than many people assume.

<!-- astrona:playground:renew -->

```sh
kubectl -n outpost create secret generic ledger-token --from-literal=token=orbit-7
kubectl -n outpost get secret ledger-token -o jsonpath='{.data.token}'
kubectl -n outpost get secret ledger-token -o jsonpath='{.data.token}' | base64 -d
```

The second command prints the value encoded with Base64, and the third decodes it. Base64 is an encoding, not encryption. Anyone who can read the Secret object can read the value.

## What Kubernetes does for a Secret

- It keeps Secret data out of the output of `kubectl describe`.
- It sends the data only to nodes that run a pod that needs it, and the kubelet keeps it in memory-backed storage for volumes.
- It supports access rules: with role-based access control, you can allow a pod to read one Secret and deny others.
- It can encrypt Secrets at rest in etcd, the cluster database, when the API server has an encryption configuration. This is not on by default in every cluster.

It does not hide the value from anyone who can create a pod in the namespace, because a pod can mount the Secret and print it. Access to create pods is therefore access to every Secret in the namespace.

## Types

| Type | Used for |
| --- | --- |
| `Opaque` | Arbitrary keys; the default |
| `kubernetes.io/dockerconfigjson` | Registry login for `imagePullSecrets` |
| `kubernetes.io/tls` | Certificate and private key |
| `kubernetes.io/basic-auth` | User name and password |
| `kubernetes.io/service-account-token` | A legacy service account token |

## Environment variables or files

A Secret can be an environment variable or a mounted volume. Files are usually safer. Environment variables are inherited by child processes, appear in crash dumps and in `/proc`, and are easy to print by mistake in a debug page. A volume with `defaultMode: 0400` limits who inside the container can read the file.

Save this as `ledger-pod.yaml` and apply it:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ledger
  namespace: outpost
spec:
  containers:
    - name: ledger
      image: busybox:1.37.0
      command: ["sh", "-c", "sleep 3600"]
      volumeMounts:
        - name: token
          mountPath: /etc/ledger-token
          readOnly: true
  volumes:
    - name: token
      secret:
        secretName: ledger-token
        defaultMode: 0400
```

```sh
kubectl apply -f ledger-pod.yaml
kubectl -n outpost wait --for=condition=Ready pod/ledger --timeout=120s
kubectl -n outpost exec ledger -- ls -l /etc/ledger-token
```

The file `token` is listed with owner-only read permission.

## Common pitfalls

> [!WARNING]
> A Secret in a manifest in Git is readable by everyone who can read the repository, and stays in the history after deletion. A Secret is not safe because it is Base64. Turn on encryption at rest, limit who can read Secrets and create pods, and never print Secret values in logs or CI output.
