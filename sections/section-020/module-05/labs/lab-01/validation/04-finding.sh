#!/usr/bin/env bash
# Check: The Deployment crew records the finding in an annotation.
set -uo pipefail

f="$(kubectl -n outpost get deployment crew -o jsonpath='{.metadata.annotations.debug/finding}' 2>/dev/null || true)"
if [ "$f" != "exceeded quota" ]; then
  echo "FAIL: debug/finding is '${f}'"
  exit 1
fi
echo "PASS: finding recorded"
