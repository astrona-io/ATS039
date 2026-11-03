---
draft: true
exam_objectives:
  - Debugging
---
# Debugging Services, DNS And Ingress

A request that fails between two parts of a cluster has few places to fail: the name does not resolve, the Service has no endpoints, the port is wrong, a policy blocks the traffic, or the entry point from outside does not route. This module walks that path in order and gives one check for each step.

The module has four parts. The first covers Service selectors, endpoints and ports. The second covers DNS and CoreDNS. The third covers NetworkPolicy. The fourth covers Ingress and Gateway routing.

## Learning goals

After this module you can:

- Find a Service with no endpoints and name the cause.
- Test name resolution from inside a pod and read CoreDNS state.
- Recognise when a NetworkPolicy blocks traffic.
- Trace a request from an Ingress or Gateway to a pod.

## Before you start

You need Services, labels and selectors, and the basics of `kubectl get` and `kubectl describe`. A Service is a stable name and address that sends traffic to the pods its selector matches.

The playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | `scout` (two replicas, `podinfo`, port 9898), `probe`, `shuttle` (a `curl` client) |
| `outpost` | `drifter`. You create the example resources here |

Launch your playground now and keep it running next to you while you read:

<!-- astrona:playground -->
