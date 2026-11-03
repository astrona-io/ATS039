#!/usr/bin/env bash
# Check: harbor runs the corrected image.
set -uo pipefail

image="$(kubectl -n outpost get deployment harbor -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ "$image" != "curlimages/curl:8.22.0" ]; then
  echo "FAIL: harbor image is '${image}'"
  exit 1
fi
available="$(kubectl -n outpost get deployment harbor -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" -lt 1 ]; then
  echo "FAIL: harbor has no available replica"
  exit 1
fi
echo "PASS: harbor runs ${image}"
