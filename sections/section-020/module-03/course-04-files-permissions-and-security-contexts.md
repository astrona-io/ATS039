---
draft: true
exam_objectives:
  - Debugging
---
# Files, Permissions And Security Contexts

A container that starts and then fails often has a permission problem: it cannot write a file, open a mounted path or run as the required user. This part covers the settings that cause these failures and how to confirm them from inside.

## The security context

The `securityContext` of a pod or container sets the user, the groups and the limits on the process:

| Field | Effect |
| --- | --- |
| `runAsUser`, `runAsGroup` | Numeric user and group of the process |
| `runAsNonRoot` | Refuses to start a container that would run as root |
| `readOnlyRootFilesystem` | Makes the container filesystem read-only |
| `fsGroup` | Group ownership applied to mounted volumes |
| `allowPrivilegeEscalation` | Whether a process can gain more privileges |

These settings are good practice. They are also a frequent cause of failures when an image was built for a root user and writable paths.

<!-- astrona:playground:renew -->

Save this as `mill.yaml`. The container writes a file to a directory that the read-only filesystem does not allow:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mill
  namespace: outpost
spec:
  restartPolicy: Never
  containers:
    - name: mill
      image: busybox:1.37.0
      command: ["sh", "-c", "echo ready > /data/state && sleep 3600"]
      securityContext:
        readOnlyRootFilesystem: true
        runAsNonRoot: true
        runAsUser: 1000
```

Apply it and read the failure:

```sh
kubectl apply -f mill.yaml
kubectl -n outpost get pod mill
kubectl -n outpost logs mill
```

The pod ends in the state `Error`. The log shows that the shell cannot create `/data/state`. The message names either a read-only filesystem or a missing directory. The cause is the combination of a read-only root filesystem and a path that is not a volume.

## Fix it with a volume

A writable path under a read-only root needs a volume. An `emptyDir` volume is a scratch directory that lives as long as the pod:

```yaml
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      emptyDir: {}
```

Delete the pod, add these lines to `mill.yaml` at the right depth, and apply it again. The container now writes to `/data` and keeps running. Use `emptyDir` with `medium: Memory` for data that must not touch the disk. It counts against the memory limit.

## Volume ownership

A volume is often owned by root. A container with `runAsUser: 1000` cannot write to it unless the group matches. `fsGroup: 2000` in the pod security context changes the group of the volume and adds the group to the process. Check the numbers from inside the pod:

```sh
kubectl -n outpost exec mill -- id
kubectl -n outpost exec mill -- ls -ld /data
```

The first command shows the user and group of the process, and the second shows the owner and the mode of the directory.

## Other permission errors

- `runAsNonRoot: true` with an image whose default user is root produces the status `CreateContainerConfigError` and a message that the image will run as root. Set a numeric `runAsUser` or use an image with a non-root user.
- A mounted Secret with `defaultMode: 0400` is readable only by the owner, and the owner may not be the container user. Use `fsGroup` or a mode such as `0440`.
- A Pod Security admission level of `restricted` rejects pods that do not set these fields. The rejection appears when the pod or Deployment is created, as an event or a warning.

## Common pitfalls

> [!WARNING]
> Do not fix a permission error by running the container as root or by making the filesystem writable everywhere; that removes the protection the settings give. Add a volume for the one path that needs to be written. A permission error and a missing path look alike, so check with `exec` and `ls` which of the two it is.
