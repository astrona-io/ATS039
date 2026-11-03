# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You can diagnose crash loops, configuration errors, empty endpoints and stalled rollouts from logs, events, conditions and status fields.

The lab starts a single-node kind cluster (Kubernetes 1.35) with three workloads that do not work: `dispatch`, `beacon` and `relay`.
