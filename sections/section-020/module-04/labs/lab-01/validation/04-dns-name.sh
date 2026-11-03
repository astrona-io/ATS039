#!/usr/bin/env bash
# Check: The Service records its full DNS name in an annotation.
set -uo pipefail

n="$(kubectl -n outpost get service web -o jsonpath='{.metadata.annotations.debug/dns}' 2>/dev/null || true)"
if [ "$n" != "web.outpost.svc.cluster.local" ]; then
  echo "FAIL: debug/dns is '${n}'"
  exit 1
fi
echo "PASS: DNS name recorded"
