#!/usr/bin/env bash
# Check: the Job release-check completed and targets the production Service.
set -uo pipefail

succeeded="$(kubectl -n outpost get job release-check -o jsonpath='{.status.succeeded}' 2>/dev/null || true)"
if [ "${succeeded:-0}" != "1" ]; then
  echo "FAIL: Job release-check in outpost has '${succeeded:-0}' successful completions, expected 1"
  exit 1
fi
spec="$(kubectl -n outpost get job release-check -o jsonpath='{.spec.template.spec.containers[*].command}{.spec.template.spec.containers[*].args}' 2>/dev/null || true)"
if [[ "$spec" != *scout* ]]; then
  echo "FAIL: the Job does not request the scout Service"
  exit 1
fi

echo "PASS: release-check completed against the production Service"
