#!/usr/bin/env bash
# Check: The Deployment stray is removed.
set -uo pipefail

if kubectl -n outpost get deployment stray >/dev/null 2>&1; then
  echo "FAIL: Deployment stray still exists"
  exit 1
fi
echo "PASS: stray is pruned"
