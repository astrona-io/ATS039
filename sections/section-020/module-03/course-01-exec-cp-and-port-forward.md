---
draft: true
exam_objectives:
  - Debugging
---
# exec, cp And port-forward

When logs are not enough, run something inside the pod. `kubectl exec` starts a process in a running container, `kubectl cp` copies files, and `kubectl port-forward` opens a local port to the pod. All three need the container to be running.

<!-- astrona:playground:renew -->

Start a helper pod with a shell and a web server:

```sh
kubectl -n outpost run shell --image=busybox:1.37.0 --restart=Never -- sh -c 'echo hello > /tmp/note; httpd -f -p 8080 -h /tmp'
kubectl -n outpost wait --for=condition=Ready pod/shell --timeout=120s
```

## exec

```sh
kubectl -n outpost exec shell -- cat /tmp/note
kubectl -n outpost exec -it shell -- sh
```

Everything after `--` is the command. `-i` keeps standard input open and `-t` allocates a terminal, so `-it` gives an interactive shell. In a pod with several containers, choose one with `-c NAME`. Inside you can read environment variables with `env`, the resolver file `/etc/resolv.conf`, the processes with `ps` and mounted files. Exit with `exit`.

`exec` fails with an error like `executable file not found in $PATH` when the image has no shell. That is common for images built from `scratch` or from distroless bases. The next part shows the answer.

## cp

```sh
kubectl -n outpost cp shell:/tmp/note ./note
kubectl -n outpost cp ./note shell:/tmp/note-copy
```

`kubectl cp` needs the `tar` program in the container. Without it, the copy fails. Copying out a log file or a core dump from a stopped container is not possible, because the container must run.

## port-forward

```sh
kubectl -n outpost port-forward pod/shell 8080:8080
```

In a second terminal, run `curl http://127.0.0.1:8080/note`. The command forwards a local port to a port of the pod through the API server. You can also name a Service or a Deployment, and kubectl then picks one pod. A port-forward to a Service reaches one pod only and does not balance. Stop it with Ctrl+C.

Port-forward is useful for reaching an application that has no Ingress, for testing a pod directly, and for comparing a pod that behaves badly with one that behaves well. It also bypasses the Service, so a request that works through the forward and fails through the Service points at the Service, its selector or its endpoints.

## Pods with more than one container

`kubectl logs` and `kubectl exec` use the default container, named by the annotation `kubectl.kubernetes.io/default-container` or else the first container. Name the container with `-c`. Init containers can be addressed the same way with `-c` while they run or after they ended, for logs.

## Common pitfalls

> [!WARNING]
> A change made with `exec` exists only in that container and disappears when the container restarts, so do not fix a problem by editing files in a running pod and then forget to change the manifest or image. Remember that `exec` and `cp` run with the permissions of the container user, and that anyone with `exec` access to a pod can read its Secrets. `kubectl exec` is an operation on a live system: avoid commands that change data on a production pod.
