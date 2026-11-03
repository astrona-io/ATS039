#!/usr/bin/env bash
# Check: The Service ledger has an endpoint.
set -uo pipefail

path="$(kubectl -n outpost get deployment ledger -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null || true)"
if [ "$path" != "/readyz" ]; then
  echo "FAIL: readiness path is '${path}'"
  exit 1
fi
addresses="$(kubectl -n outpost get endpoints ledger -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null || true)"
if [ -z "$addresses" ]; then
  echo "FAIL: Service ledger has no endpoint addresses"
  exit 1
fi
echo "PASS: ledger has endpoint ${addresses}"
