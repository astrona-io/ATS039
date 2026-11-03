#!/usr/bin/env bash
# Starting state for the lab: a mill Deployment that cannot write and a sleeper pod
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n outpost wait --for=condition=Ready pod/sleeper --timeout=180s
sleep 10
echo "[lab] Ready."
