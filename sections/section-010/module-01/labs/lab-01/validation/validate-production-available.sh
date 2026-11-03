#!/usr/bin/env bash
# Check: two production replicas are available and the Service answers.
set -uo pipefail

available="$(kubectl -n outpost get deployment scout -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" -lt 2 ]; then
  echo "FAIL: scout in outpost has '${available:-0}' available replicas, expected 2"
  exit 1
fi
code="$(kubectl -n outpost exec deploy/drifter -- curl -s -o /dev/null -m 5 -w '%{http_code}' http://scout.outpost.svc.cluster.local/healthz 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: drifter got HTTP '${code}' from the scout Service in outpost, expected 200"
  exit 1
fi

echo "PASS: production scout has 2 available replicas and answers HTTP 200"
