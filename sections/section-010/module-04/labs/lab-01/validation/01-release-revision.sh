#!/usr/bin/env bash
# Check: The latest deployed revision of release beacon is 4.
set -uo pipefail

ver="$(kubectl -n outpost get secret -l owner=helm,name=beacon,status=deployed -o jsonpath='{.items[*].metadata.labels.version}' 2>/dev/null || true)"
if [ "$ver" != "4" ]; then
  echo "FAIL: deployed revision is '${ver}', expected 4"
  exit 1
fi
echo "PASS: revision 4 is deployed"
