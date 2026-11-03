#!/usr/bin/env bash
# Starting state for the lab: a Deployment that reads a mutable ConfigMap and has no Secret
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n outpost rollout status deployment/ledger --timeout=180s
echo "[lab] Ready."
