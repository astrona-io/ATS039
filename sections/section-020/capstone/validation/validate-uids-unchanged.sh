#!/usr/bin/env bash
# Check: the three Deployments were repaired in place, not deleted and recreated.
set -uo pipefail

for name in dispatch beacon relay; do
  expected="$(kubectl -n lab-meta get configmap deployment-uids -o jsonpath="{.data.${name}}" 2>/dev/null || true)"
  actual="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.metadata.uid}' 2>/dev/null || true)"
  if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
    echo "FAIL: the Deployment ${name} was deleted and recreated. Repair it in place"
    exit 1
  fi
done

echo "PASS: all three Deployments are the original objects"
