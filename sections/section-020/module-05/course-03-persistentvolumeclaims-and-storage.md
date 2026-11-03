---
draft: true
exam_objectives:
  - Debugging
---
# PersistentVolumeClaims And Storage

A pod that uses a PersistentVolumeClaim stays `Pending` until the claim is bound to a volume. A claim is a request for storage with a size, an access mode and optionally a storage class. A PersistentVolume is the storage itself. The binding connects the two.

<!-- astrona:playground:renew -->

## Dynamic provisioning

Most clusters have a default StorageClass that creates a volume when a claim appears:

```sh
kubectl get storageclass
```

The default class has the mark `(default)`. Create a claim and a pod that uses it:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data
  namespace: outpost
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 100Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: store
  namespace: outpost
spec:
  containers:
    - name: store
      image: busybox:1.37.0
      command: ["sh", "-c", "sleep 3600"]
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: data
```

```sh
kubectl apply -f storage.yaml
kubectl -n outpost get pvc,pod
kubectl -n outpost describe pvc data
```

The claim status is `Pending` or `Bound`. With the binding mode `WaitForFirstConsumer`, which many classes use, the claim stays `Pending` until a pod uses it, and the message says `waiting for first consumer`. That is normal.

## When a claim stays Pending

Read the events of the claim. Common causes are:

- No default StorageClass and no `storageClassName` on the claim, so nothing provisions the volume.
- A `storageClassName` that does not exist.
- A static volume that does not match the claim in size, access mode or class.
- The provisioner pods are not running, so the storage driver cannot create the volume.
- A zone mismatch: the volume exists in one zone and the pod can only run in another.

Check each with:

```sh
kubectl get storageclass
kubectl get pv
kubectl -n kube-system get pods
```

## Access modes

| Mode | Meaning |
| --- | --- |
| `ReadWriteOnce` | One node can mount it for reading and writing |
| `ReadOnlyMany` | Many nodes can mount it read-only |
| `ReadWriteMany` | Many nodes can mount it for reading and writing |
| `ReadWriteOncePod` | One pod can use it |

With `ReadWriteOnce`, a second pod on another node waits or fails to attach. The event reads `Multi-Attach error`. Many drivers do not support `ReadWriteMany`.

## Expansion and deletion

A claim can grow if the class sets `allowVolumeExpansion: true`: edit the size and wait for the condition `FileSystemResizePending`. The size cannot shrink. A claim in use is protected from deletion; the status is `Terminating` until the pod is gone. The reclaim policy of the volume, `Delete` or `Retain`, decides whether data is removed with the claim.

## Common pitfalls

> [!WARNING]
> Deleting a claim can delete the data when the reclaim policy is `Delete`. Check the policy with `kubectl get pv` before removing a claim of real data. A pod and its claim that are stuck during a node failure may need the node to be confirmed down before the volume detaches; do not force-detach volumes without understanding the data risk. A `Pending` claim on a `WaitForFirstConsumer` class is waiting for a pod, not broken.
