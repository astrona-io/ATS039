---
draft: true
exam_objectives:
  - Debugging
---
# NetworkPolicy Blocks

A NetworkPolicy limits which pods can send traffic to or receive traffic from a pod. When no policy selects a pod, all traffic is allowed. When a policy selects a pod, only the traffic the policies allow is let through for the direction the policy covers. A blocked connection is silent: it times out, with no refusal and no event.

The cluster network plugin must enforce policies. A cluster whose plugin does not enforce them accepts the objects and ignores them. The default network of `kind` does not enforce policies, so on that cluster a policy has no effect and the commands in this part show the objects only.

<!-- astrona:playground:renew -->

## A policy that allows only some clients

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-allow-clients
  namespace: outpost
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: client
      ports:
        - port: 9898
```

Save it as `policy.yaml` and apply it. After this, pods labelled `app=web` accept traffic on port 9898 only from pods labelled `role=client` in the same namespace. Everything else to those pods is dropped.

```sh
kubectl apply -f policy.yaml
kubectl -n outpost get networkpolicy
kubectl -n outpost describe networkpolicy web-allow-clients
```

The `describe` output lists which pods are selected and what is allowed. Read it as: the pods in `PodSelector`, the allowed `Ingress` sources and the ports.

## Debugging a blocked connection

1. Find the policies that select the target pod. List all policies in the namespace and compare each `podSelector` with the pod labels.
2. Read what they allow. Check the source labels, the namespace selector and the port.
3. Compare the client pod labels with the allowed sources.
4. Test from an allowed client and from a denied one.

```sh
kubectl -n outpost label pod curl role=client --overwrite
kubectl -n outpost exec curl -- curl -s -m 5 http://web/healthz
```

If the connection works after the label is added and not before, the policy was the cause.

## Common traps

- A policy with an empty `podSelector: {}` selects every pod in the namespace.
- `from` entries in one list item with both `namespaceSelector` and `podSelector` mean AND. Two separate list items mean OR.
- A policy that covers Egress blocks DNS unless it allows the cluster DNS pods on port 53 for both UDP and TCP.
- Allowing traffic to a pod does not allow the reply direction to be a new connection; replies to allowed connections are always allowed.
- Traffic to a Service address is translated to a pod address before the policy applies, so write policies against pods, not Service addresses.
- A default-deny policy is a policy with an empty `podSelector` and no rules. Add allow policies after it.

## Common pitfalls

> [!WARNING]
> A timeout is the typical sign of a NetworkPolicy block, while `connection refused` means the host answered and nothing listens on the port. Treat these differently. Do not delete a policy in production to see if it fixes the problem; test with a labelled client in a copy of the workload, or read the policy as shown. Remember that some plugins offer their own policy kinds that are not shown by `kubectl get networkpolicy`.
