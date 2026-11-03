#!/usr/bin/env bash
# Check: the cutover is recorded on the Service in kubernetes.io/change-cause.
set -uo pipefail

cause="$(kubectl -n starfleet get service scout -o jsonpath='{.metadata.annotations.kubernetes\.io/change-cause}' 2>/dev/null || true)"
if [[ "$cause" != *green* ]]; then
  echo "FAIL: the annotation kubernetes.io/change-cause on the Service scout is '${cause}', it must mention green"
  exit 1
fi

echo "PASS: the cutover is recorded"
