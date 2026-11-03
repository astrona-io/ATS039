#!/usr/bin/env bash
# Check: behaviour. shuttle gets HTTP 200 from relay and version two from dispatch.
set -uo pipefail

code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -m 5 -w '%{http_code}' http://relay.starfleet.svc.cluster.local/healthz 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got HTTP '${code}' from relay, expected 200"
  exit 1
fi
body="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 http://dispatch.starfleet.svc.cluster.local/ 2>/dev/null || true)"
if [[ "$body" != *dispatch-v2* ]]; then
  echo "FAIL: the response of dispatch does not contain dispatch-v2"
  exit 1
fi

echo "PASS: shuttle reaches relay (HTTP 200) and dispatch (dispatch-v2)"
