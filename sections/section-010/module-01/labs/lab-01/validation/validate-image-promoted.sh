#!/usr/bin/env bash
# Check: production runs exactly the staging image reference, not latest.
set -uo pipefail

staging="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
production="$(kubectl -n outpost get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ -z "$production" ]; then
  echo "FAIL: no Deployment scout in outpost"
  exit 1
fi
if [ "$production" != "$staging" ]; then
  echo "FAIL: outpost runs '${production}', staging runs '${staging}'"
  exit 1
fi
if [[ "$production" == *:latest ]]; then
  echo "FAIL: the latest tag is not a release identity"
  exit 1
fi

echo "PASS: outpost runs the staging image reference '${production}'"
