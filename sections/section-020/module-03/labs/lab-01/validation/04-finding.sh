#!/usr/bin/env bash
# Check: The Deployment mill records the finding in an annotation.
set -uo pipefail

f="$(kubectl -n outpost get deployment mill -o jsonpath='{.metadata.annotations.debug/finding}' 2>/dev/null || true)"
if [ "$f" != "read-only root filesystem" ]; then
  echo "FAIL: debug/finding is '${f}'"
  exit 1
fi
echo "PASS: finding recorded"
