#!/usr/bin/env bash
# Check: behaviour. shuttle gets HTTP 200 from the Service lookout.
set -uo pipefail

code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -m 5 -w '%{http_code}' http://lookout.starfleet.svc.cluster.local/healthz 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got HTTP '${code}' from lookout, expected 200"
  exit 1
fi

echo "PASS: shuttle reaches lookout (HTTP 200)"
