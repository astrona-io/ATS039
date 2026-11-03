---
draft: true
exam_objectives:
  - Debugging
---
# Summary

A Service sends traffic only to ready pods that match its selector, so the first check is its EndpointSlice. An empty list means a selector typo, unready pods or the wrong namespace. A wrong `targetPort` gives refused connections.

Names resolve through CoreDNS. Test one cluster name and one outside name from a pod in the failing namespace, read `/etc/resolv.conf`, and check that the `kube-dns` pods and endpoints are healthy.

A NetworkPolicy drops traffic silently, so a timeout points at it, while `connection refused` points at the port. The network plugin must enforce policies. Ingress and Gateway failures are placed by status code and conditions: `404` no rule, `503` no ready endpoint, and `Accepted` or `ResolvedRefs` false on the objects.

- Always test from inside, then from outside.
- Test the Service and the pod address separately.
- Check the class of the Ingress first.
- Change shared services such as CoreDNS only after reading logs.

<!-- astrona:playground:destroy -->
