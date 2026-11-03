---
draft: true
exam_objectives:
  - Debugging
---
# Image And Registry Failures

A release can stall before any container starts, because the node cannot get the image. These failures look like application problems in a pipeline status, but the cause is a name, a credential or the registry. This part shows how to recognise an image pull failure, read its cause in the events and correct it for a public and a private registry.

## How a pull works

When the kubelet starts a pod, it asks the container runtime to pull each image that is not on the node, according to `imagePullPolicy`. The runtime contacts the registry named in the image reference. If the reference has no registry, the runtime uses its default. The pull can fail for four reasons: the name or tag does not exist, the registry denies access, the registry cannot be reached, or the node cannot resolve the registry name.

After a failure the kubelet retries with a growing delay. The pod status shows `ErrImagePull` during the attempt and `ImagePullBackOff` during the wait.

## A tag that does not exist

<!-- astrona:playground:renew -->

Save this as `deployment-relay-bad-tag.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay-badtag
  namespace: outpost
spec:
  replicas: 1
  selector:
    matchLabels:
      app: relay-badtag
  template:
    metadata:
      labels:
        app: relay-badtag
    spec:
      containers:
        - name: relay
          image: ghcr.io/stefanprodan/podinfo:6.15.999
```

Apply it and look at the result:

```sh
kubectl apply -f deployment-relay-bad-tag.yaml
kubectl -n outpost get pods -l app=relay-badtag
kubectl -n outpost describe pod -l app=relay-badtag
```

The pod shows `ErrImagePull` and then `ImagePullBackOff`. The events contain a `Failed` warning with the registry's answer, which for a missing tag says that the manifest was not found. The fix is to correct the tag in the Deployment. A tag typo is the most common cause, and the events name the exact reference that failed.

## Private registries

A private registry needs credentials. A Secret of type `kubernetes.io/dockerconfigjson` stores them, and a pod uses it through `imagePullSecrets`. Create one with a command:

```sh
kubectl -n outpost create secret docker-registry registry-login --docker-server=registry.example.com --docker-username=robot --docker-password=not-a-real-password
kubectl -n outpost get secret registry-login -o jsonpath='{.type}{"\n"}'
```

The second command prints `kubernetes.io/dockerconfigjson`. A pod then lists the Secret:

```yaml
spec:
  imagePullSecrets:
    - name: registry-login
```

The Secret must be in the same namespace as the pod. A ServiceAccount can also list `imagePullSecrets`, and every pod that uses the ServiceAccount inherits them. A pull error for a private image says `unauthorized` or `denied` in the events, which separates it from a missing tag.

## Digest and policy failures

A reference with a digest fails if the digest does not exist in that repository. A cluster with an admission policy can reject the pod before any pull, and the rejection then appears as an error from `kubectl apply` or as a failed ReplicaSet event, and not as a pod status. For a Deployment, the pod does not exist at all, so check `kubectl -n outpost get events` and `kubectl -n outpost describe replicaset <NAME>`.

The next step after a corrected image is to decide whether to roll back or fix forward.

## Common pitfalls

> [!WARNING]
> A new pod with a bad image does not kill the old pods in a rolling update, so the application may still serve traffic while the rollout is stuck. `imagePullPolicy: Always` makes every restart contact the registry, so a registry outage can stop pods that would otherwise start from the local copy. Clean up with `kubectl -n outpost delete deployment relay-badtag` and `kubectl -n outpost delete secret registry-login`.
