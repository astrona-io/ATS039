#!/usr/bin/env bash
# Check: The strategy is Recreate and the history limit is 5.
set -uo pipefail

type="$(kubectl -n outpost get deployment relay -o jsonpath='{.spec.strategy.type}' 2>/dev/null || true)"
limit="$(kubectl -n outpost get deployment relay -o jsonpath='{.spec.revisionHistoryLimit}' 2>/dev/null || true)"
if [ "$type" != "Recreate" ] || [ "$limit" != "5" ]; then
  echo "FAIL: strategy is '${type}' and revisionHistoryLimit is '${limit}'"
  exit 1
fi
echo "PASS: Recreate with revisionHistoryLimit 5"
