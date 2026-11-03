# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know what drift is, how `kubectl diff` and `kubectl apply` work, and what a Kustomize base and overlay are.

The lab starts a single-node kind cluster (Kubernetes 1.35). A ConfigMap in the namespace `gitops-repo` stands in for a Git repository.
