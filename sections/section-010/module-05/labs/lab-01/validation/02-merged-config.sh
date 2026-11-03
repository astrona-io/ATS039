#!/usr/bin/env bash
# Check: The generated ConfigMap of prod-relay has MESSAGE production.
set -uo pipefail

name="$(kubectl -n outpost get deployment prod-relay -o jsonpath='{.spec.template.spec.containers[0].env[0].valueFrom.configMapKeyRef.name}' 2>/dev/null || true)"
case "$name" in
  prod-relay-config-*) ;;
  *) echo "FAIL: the ConfigMap reference is '${name}'"; exit 1 ;;
esac
msg="$(kubectl -n outpost get configmap "$name" -o jsonpath='{.data.MESSAGE}' 2>/dev/null || true)"
if [ "$msg" != "production" ]; then
  echo "FAIL: MESSAGE is '${msg}', expected production"
  exit 1
fi
echo "PASS: ${name} has MESSAGE production"
