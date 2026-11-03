#!/usr/bin/env bash
# Check: The staging Deployment carries the approval annotation.
set -uo pipefail

value="$(kubectl -n starfleet get deployment scout -o jsonpath='{.metadata.annotations.release\.astrona\.io/approved-by}' 2>/dev/null || true)"
if [ "$value" != "release-manager" ]; then
  echo "FAIL: approved-by is '${value}', expected 'release-manager'"
  exit 1
fi
echo "PASS: staging is approved by ${value}"
