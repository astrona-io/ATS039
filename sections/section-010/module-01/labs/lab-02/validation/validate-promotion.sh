#!/usr/bin/env bash
# Check: Production runs the staging image with the copied approval and the promoted-from annotation.
set -uo pipefail

staging="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
production="$(kubectl -n outpost get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ -z "$production" ] || [ "$production" != "$staging" ]; then
  echo "FAIL: outpost runs '${production}', staging runs '${staging}'"
  exit 1
fi
approved="$(kubectl -n outpost get deployment scout -o jsonpath='{.metadata.annotations.release\.astrona\.io/approved-by}' 2>/dev/null || true)"
from="$(kubectl -n outpost get deployment scout -o jsonpath='{.metadata.annotations.release\.astrona\.io/promoted-from}' 2>/dev/null || true)"
if [ "$approved" != "release-manager" ] || [ "$from" != "starfleet" ]; then
  echo "FAIL: annotations are approved-by='${approved}' promoted-from='${from}'"
  exit 1
fi
ready="$(kubectl -n outpost get deployment scout -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${ready:-0}" -lt 1 ]; then
  echo "FAIL: no available replica in outpost"
  exit 1
fi
echo "PASS: outpost runs ${production} with the approval evidence"
