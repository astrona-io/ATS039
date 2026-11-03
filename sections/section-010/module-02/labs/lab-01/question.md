# Question

Solve this question on: `terminal`

The desired state of the `scout` application is stored in the ConfigMap `desired-state` in the namespace `gitops-repo`. It stands in for a Git repository: the key `scout.yaml` holds the Deployment for `starfleet`, and the key `base-deployment.yaml` holds a base Deployment for Kustomize. Someone changed the live `scout` Deployment in `starfleet` by hand and created a Deployment that is not in the repository.

1. Find the differences between the manifest `scout.yaml` and the live cluster. Correct the cluster so that `scout` in `starfleet` matches the repository, and wait until all replicas are available.

2. Delete the Deployment in `starfleet` that the repository does not list. Do not delete `scout` or `shuttle`.

3. Do not edit the ConfigMap `desired-state`. The repository is the source of truth.

4. Build a Kustomize overlay on top of the base in `base-deployment.yaml` and apply it with `kubectl apply -k`. The result must be the Deployment `scout` in the namespace `outpost` with 2 replicas, the image `ghcr.io/stefanprodan/podinfo:6.15.0`, and the label `env: production` on the Deployment and on its pod template. Wait until both replicas are available.

`kubectl` already points at the cluster as the cluster administrator. Work in any empty directory.
