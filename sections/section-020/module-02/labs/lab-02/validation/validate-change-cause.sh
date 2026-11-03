#!/usr/bin/env bash
# Check: The change cause records the rollback.
set -uo pipefail

cause="$(kubectl -n outpost get deployment relay -o jsonpath='{.metadata.annotations.kubernetes\.io/change-cause}' 2>/dev/null || true)"
if [ "$cause" != "rolled back: image tag not found" ]; then
  echo "FAIL: change-cause is '${cause}'"
  exit 1
fi
echo "PASS: change-cause is '${cause}'"
