#!/usr/bin/env bash
# Check: The relay Deployment matches the repository.
set -uo pipefail

replicas="$(kubectl -n outpost get deployment relay -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ "$replicas" != "2" ]; then
  echo "FAIL: relay has '${replicas}' replicas, the repository says 2"
  exit 1
fi
available="$(kubectl -n outpost get deployment relay -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" != "2" ]; then
  echo "FAIL: ${available:-0} replicas are available, expected 2"
  exit 1
fi
echo "PASS: relay runs 2 available replicas as the repository says"
