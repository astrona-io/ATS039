#!/usr/bin/env bash
# Starting state for the lab: three faulty workloads in outpost: gauge, ledger and harbor
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
true
echo "[lab] Ready."
