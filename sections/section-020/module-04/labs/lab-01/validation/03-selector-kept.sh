#!/usr/bin/env bash
# Check: The Deployment labels are unchanged.
set -uo pipefail

lbl="$(kubectl -n outpost get deployment web -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null || true)"
if [ "$lbl" != "web" ]; then
  echo "FAIL: pod label app is '${lbl}'"
  exit 1
fi
echo "PASS: pod label app is web"
