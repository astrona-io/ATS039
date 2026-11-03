# Question

Solve this question on: `terminal`

The stand-in repository is the ConfigMap `desired-state` in the namespace `gitops-repo`. Its key `relay.yaml` is the desired state of the `relay` Deployment in `outpost`. Its key `revision` is the commit that holds that state. Someone changed the live cluster by hand.

1. Make the `relay` Deployment in `outpost` match the `relay.yaml` content of the repository. Do not edit the ConfigMap.

2. Remove the Deployment `stray` from `outpost`. It has the label `app.kubernetes.io/part-of=relay`, but the repository does not list it.

3. Record the revision you applied: set the annotation `gitops.astrona.io/synced-revision` on the `relay` Deployment to the value of the key `revision` in the repository.

Wait until the `relay` Deployment has all its replicas available. `kubectl` already points at the cluster as the cluster administrator.
