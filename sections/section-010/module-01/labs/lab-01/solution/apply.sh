#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/solution.yaml"
kubectl -n outpost rollout status deployment/scout --timeout=180s
kubectl -n outpost wait --for=condition=complete job/release-check --timeout=120s
echo "[solution] Applied."
