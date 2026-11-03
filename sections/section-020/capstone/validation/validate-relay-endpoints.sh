#!/usr/bin/env bash
# Check: the Service relay has endpoints.
set -uo pipefail

ips="$(kubectl -n starfleet get endpoints relay -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null || true)"
if [ -z "$ips" ]; then
  echo "FAIL: the Service relay has no ready endpoints. Compare its selector with the pod labels"
  exit 1
fi

echo "PASS: the Service relay has endpoints: ${ips}"
