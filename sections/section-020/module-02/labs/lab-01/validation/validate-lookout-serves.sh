#!/usr/bin/env bash
# Check: behaviour. shuttle gets version two from the Service lookout.
set -uo pipefail

body="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -m 5 -w '\n%{http_code}' http://lookout.starfleet.svc.cluster.local/ 2>/dev/null || true)"
code="${body##*$'\n'}"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got HTTP '${code}' from lookout, expected 200"
  exit 1
fi
if [[ "$body" != *lookout-v2* ]]; then
  echo "FAIL: the response of lookout does not contain lookout-v2"
  exit 1
fi

echo "PASS: shuttle gets HTTP 200 and lookout-v2 from lookout"
