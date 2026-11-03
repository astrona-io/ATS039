#!/usr/bin/env bash
# Check: blue keeps running for a quick return, and green is fully available.
set -uo pipefail

for name in scout-blue scout-green; do
  available="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
  if [ "${available:-0}" -lt 1 ]; then
    echo "FAIL: Deployment ${name} has '${available:-0}' available replicas, expected at least 1"
    exit 1
  fi
done

echo "PASS: blue and green are both available"
