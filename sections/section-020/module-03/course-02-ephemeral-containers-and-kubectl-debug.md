---
draft: true
exam_objectives:
  - Debugging
---
# Ephemeral Containers And kubectl debug

An ephemeral container is a temporary container added to a running pod for debugging. It shares the pod network and, when asked, the process namespace of another container. It is not restarted and it cannot be removed from the pod, and the pod specification is not changed otherwise. It is the answer to an image with no shell.

<!-- astrona:playground:renew -->

Start a pod from the application image, which has no debugging tools in the sense of the lesson:

```sh
kubectl -n outpost run app --image=ghcr.io/stefanprodan/podinfo:6.15.0 --restart=Never
kubectl -n outpost wait --for=condition=Ready pod/app --timeout=120s
```

Attach an ephemeral container that brings its own tools:

```sh
kubectl -n outpost debug -it app --image=busybox:1.37.0 --target=app --container=debugger -- sh
```

Inside, `ps` lists the processes of the application container, because `--target` shares its process namespace. The network is the pod network, so `wget -qO- http://127.0.0.1:9898/healthz` reaches the application on localhost. With the right permissions you can also read the application files through `/proc/PID/root`. Exit with `exit`. The container stays in the pod specification as stopped:

```sh
kubectl -n outpost get pod app -o jsonpath='{.spec.ephemeralContainers[*].name}'
```

Without `-it` and with a command after `--`, `kubectl debug` adds the container and runs the command without a terminal. Read the output with `kubectl logs app -c debugger`.

## Copy a pod

A crashing pod cannot be debugged from inside because it keeps restarting. `kubectl debug` can create a copy with changed settings:

```sh
kubectl -n outpost debug app --copy-to=app-debug --container=app -- sleep 3600
```

The copy runs the same image with the command replaced by `sleep 3600`, so it stays up. Open a shell with `exec` and start the real command by hand to see the error. Options of the same command change the image with `--set-image=app=IMAGE`, and `--share-processes` shares the process namespace. Delete the copy afterwards with `kubectl -n outpost delete pod app-debug`.

## Debug a node

```sh
kubectl debug node/NODE_NAME -it --image=busybox:1.37.0
```

This creates a pod on the node that mounts the node filesystem at `/host`. Use it to read files such as kubelet logs on the node when SSH access is not available. Replace `NODE_NAME` with a name from `kubectl get nodes`. The pod runs with host access, so remove it after use.

## When ephemeral containers are not available

They need a cluster whose API server and container runtime allow them, which is the default in current versions. An administrator can block them with an admission policy. In that case use the copy approach or a debug image in the deployment.

## Common pitfalls

> [!WARNING]
> An ephemeral container cannot have ports, probes or resource settings, and cannot be removed from the pod; delete the pod to clear it. The node debug pod mounts the host filesystem and can see everything on the node, so use it only when you may. A copied pod is a new pod: it can have the same labels as the original and receive traffic from a Service, so check the labels before you leave it running.
