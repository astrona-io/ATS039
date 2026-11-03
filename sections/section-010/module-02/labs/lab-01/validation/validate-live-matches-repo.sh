#!/usr/bin/env bash
# Check: live scout in starfleet equals the repository (replicas and message).
set -uo pipefail

replicas="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ "$replicas" != "2" ]; then
  echo "FAIL: scout in starfleet has spec.replicas '${replicas}', the repository says 2"
  exit 1
fi
message="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="PODINFO_UI_MESSAGE")].value}' 2>/dev/null || true)"
if [ "$message" != "scout-v1" ]; then
  echo "FAIL: PODINFO_UI_MESSAGE is '${message}', the repository says 'scout-v1'"
  exit 1
fi
available="$(kubectl -n starfleet get deployment scout -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" != "2" ]; then
  echo "FAIL: scout has '${available:-0}' available replicas, expected 2"
  exit 1
fi

echo "PASS: live scout matches the repository"
