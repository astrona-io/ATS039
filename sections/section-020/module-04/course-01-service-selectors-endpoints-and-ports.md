---
draft: true
exam_objectives:
  - Debugging
---
# Service Selectors, Endpoints And Ports

Most Service faults are one of three: the selector matches no pod, the port in the Service does not match the port in the container, or the pods are not ready. All three show in the endpoints of the Service.

<!-- astrona:playground:renew -->

Create a Deployment and a Service whose selector has a typo:

```sh
kubectl -n outpost create deployment web --image=ghcr.io/stefanprodan/podinfo:6.15.0 --replicas=2 --port=9898
kubectl -n outpost wait --for=condition=Available deployment/web --timeout=120s
kubectl -n outpost create service clusterip web --tcp=80:9898
kubectl -n outpost set selector service web app=webb
```

## Check the endpoints

```sh
kubectl -n outpost get service web -o wide
kubectl -n outpost get endpointslices -l kubernetes.io/service-name=web
kubectl -n outpost describe service web
```

An EndpointSlice lists the pod addresses that back a Service. With the typo, the list is empty and `describe` shows `Endpoints: <none>`. A Service with no endpoints accepts connections to its address and then fails them, so the symptom is a timeout or a connection refused.

Compare the selector with the pod labels:

```sh
kubectl -n outpost get service web -o jsonpath='{.spec.selector}'
kubectl -n outpost get pods --show-labels
```

The pods carry `app=web` and the selector asks for `app=webb`. Fix the selector:

```sh
kubectl -n outpost set selector service web app=web
kubectl -n outpost get endpointslices -l kubernetes.io/service-name=web
```

The addresses appear.

## Check the ports

A Service has two port numbers. `port` is what clients use on the Service. `targetPort` is the port in the container, and it defaults to the value of `port`. If the application listens on 9898 and the Service sends to 80, the connection is refused:

```sh
kubectl -n outpost get service web -o jsonpath='{.spec.ports[0]}'
```

In the output, `targetPort` must match the container port. A named port, such as `targetPort: http`, resolves against the port names in the pod.

## Check readiness

Only ready pods are listed as endpoints. A pod whose readiness probe fails is removed from the Service without a restart. List `kubectl get pods` and read the `READY` column, then `kubectl describe pod` for probe failures.

## Test from inside

```sh
kubectl -n outpost run curl --image=curlimages/curl:8.11.1 --restart=Never --command -- sleep 3600
kubectl -n outpost wait --for=condition=Ready pod/curl --timeout=120s
kubectl -n outpost exec curl -- curl -s -m 5 http://web/healthz
```

Test the Service by name, then the pod address directly, to see which layer fails. A request to the pod address that works while the Service fails points to the Service.

## Common pitfalls

> [!WARNING]
> A Service in a different namespace has a different name: use `web.outpost` or the full `web.outpost.svc.cluster.local` from another namespace. Do not use the Service cluster address from outside the cluster; it is only routed inside. A Service of type `ExternalName` has no selector and no endpoints by design, so an empty endpoint list is not a fault there.
