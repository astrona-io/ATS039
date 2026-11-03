# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know how a Deployment, a ReplicaSet and a readiness probe work together during a rollout.

The lab starts a single-node kind cluster (Kubernetes 1.35) with a Deployment `lookout` whose version two release is stuck.
