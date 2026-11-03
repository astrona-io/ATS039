---
draft: true
exam_objectives:
  - Debugging
---
# Resources, OOM Kills And Limits

Containers that use too much memory are killed, and containers that use too much CPU are slowed down. Both look like instability. This part shows how to read resource settings and the signs of a kill.

## Requests and limits

A request is the amount the scheduler reserves for the container. A limit is the maximum the container may use. Memory and CPU behave differently:

| Resource | Over the limit | Visible as |
| --- | --- | --- |
| Memory | The kernel kills the process | `OOMKilled`, exit code 137 |
| CPU | The process is throttled | Slow responses, no restart |

Memory cannot be taken back from a process, so exceeding the limit ends the process. CPU time can be shared out later, so the process only waits.

<!-- astrona:playground:renew -->

Save this as `hog.yaml`. The container tries to hold much more memory than its limit allows:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hog
  namespace: outpost
spec:
  restartPolicy: Never
  containers:
    - name: hog
      image: busybox:1.37.0
      command: ["sh", "-c", "tail /dev/zero"]
      resources:
        limits:
          memory: 32Mi
```

Apply it and read the state:

```sh
kubectl apply -f hog.yaml
kubectl -n outpost get pod hog -w
kubectl -n outpost describe pod hog
```

In the description, the container state is `Terminated` with the reason `OOMKilled` and exit code `137`. The program `tail /dev/zero` reads without end and buffers the lines in memory until the limit stops it. In a Deployment the same event shows as `Last State: Terminated` with the reason `OOMKilled` and a growing restart count, and the pod may show `CrashLoopBackOff`.

## Reading usage

```sh
kubectl top pod -n outpost
kubectl top node
```

`kubectl top` needs the metrics server, an add-on that is not part of every cluster. Without it the command reports that metrics are not available. The numbers show current use, not the peak, and a spike that ended before the sample is not visible. Compare use with the limit and with the request: use close to the limit predicts kills, and use far below the request wastes capacity.

## Other memory kills

Not every kill comes from the container limit. When a node runs out of memory the kubelet evicts pods, and the kernel can kill processes. Evicted pods show the status `Evicted` and a message about node pressure. Pods without requests are the first to go. Check the node with `kubectl describe node NODE` and read the conditions `MemoryPressure` and `DiskPressure`.

## CPU throttling

A container that is throttled shows no restart and no event. Its latency grows when the limit is low for its load. Look for response times that rise under load while use stays flat at the limit. Raising the limit or removing it for latency-sensitive workloads are the usual choices, with the node capacity in mind.

## Java and similar runtimes

A runtime that sizes its heap from the machine memory may exceed the container limit unless it is told about the limit. Modern runtimes read the container limit. Set the heap as a share of the limit and leave room for non-heap memory.

## Common pitfalls

> [!WARNING]
> Raising the memory limit hides a leak and only delays the next kill. Compare the memory curve over time and ask why it grows. A very low CPU limit makes health probes time out, which restarts the container and looks like a crash. A pod killed with exit code 137 was not always out of memory: it can also be a SIGKILL after a failed shutdown, so read the reason in the description.
