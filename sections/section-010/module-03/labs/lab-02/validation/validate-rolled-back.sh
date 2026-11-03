#!/usr/bin/env bash
# Check: relay runs MODE=v1 with two available replicas.
set -uo pipefail

mode="$(kubectl -n outpost get deployment relay -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="MODE")].value}' 2>/dev/null || true)"
if [ "$mode" != "v1" ]; then
  echo "FAIL: MODE is '${mode}', expected v1"
  exit 1
fi
available="$(kubectl -n outpost get deployment relay -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" != "2" ]; then
  echo "FAIL: ${available:-0} replicas are available, expected 2"
  exit 1
fi
echo "PASS: relay runs MODE=v1 with 2 available replicas"
