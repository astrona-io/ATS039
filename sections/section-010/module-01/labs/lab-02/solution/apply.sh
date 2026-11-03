#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/solution.yaml"
kubectl -n starfleet wait --for=condition=complete job/gate-checks --timeout=120s
kubectl -n starfleet annotate deployment scout release.astrona.io/approved-by=release-manager --overwrite
kubectl -n outpost rollout status deployment/scout --timeout=180s
echo "[solution] Applied."
