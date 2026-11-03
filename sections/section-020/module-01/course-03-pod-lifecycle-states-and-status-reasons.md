---
draft: true
exam_objectives:
  - Debugging
---
# Pod Lifecycle States And Status Reasons

The `STATUS` column of `kubectl get pods` mixes several kinds of information in one word. `Running`, `Pending`, `CrashLoopBackOff` and `Completed` are not all values of the same field. A reader who knows where each word comes from can go straight to the right command. This part explains the pod phase, the container states and the reasons that `kubectl` shows, and runs pods that end in four of the common statuses.

## Phase, container state and reason

The pod phase is a single field, `status.phase`, with five values: `Pending` (the API server accepted the pod, but one or more containers are not running yet), `Running`, `Succeeded` (all containers exited with code 0 and will not restart), `Failed` (all containers ended and at least one failed) and `Unknown`. A pod keeps the phase `Running` while a container crash-loops, because the pod still exists on its node.

Each container in `status.containerStatuses` has a state with one of three values: `Waiting`, `Running` or `Terminated`. A `Waiting` or `Terminated` state carries a `reason`. The `kubectl get pods` column `STATUS` shows the most useful of these: a reason such as `ImagePullBackOff`, `CrashLoopBackOff` or `OOMKilled`, or the phase when no better word exists.

| Status shown | Where it comes from | Usual cause |
| --- | --- | --- |
| `Pending` | Phase | The scheduler has not placed the pod, or the node has not started it |
| `ContainerCreating` | Waiting reason | The kubelet is creating the container or mounting volumes |
| `ErrImagePull`, `ImagePullBackOff` | Waiting reason | The image name or tag is wrong, or the registry denies access |
| `CrashLoopBackOff` | Waiting reason | The process keeps exiting and the kubelet delays each restart |
| `CreateContainerConfigError` | Waiting reason | A referenced ConfigMap or Secret key does not exist |
| `OOMKilled` | Terminated reason | The container used more memory than its limit |
| `Completed` | Terminated reason | The process exited with code 0 |
| `Error` | Terminated reason | The process exited with a non-zero code |
| `Evicted` | Pod reason | The node removed the pod, usually under resource pressure |

## Produce four statuses

<!-- astrona:playground:renew -->

Save this as `pods-statuses.yaml`. Each pod is built to end in a different status:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: status-completed
  namespace: outpost
spec:
  restartPolicy: Never
  containers:
    - name: main
      image: curlimages/curl:8.22.0
      command: ["sh", "-c", "echo done"]
---
apiVersion: v1
kind: Pod
metadata:
  name: status-error
  namespace: outpost
spec:
  restartPolicy: Never
  containers:
    - name: main
      image: curlimages/curl:8.22.0
      command: ["sh", "-c", "exit 2"]
---
apiVersion: v1
kind: Pod
metadata:
  name: status-pullback
  namespace: outpost
spec:
  containers:
    - name: main
      image: curlimages/curl:no-such-tag
---
apiVersion: v1
kind: Pod
metadata:
  name: status-config
  namespace: outpost
spec:
  containers:
    - name: main
      image: curlimages/curl:8.22.0
      command: ["sleep", "3600"]
      env:
        - name: SETTING
          valueFrom:
            configMapKeyRef:
              name: missing-config
              key: setting
```

Apply it:

```sh
kubectl apply -f pods-statuses.yaml
```

Then check the result after about a minute:

```sh
kubectl -n outpost get pods
```

The list shows `Completed` for `status-completed`, `Error` for `status-error`, `ErrImagePull` or `ImagePullBackOff` for `status-pullback`, and `CreateContainerConfigError` for `status-config`. The pull status changes from `ErrImagePull` to `ImagePullBackOff` as the kubelet waits longer between attempts. The kubelet reports all four, and the container runtime only reports the pull result.

## Read the reason and the exit code

`kubectl describe` prints the state, the reason and the events. For the terminated pods, the exit code is in the container status:

```sh
kubectl -n outpost get pod status-error -o jsonpath='{.status.containerStatuses[0].state.terminated.exitCode}{"\n"}'
kubectl -n outpost get pod status-completed -o jsonpath='{.status.phase}{"\n"}'
kubectl -n outpost describe pod status-pullback
```

The first command prints `2` and the second prints `Succeeded`. The events at the end of the `describe` output name the image and the pull error. Exit codes above 128 mean the process ended by a signal: the code is 128 plus the signal number, so `137` is `SIGKILL` (9) and `143` is `SIGTERM` (15).

You now can tell where a status word comes from and which command shows its cause. A crash loop and a failing probe look alike from outside, and the probes are the next topic.

## Common pitfalls

> [!WARNING]
> `Running` in the phase does not mean the application works. `CrashLoopBackOff` is a restart delay, not an error: the error is in the last exit code and the previous log. A pod in `Completed` is correct for a Job and wrong for a Deployment. Clean up with `kubectl -n outpost delete pod status-completed status-error status-pullback status-config`.
