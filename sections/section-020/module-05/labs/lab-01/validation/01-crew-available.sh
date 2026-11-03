#!/usr/bin/env bash
# Check: The Deployment crew has five available replicas.
set -uo pipefail

available="$(kubectl -n outpost get deployment crew -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" != "5" ]; then
  echo "FAIL: ${available:-0} replicas are available, expected 5"
  exit 1
fi
echo "PASS: crew has 5 available replicas"
