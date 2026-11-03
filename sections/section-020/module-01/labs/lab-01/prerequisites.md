# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You can read pod states, logs, events and endpoints with `kubectl get`, `kubectl describe` and `kubectl logs`.

The lab starts a single-node kind cluster (Kubernetes 1.35) with three workloads that do not work: `beacon`, `relay` and `lookout`.
