#!/usr/bin/env bash
# Check: the fix of dispatch is recorded in kubernetes.io/change-cause.
set -uo pipefail

cause="$(kubectl -n starfleet get deployment dispatch -o jsonpath='{.metadata.annotations.kubernetes\.io/change-cause}' 2>/dev/null || true)"
if [[ "$cause" != *readyz* ]]; then
  echo "FAIL: the annotation kubernetes.io/change-cause on dispatch is '${cause}', it must mention readyz"
  exit 1
fi

echo "PASS: the fix is recorded: ${cause}"
