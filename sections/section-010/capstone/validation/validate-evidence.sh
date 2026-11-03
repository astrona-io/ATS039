#!/usr/bin/env bash
# Check: the release evidence is recorded on the Deployment scout in outpost.
set -uo pipefail

cause="$(kubectl -n outpost get deployment scout -o jsonpath='{.metadata.annotations.kubernetes\.io/change-cause}' 2>/dev/null || true)"
if [[ "$cause" != *canary* ]]; then
  echo "FAIL: the annotation kubernetes.io/change-cause on scout in outpost is '${cause}', it must mention canary"
  exit 1
fi

echo "PASS: the release is recorded: ${cause}"
