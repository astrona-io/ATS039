#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl -n outpost patch service web --type merge -p '{"spec":{"selector":{"app":"web"},"ports":[{"port":80,"targetPort":9898}]}}'
kubectl -n outpost annotate service web debug/dns="web.outpost.svc.cluster.local" --overwrite
echo "[solution] Applied."
