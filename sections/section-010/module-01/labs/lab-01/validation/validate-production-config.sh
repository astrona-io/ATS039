#!/usr/bin/env bash
# Check: production has its own configuration, and the Deployment reads it.
set -uo pipefail

message="$(kubectl -n outpost get configmap scout-config -o jsonpath='{.data.PODINFO_UI_MESSAGE}' 2>/dev/null || true)"
if [ "$message" != "scout-production" ]; then
  echo "FAIL: ConfigMap scout-config in outpost has PODINFO_UI_MESSAGE='${message}', expected 'scout-production'"
  exit 1
fi
refs="$(kubectl -n outpost get deployment scout -o jsonpath='{.spec.template.spec.containers[0].envFrom[*].configMapRef.name}' 2>/dev/null || true)"
if [[ "$refs" != *scout-config* ]]; then
  echo "FAIL: the scout Deployment in outpost does not read the ConfigMap scout-config with envFrom"
  exit 1
fi

echo "PASS: production reads its own ConfigMap"
