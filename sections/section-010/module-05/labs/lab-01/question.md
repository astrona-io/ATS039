# Question

Solve this question on: `terminal`

A Kustomize base is in `/tmp/ats039-lab/kustomize/base`. It defines a Deployment `relay` with one replica and a generated ConfigMap `relay-config` with `MESSAGE=base`. The directory `/tmp/ats039-lab/kustomize/overlays/production` is empty.

Create a `kustomization.yaml` in the production overlay directory and apply it with `kubectl apply -k`, so that:

1. The resources use the namespace `outpost` and the name prefix `prod-`, so the Deployment is called `prod-relay`.

2. `prod-relay` runs three replicas.

3. The generated ConfigMap has `MESSAGE=production`. Change it with the generator and the behavior `merge`; do not edit the base.

4. The container has the memory limit `128Mi`, set with a patch.

`kubectl` already points at the cluster as the cluster administrator.
