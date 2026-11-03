#!/usr/bin/env bash
# Check: the Service lookout has an endpoint behind it.
set -uo pipefail

ips="$(kubectl -n starfleet get endpoints lookout -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null || true)"
if [ -z "$ips" ]; then
  echo "FAIL: the Service lookout has no ready endpoints. Compare its selector with the pod labels"
  exit 1
fi

echo "PASS: the Service lookout has endpoints: ${ips}"
