# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` with Kustomize support (`kubectl apply -k`).
- You know how Kustomize overlays, Deployments, Services, Jobs and canary releases with two Deployments behind one Service work.

The lab starts a single-node kind cluster (Kubernetes 1.35). The desired state of `scout` is stored in a ConfigMap that stands in for a Git repository.
