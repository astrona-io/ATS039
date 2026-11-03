#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl -n outpost patch deployment mill --type merge -p '{"spec":{"template":{"spec":{"volumes":[{"name":"data","emptyDir":{}}],"containers":[{"name":"mill","volumeMounts":[{"name":"data","mountPath":"/data"}]}]}}}}'
kubectl -n outpost rollout status deployment/mill --timeout=180s
kubectl -n outpost debug sleeper --image=busybox:1.37.0 --container=inspector --target=sleeper -- sleep 3600
kubectl -n outpost annotate deployment mill debug/finding="read-only root filesystem" --overwrite
echo "[solution] Applied."
