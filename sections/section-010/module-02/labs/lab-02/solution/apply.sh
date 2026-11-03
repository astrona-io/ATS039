#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/solution.yaml"
kubectl -n outpost delete deployment stray --ignore-not-found
kubectl -n outpost rollout status deployment/relay --timeout=180s
revision="$(kubectl -n gitops-repo get configmap desired-state -o jsonpath='{.data.revision}')"
kubectl -n outpost annotate deployment relay gitops.astrona.io/synced-revision="$revision" --overwrite
echo "[solution] Applied."
