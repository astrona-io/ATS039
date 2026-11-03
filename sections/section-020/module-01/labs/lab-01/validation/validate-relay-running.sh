#!/usr/bin/env bash
# Check: relay starts, so its ConfigMap reference is valid.
set -uo pipefail

ready="$(kubectl -n starfleet get deployment relay -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "${ready:-0}" != "1" ]; then
  reason="$(kubectl -n starfleet get pods -l app=relay -o jsonpath='{.items[0].status.containerStatuses[0].state.waiting.reason}' 2>/dev/null || true)"
  echo "FAIL: relay has '${ready:-0}' ready replicas (container waiting reason: '${reason}')"
  exit 1
fi
value="$(kubectl -n starfleet exec deploy/relay -- sh -c 'echo "$ENDPOINT"' 2>/dev/null || true)"
if [ -z "$value" ]; then
  echo "FAIL: the variable ENDPOINT in relay is empty"
  exit 1
fi

echo "PASS: relay runs and ENDPOINT is '${value}'"
