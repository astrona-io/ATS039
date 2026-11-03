---
draft: true
exam_objectives:
  - Debugging
---
# Configuration, Dependencies And Request Failures

A pod can be `Running` and `Ready` and still fail its users. The process starts, but a setting is wrong, a dependency cannot be reached, or a request returns an error status. This part follows those failures: a missing configuration key, a Service with no endpoints, an HTTP error status, and the steps to reproduce a failing request without touching the live workload.

Separate two failure classes. A process failure means the container does not start or does not stay up; the evidence is the pod state, the exit code and the log. An application response failure means the process runs and answers, but the answer is an error or is missing; the evidence is the HTTP status code, the response body and the log lines that match the request.

## Configuration references

A container can take settings from a ConfigMap, which is an object that stores configuration as key and value pairs. The Deployment refers to a key by name. When the key does not exist, the kubelet refuses to create the container. Save this as `deployment-relay.yaml`. The ConfigMap has the key `endpoint-url`, and the Deployment asks for the key `endpoint`:

<!-- astrona:playground:renew -->

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: relay-config
  namespace: outpost
data:
  endpoint-url: http://probe.starfleet.svc.cluster.local
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay
  namespace: outpost
spec:
  replicas: 1
  selector:
    matchLabels:
      app: relay
  template:
    metadata:
      labels:
        app: relay
    spec:
      containers:
        - name: relay
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "while true; do sleep 30; done"]
          env:
            - name: ENDPOINT
              valueFrom:
                configMapKeyRef:
                  name: relay-config
                  key: endpoint
```

Apply it and read the state:

```sh
kubectl apply -f deployment-relay.yaml
kubectl -n outpost get pods -l app=relay
kubectl -n outpost describe pod -l app=relay
```

The pod shows `CreateContainerConfigError`. The event says that the key `endpoint` was not found in the ConfigMap `relay-config`. The log is empty because no process ran. Fix the reference so it names the real key, and the kubelet creates the container on its next retry:

```sh
kubectl -n outpost patch deployment relay --type json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/env/0/valueFrom/configMapKeyRef/key","value":"endpoint-url"}]'
kubectl -n outpost rollout status deployment/relay --timeout=120s
```

A Secret reference fails in the same way when the Secret or its key is missing. Remember also that environment variables are read once at container start, so a corrected ConfigMap value reaches a running pod only after the pod restarts.

## Dependency access

An application reaches a dependency through a Service name. The Service is an object with a stable name and a label selector; it sends requests to the pods that match the selector and are ready. A Service whose selector matches no pod has no endpoints, and every request to it fails. Save this as `service-lookout.yaml`. The Service selects `app: lookout-api`, but the pods have the label `app: lookout`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lookout
  namespace: outpost
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lookout
  template:
    metadata:
      labels:
        app: lookout
    spec:
      containers:
        - name: lookout
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          ports:
            - name: http
              containerPort: 9898
---
apiVersion: v1
kind: Service
metadata:
  name: lookout
  namespace: outpost
spec:
  selector:
    app: lookout-api
  ports:
    - name: http
      port: 80
      targetPort: http
```

Apply it and send a request from `drifter`. The `-m 5` flag limits the request to five seconds:

```sh
kubectl apply -f service-lookout.yaml
kubectl -n outpost rollout status deployment/lookout --timeout=120s
kubectl -n outpost exec deploy/drifter -- curl -sS -m 5 http://lookout.outpost.svc.cluster.local/healthz
kubectl -n outpost get endpoints lookout
```

The request fails with a connection error, although the pod is ready, and the endpoints list is empty. The DNS name resolved, because the Service exists, but no pod backs it. Compare the selector with the pod labels using `kubectl -n outpost get service lookout -o jsonpath='{.spec.selector}'` and `kubectl -n outpost get pods --show-labels`. Fix the selector:

```sh
kubectl -n outpost patch service lookout -p '{"spec":{"selector":{"app":"lookout"}}}'
kubectl -n outpost exec deploy/drifter -- curl -sS -m 5 http://lookout.outpost.svc.cluster.local/healthz
```

The failure moves with the layer: a wrong name fails in DNS, a wrong selector leaves no endpoints, a wrong port refuses the connection and a slow dependency times out. Note which of these the error text shows.

## Status codes and correlation

The `probe` Service in `starfleet` runs `go-httpbin`, which returns any status code you request. Ask for a `503`:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc.cluster.local/status/503
```

A `4xx` code says that the request was wrong or not allowed, and a `5xx` code says that the server failed to answer a valid request. A `503` often means the server or a dependency is unavailable. To follow one request through several components, give it a request identifier in a header. Each component can copy the header into its logs, so a search for the identifier finds every line about that request. The endpoint `/headers` of `go-httpbin` echoes what it received:

```sh
kubectl -n starfleet exec deploy/shuttle -- curl -s -H 'X-Request-Id: req-4711' http://probe.starfleet.svc.cluster.local/headers
```

The echo shows `X-Request-Id` with the value `req-4711`. In a real system, the same identifier appears in the log of every service that handled the request, which is how you tie an error in a backend to the user request that caused it.

## Reproduce safely

Reproduce a failure from the outside first. A throwaway pod gives a clean client in the same namespace and leaves the live workload alone:

```sh
kubectl -n outpost run probe-client --rm -it --restart=Never --image=curlimages/curl:8.22.0 -- curl -sS -m 5 http://lookout.outpost.svc.cluster.local/healthz
```

`kubectl port-forward` opens a local port to one pod or Service, which lets you test a single pod without changing the Service. When you need a shell next to a running container, `kubectl debug -it <pod> --image=curlimages/curl:8.22.0 --target=<container> -- sh` adds an ephemeral container to the pod. Use read-only commands first. Changing configuration or restarting pods during an investigation destroys the evidence and can change the failure.

Clean up:

```sh
kubectl -n outpost delete deployment relay lookout
kubectl -n outpost delete service lookout
```

## Common pitfalls

> [!WARNING]
> A ready pod does not prove that its Service has endpoints. A Service name that resolves does not prove that a pod backs it. A corrected ConfigMap value does not reach environment variables of running pods until they restart. Testing a fix on the live workload before you have reproduced the failure removes the evidence.
