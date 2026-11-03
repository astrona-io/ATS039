#!/usr/bin/env bash
# Check: The pod wanderer is running without the bad node selector.
set -uo pipefail

phase="$(kubectl -n outpost get pod wanderer -o jsonpath='{.status.phase}' 2>/dev/null || true)"
sel="$(kubectl -n outpost get pod wanderer -o jsonpath='{.spec.nodeSelector}' 2>/dev/null || true)"
if [ "$phase" != "Running" ]; then
  echo "FAIL: wanderer is '${phase}'"
  exit 1
fi
if [ -n "$sel" ]; then
  echo "FAIL: wanderer still has a node selector"
  exit 1
fi
echo "PASS: wanderer is running with no node selector"
