#!/usr/bin/env bash
# Check: the Job release-check completed and its log shows HTTP status 200.
set -uo pipefail

succeeded="$(kubectl -n outpost get job release-check -o jsonpath='{.status.succeeded}' 2>/dev/null || true)"
if [ "${succeeded:-0}" -lt 1 ]; then
  echo "FAIL: the Job release-check in outpost has '${succeeded:-0}' succeeded pods. Create it and wait for completion"
  exit 1
fi
image="$(kubectl -n outpost get job release-check -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ "$image" != "curlimages/curl:8.22.0" ]; then
  echo "FAIL: the Job uses image '${image}', expected 'curlimages/curl:8.22.0'"
  exit 1
fi
logs="$(kubectl -n outpost logs job/release-check 2>/dev/null || true)"
if [[ "$logs" != *200* ]]; then
  echo "FAIL: the log of release-check does not show the HTTP status 200"
  exit 1
fi

echo "PASS: release-check completed and logged 200"
