---
draft: true
exam_objectives:
  - Debugging
---
# DNS And CoreDNS

Pods find Services by name, and the name is resolved by DNS. The cluster DNS service is CoreDNS, which runs as pods in the namespace `kube-system`. A name that does not resolve gives errors such as `NXDOMAIN` or `could not resolve host`, which look like network failures.

<!-- astrona:playground:renew -->

## Names and search paths

A Service `web` in namespace `outpost` has the full name `web.outpost.svc.cluster.local`. Every pod gets a resolver file with search domains, so short names work:

```sh
kubectl -n outpost run dns --image=busybox:1.37.0 --restart=Never -- sleep 3600
kubectl -n outpost wait --for=condition=Ready pod/dns --timeout=120s
kubectl -n outpost exec dns -- cat /etc/resolv.conf
```

The file lists the cluster DNS address as `nameserver`, search domains such as `outpost.svc.cluster.local`, `svc.cluster.local` and `cluster.local`, and the option `ndots:5`. With `ndots:5` a name with fewer than five dots is tried with each search domain first. That is why `web` resolves in the same namespace, why a name from another namespace needs `web.outpost`, and why external names make several failed lookups before they succeed.

## Test resolution

```sh
kubectl -n outpost exec dns -- nslookup kubernetes.default
kubectl -n outpost exec dns -- nslookup web.outpost.svc.cluster.local
kubectl -n outpost exec dns -- nslookup example.com
```

Test one name inside the cluster and one outside. If the cluster name fails and the outside name works, the problem is the name or the Service. If both fail, the problem is the DNS service or the path to it. Some minimal images have no `nslookup`; use an ephemeral debug container from the previous module.

## Check CoreDNS

```sh
kubectl -n kube-system get pods -l k8s-app=kube-dns
kubectl -n kube-system logs -l k8s-app=kube-dns --tail=50
kubectl -n kube-system get configmap coredns -o yaml
kubectl -n kube-system get service kube-dns
```

The pods must be ready and the Service `kube-dns` must have endpoints. The `Corefile` in the ConfigMap lists the plugins. The plugin `kubernetes` answers cluster names and `forward` sends other names to the upstream resolvers. Errors in the logs about timeouts to upstream servers explain failures of outside names.

## Headless Services and Pod names

A Service with `clusterIP: None` is headless. A lookup of its name returns the addresses of the pods, not one Service address. A StatefulSet with a headless Service gives each pod a stable name such as `db-0.db.outpost.svc.cluster.local`.

## Custom resolver settings

A pod can set `dnsPolicy` and `dnsConfig`. With `dnsPolicy: Default` the pod uses the node resolver and cannot resolve cluster names. With `ClusterFirst`, which is the default, cluster names go to CoreDNS. A pod on the host network uses `ClusterFirstWithHostNet` to keep cluster names working.

## Common pitfalls

> [!WARNING]
> Do not test DNS only from your own computer: it uses a different resolver than a pod. Run the lookup inside a pod in the same namespace as the failing workload, because search domains differ per namespace. A name that resolved a moment ago and no longer does may be a Service that was deleted, so list the Services before restarting CoreDNS. Restarting CoreDNS is a change on a shared service; check the logs first.
