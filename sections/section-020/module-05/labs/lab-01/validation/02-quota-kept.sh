#!/usr/bin/env bash
# Check: The quota still exists and limits pods.
set -uo pipefail

hard="$(kubectl -n outpost get resourcequota small -o jsonpath='{.spec.hard.pods}' 2>/dev/null || true)"
if [ -z "$hard" ]; then
  echo "FAIL: the quota small is missing or has no pod limit"
  exit 1
fi
echo "PASS: quota small limits pods to ${hard}"
