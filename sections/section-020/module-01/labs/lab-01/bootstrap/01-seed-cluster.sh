#!/usr/bin/env bash
# Starting state for the failure diagnosis lab: starfleet plus three faulty workloads.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
for name in scout probe shuttle lookout; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
# beacon and relay are meant to be unhealthy, so they are not waited for.
echo "[lab] Ready."
