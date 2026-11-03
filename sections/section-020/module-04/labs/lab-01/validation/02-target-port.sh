#!/usr/bin/env bash
# Check: The Service sends traffic to port 9898.
set -uo pipefail

tp="$(kubectl -n outpost get service web -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null || true)"
if [ "$tp" != "9898" ]; then
  echo "FAIL: targetPort is '${tp}', expected 9898"
  exit 1
fi
echo "PASS: targetPort is 9898"
