#!/usr/bin/env bash
# Check: the reason for the change is recorded on the Deployment.
set -uo pipefail

cause="$(kubectl -n starfleet get deployment lookout -o jsonpath='{.metadata.annotations.kubernetes\.io/change-cause}' 2>/dev/null || true)"
if [[ "$cause" != *readyz* ]]; then
  echo "FAIL: the annotation kubernetes.io/change-cause on lookout is '${cause}', it must mention the new readiness path readyz"
  exit 1
fi

echo "PASS: the change is recorded: ${cause}"
