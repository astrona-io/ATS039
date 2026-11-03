#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl -n outpost patch deployment relay --type merge -p '{"spec":{"strategy":{"type":"Recreate","rollingUpdate":null},"revisionHistoryLimit":5}}'
kubectl -n outpost rollout undo deployment/relay --to-revision=1
kubectl -n outpost rollout status deployment/relay --timeout=180s
kubectl -n outpost annotate deployment relay kubernetes.io/change-cause="rolled back to v1" --overwrite
echo "[solution] Applied."
