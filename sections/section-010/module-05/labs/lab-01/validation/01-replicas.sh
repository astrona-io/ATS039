#!/usr/bin/env bash
# Check: prod-relay has three available replicas.
set -uo pipefail

available="$(kubectl -n outpost get deployment prod-relay -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" != "3" ]; then
  echo "FAIL: ${available:-0} replicas are available, expected 3"
  exit 1
fi
echo "PASS: 3 replicas are available"
