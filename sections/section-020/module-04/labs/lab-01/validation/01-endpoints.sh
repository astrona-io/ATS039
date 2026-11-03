#!/usr/bin/env bash
# Check: The Service web has two endpoint addresses.
set -uo pipefail

addrs="$(kubectl -n outpost get endpointslices -l kubernetes.io/service-name=web -o jsonpath='{.items[*].endpoints[*].addresses[*]}' 2>/dev/null || true)"
count="$(echo "$addrs" | wc -w | tr -d ' ')"
if [ "$count" != "2" ]; then
  echo "FAIL: the Service has ${count} endpoint addresses, expected 2"
  exit 1
fi
echo "PASS: the Service has 2 endpoint addresses"
