# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know how a Service selector, a readiness probe and `kubectl rollout` work.

The lab starts a single-node kind cluster (Kubernetes 1.35) with a blue and a green version of `scout` and a `probe` Deployment whose latest update is stuck.
