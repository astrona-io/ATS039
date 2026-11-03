#!/usr/bin/env bash
# Check: The smoke test Job completed against the relay Service.
set -uo pipefail

succeeded="$(kubectl -n outpost get job smoke-test -o jsonpath='{.status.succeeded}' 2>/dev/null || true)"
if [ "${succeeded:-0}" != "1" ]; then
  echo "FAIL: Job smoke-test has '${succeeded:-0}' successful completions, expected 1"
  exit 1
fi
spec="$(kubectl -n outpost get job smoke-test -o jsonpath='{.spec.template.spec.containers[*].command}' 2>/dev/null || true)"
if [[ "$spec" != *relay* ]]; then
  echo "FAIL: the Job does not request the relay Service"
  exit 1
fi
echo "PASS: smoke-test completed"
