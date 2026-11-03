#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl -n starfleet patch deployment lookout --type json \
  -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/readyz"}]'
kubectl -n starfleet rollout status deployment/lookout --timeout=180s
kubectl -n starfleet annotate deployment lookout kubernetes.io/change-cause="fix readiness path to /readyz" --overwrite
echo "[solution] Applied."
