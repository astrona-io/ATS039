---
draft: true
exam_objectives:
  - Debugging
---
# Ingress And Gateway Routing

From outside the cluster, a request reaches a pod through an entry point. The older object is Ingress, which needs an Ingress controller. The newer API is Gateway API, with a Gateway and one or more routes. Both end at a Service, so the checks from the first part apply to the last step.

<!-- astrona:playground:renew -->

## The path

A request from outside takes these steps:

1. The client resolves the host name to the address of the load balancer or node.
2. The controller or gateway receives the request and matches host and path rules.
3. The controller chooses a Service and a port.
4. The Service sends it to a ready pod.

A failure at each step has its own sign. A resolution failure is a DNS record issue. A response `404` from the controller means no rule matched. A response `503` means the rule matched and no ready endpoint exists. A `502` means the pod answered badly or closed the connection.

## Check an Ingress

```sh
kubectl get ingressclass
kubectl -n outpost get ingress
kubectl -n outpost describe ingress web
```

The `describe` output lists the rules, the backends with their endpoints and the events from the controller. Check these fields:

- `ingressClassName` must name an installed class. Without a class and without a default class, no controller picks the object.
- The `ADDRESS` column must show an address after the controller has processed the object.
- Each backend must say `web:80 (10.x.x.x:9898,...)`. A backend with `<error: endpoints "web" not found>` or an empty list names a Service problem.
- The `pathType` decides matching. `Exact` matches only the path, `Prefix` matches by path elements.

A basic Ingress looks like this, with the controller answering for the host `web.example.test`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: outpost
spec:
  ingressClassName: nginx
  rules:
    - host: web.example.test
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  number: 80
```

A cluster created for these labs has no Ingress controller, so applying this object has no effect there until one is installed. Read the controller logs in its own namespace for a real failure.

## Check Gateway API

```sh
kubectl get gatewayclass
kubectl -n outpost get gateway,httproute
kubectl -n outpost describe httproute web
```

Read the `status` conditions. A Gateway needs `Accepted` and `Programmed` to be `True`. A route needs `Accepted` and `ResolvedRefs` to be `True` in the parent status. `ResolvedRefs` is `False` when the backend Service does not exist or a cross-namespace reference is not allowed. These conditions name the cause in the `reason` and `message` fields.

## Probe each step

```sh
kubectl -n outpost exec curl -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' http://web/
curl -s -m 5 -H 'Host: web.example.test' http://NODE_ADDRESS:PORT/
```

The first line tests the Service from inside, and the second sends the host header to the controller from outside. Replace `NODE_ADDRESS` and `PORT` with the address and port where the controller listens. A working first step and a failing second step place the fault in the controller rules or its network path.

## Common pitfalls

> [!WARNING]
> A missing or wrong `ingressClassName` leaves the Ingress unprocessed with no error on the object, so check the class first. TLS errors are separate from routing errors: check that the Secret named in `tls` exists in the same namespace and holds a valid certificate. Do not widen a host rule to a wildcard to make a route work; find out why the host does not match.
