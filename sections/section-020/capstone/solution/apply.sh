#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

# dispatch: fix the readiness path forward.
kubectl -n starfleet patch deployment dispatch --type json \
  -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/readyz"}]'
kubectl -n starfleet rollout status deployment/dispatch --timeout=180s
kubectl -n starfleet annotate deployment dispatch kubernetes.io/change-cause="fix readiness path to /readyz" --overwrite

# beacon: correct the ConfigMap value, then restart so the new value is read.
kubectl -n starfleet patch configmap beacon-config --type merge -p '{"data":{"mode":"serve"}}'
kubectl -n starfleet rollout restart deployment/beacon
kubectl -n starfleet rollout status deployment/beacon --timeout=180s

# relay: fix the Service selector.
kubectl -n starfleet patch service relay -p '{"spec":{"selector":{"app":"relay"}}}'
echo "[solution] Applied."
