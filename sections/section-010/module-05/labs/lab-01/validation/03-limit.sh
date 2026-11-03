#!/usr/bin/env bash
# Check: The container has a memory limit of 128Mi.
set -uo pipefail

limit="$(kubectl -n outpost get deployment prod-relay -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null || true)"
if [ "$limit" != "128Mi" ]; then
  echo "FAIL: memory limit is '${limit}', expected 128Mi"
  exit 1
fi
echo "PASS: memory limit is 128Mi"
