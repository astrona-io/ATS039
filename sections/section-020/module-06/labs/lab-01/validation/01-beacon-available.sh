#!/usr/bin/env bash
# Check: The Deployment beacon has two available replicas.
set -uo pipefail

available="$(kubectl -n outpost get deployment beacon -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" != "2" ]; then
  echo "FAIL: ${available:-0} replicas are available, expected 2"
  exit 1
fi
echo "PASS: beacon has 2 available replicas"
