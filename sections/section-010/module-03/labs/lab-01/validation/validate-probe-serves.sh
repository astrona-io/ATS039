#!/usr/bin/env bash
# Check: behaviour. shuttle still gets HTTP 200 from the probe Service.
set -uo pipefail

code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -m 5 -w '%{http_code}' http://probe.starfleet.svc.cluster.local/status/200 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got HTTP '${code}' from probe, expected 200"
  exit 1
fi

echo "PASS: shuttle reaches probe (HTTP 200)"
