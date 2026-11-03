#!/usr/bin/env bash
# Starting state for the lab: a stand-in repository, a drifted relay and a stray Deployment
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n outpost rollout status deployment/relay --timeout=180s
echo "[lab] Ready."
