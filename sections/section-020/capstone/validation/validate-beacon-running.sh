#!/usr/bin/env bash
# Check: beacon runs because the ConfigMap value is corrected, and still reads it from there.
set -uo pipefail

mode="$(kubectl -n starfleet get configmap beacon-config -o jsonpath='{.data.mode}' 2>/dev/null || true)"
if [ "$mode" != "serve" ]; then
  echo "FAIL: the key mode in the ConfigMap beacon-config is '${mode}', the process only keeps running with 'serve'"
  exit 1
fi
ref="$(kubectl -n starfleet get deployment beacon -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="MODE")].valueFrom.configMapKeyRef.name}' 2>/dev/null || true)"
if [ "$ref" != "beacon-config" ]; then
  echo "FAIL: beacon must keep reading MODE from the ConfigMap beacon-config (found '${ref}')"
  exit 1
fi
ready="$(kubectl -n starfleet get deployment beacon -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "${ready:-0}" != "1" ]; then
  echo "FAIL: beacon has '${ready:-0}' ready replicas. A corrected ConfigMap value reaches a container only when it starts again"
  exit 1
fi

echo "PASS: beacon runs with the corrected ConfigMap value"
