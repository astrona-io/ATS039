#!/usr/bin/env bash
# Starting state for the lab: a web Deployment and a Service with a wrong selector and target port
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n outpost wait --for=condition=Available deployment/web --timeout=180s
echo "[lab] Ready."
