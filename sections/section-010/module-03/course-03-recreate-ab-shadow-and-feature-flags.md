---
draft: true
exam_objectives:
  - Application Delivery
---
# Recreate, A/B Testing, Shadow And Feature Flags

Rolling, blue-green and canary are not the only ways to release. Some applications cannot run two versions at once, and some teams want to compare versions or test with real traffic before users see a result. This part covers four more approaches, explains when each one fits and what Kubernetes provides for it. It then runs the one that Kubernetes supports directly, the recreate strategy.

## Recreate

The recreate strategy stops all pods of the old version and then starts the pods of the new version. The application is unavailable between the two steps. A team accepts the downtime when two versions cannot share a resource, for example when both would write to the same database schema in incompatible ways. Kubernetes supports it as `spec.strategy.type: Recreate` in a Deployment. The default type is `RollingUpdate`.

<!-- astrona:playground:renew -->

Save this as `deployment-relay-recreate.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay
  namespace: outpost
spec:
  replicas: 2
  strategy:
    type: Recreate
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
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          ports:
            - name: http
              containerPort: 9898
```

Apply it and wait:

```sh
kubectl apply -f deployment-relay-recreate.yaml
kubectl -n outpost rollout status deployment/relay --timeout=120s
```

Then change an environment variable, which creates a new revision, and watch the pods. Start the watch first, in a second terminal:

```sh
kubectl -n outpost get pods -l app=relay -w
kubectl -n outpost set env deployment/relay PODINFO_UI_MESSAGE=v2
```

The watch shows the old pods in the `Terminating` state before any new pod starts. A rolling update would keep some old pods until new ones are ready. Here the Deployment controller scaled the old ReplicaSet to zero and then scaled the new one up.

## A/B testing

A/B testing sends different groups of users to different versions to compare a result, such as a purchase rate. It is a product experiment, and it differs from canary. A canary tests whether a version is safe, using a small share of random traffic. An A/B test selects users by a rule, such as a request header, a cookie, a region or a user identifier, and keeps each user on the same version. Kubernetes Services cannot route by header. An Ingress controller, a Gateway API implementation or a service mesh can, with rules such as "header `x-group: b` goes to the new Service".

## Shadow traffic

A shadow release (also called traffic mirroring) copies real requests to the new version and discards its responses. Users see only the answer of the old version. The team compares the behaviour and the errors of the new version with real load and no user risk. It needs a proxy that can mirror, such as a service mesh. Requests that change data are a problem, because the shadow copy would repeat them, so the shadow version must use test data or a stubbed dependency.

## Feature flags

A feature flag is a condition in the code that turns a feature on or off at run time, from configuration or from a flag service. It separates deploying code from releasing a feature. The new code ships in the image, switched off, and a flag change enables it for a user group, and disables it again in seconds without a new deployment. In Kubernetes the flag can be an environment variable from a ConfigMap, although a change to an environment variable needs a restart of the pods. Flag services avoid the restart.

## Choose a strategy

| Strategy | Two versions at once | Downtime | Needs more than Kubernetes |
| --- | --- | --- | --- |
| Recreate | No | Yes | No |
| Rolling update | Yes | No | No |
| Blue-green | Yes, briefly | No | No, uses two Deployments |
| Canary | Yes | No | Weights need a router; replica ratio does not |
| A/B test | Yes | No | Yes, request-based routing |
| Shadow | Yes | No | Yes, traffic mirroring |

You can now match a requirement to a strategy. The next question is how a tool can make the promote or abort decision from metrics instead of a person.

## Common pitfalls

> [!WARNING]
> Recreate causes downtime by design. A canary built from replica counts gives an approximate share only. A/B tests need a stable assignment, otherwise a user flips between versions. Feature flags left in the code after a launch become hidden paths that nobody tests.
