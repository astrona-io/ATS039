#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n outpost rollout undo deployment/relay
kubectl -n outpost rollout status deployment/relay --timeout=180s
kubectl -n outpost annotate deployment relay kubernetes.io/change-cause="rolled back: image tag not found" --overwrite
kubectl apply -f "$DIR/solution.yaml"
kubectl -n outpost wait --for=condition=complete job/smoke-test --timeout=120s
echo "[solution] Applied."
