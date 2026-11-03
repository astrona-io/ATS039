#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl -n outpost rollout undo deployment/beacon
kubectl -n outpost rollout status deployment/beacon --timeout=180s
kubectl -n outpost scale deployment/ledger --replicas=2
kubectl -n outpost annotate deployment beacon debug/finding="bad image tag" --overwrite
echo "[solution] Applied."
