#!/usr/bin/env bash
# Starting state for the lab: beacon updated to a missing image tag, and ledger scaled away from its declared replicas
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n outpost rollout status deployment/beacon --timeout=180s
kubectl -n outpost set image deployment/beacon beacon=ghcr.io/stefanprodan/podinfo:6.15.0-missing
sleep 10
echo "[lab] Ready."
