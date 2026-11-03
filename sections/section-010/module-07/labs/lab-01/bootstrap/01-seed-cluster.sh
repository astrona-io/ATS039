#!/usr/bin/env bash
# Starting state for the lab: a Deployment with default rollout settings and no budget
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n outpost rollout status deployment/dock --timeout=180s
echo "[lab] Ready."
