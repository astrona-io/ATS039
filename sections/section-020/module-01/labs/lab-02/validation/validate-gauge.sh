#!/usr/bin/env bash
# Check: gauge uses the path /healthz and is available.
set -uo pipefail

path="$(kubectl -n outpost get deployment gauge -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}' 2>/dev/null || true)"
if [ "$path" != "/healthz" ]; then
  echo "FAIL: liveness path is '${path}'"
  exit 1
fi
available="$(kubectl -n outpost get deployment gauge -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" -lt 1 ]; then
  echo "FAIL: gauge has no available replica"
  exit 1
fi
echo "PASS: gauge liveness path is /healthz and the replica is available"
