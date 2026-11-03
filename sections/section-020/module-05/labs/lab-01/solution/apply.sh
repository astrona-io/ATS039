#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl -n outpost patch resourcequota small --type merge -p '{"spec":{"hard":{"pods":"10"}}}'
kubectl -n outpost rollout status deployment/crew --timeout=180s
kubectl -n outpost delete pod wanderer --wait=true
kubectl -n outpost run wanderer --image=busybox:1.37.0 --restart=Never -- sleep 3600
kubectl -n outpost wait --for=condition=Ready pod/wanderer --timeout=180s
kubectl -n outpost annotate deployment crew debug/finding="exceeded quota" --overwrite
echo "[solution] Applied."
