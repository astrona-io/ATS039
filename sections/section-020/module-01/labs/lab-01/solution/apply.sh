#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

# Fault 1: beacon needs MODE=serve.
kubectl -n starfleet set env deployment/beacon MODE=serve
# Fault 2: relay must refer to the key endpoint-url.
kubectl -n starfleet patch deployment relay --type json \
  -p '[{"op":"replace","path":"/spec/template/spec/containers/0/env/0/valueFrom/configMapKeyRef/key","value":"endpoint-url"}]'
# Fault 3: the Service must select app=lookout.
kubectl -n starfleet patch service lookout -p '{"spec":{"selector":{"app":"lookout"}}}'

for name in beacon relay; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
echo "[solution] Applied."
