#!/usr/bin/env bash
# Check: mill keeps the read-only root filesystem.
set -uo pipefail

ro="$(kubectl -n outpost get deployment mill -o jsonpath='{.spec.template.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null || true)"
if [ "$ro" != "true" ]; then
  echo "FAIL: readOnlyRootFilesystem is '${ro}'"
  exit 1
fi
echo "PASS: readOnlyRootFilesystem is still true"
