#!/usr/bin/env bash
# Starting state for the lab: a tight quota, a Deployment that hits it and a pod with a bad node selector
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
sleep 15
echo "[lab] Ready."
