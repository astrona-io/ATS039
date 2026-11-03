#!/usr/bin/env bash
# Check: the release record (source revision and build id) is copied to production.
set -uo pipefail

for key in 'release\.astrona\.io/source-revision' 'release\.astrona\.io/build-id'; do
  staging="$(kubectl -n starfleet get deployment scout -o jsonpath="{.metadata.annotations.${key}}" 2>/dev/null || true)"
  production="$(kubectl -n outpost get deployment scout -o jsonpath="{.metadata.annotations.${key}}" 2>/dev/null || true)"
  if [ -z "$production" ] || [ "$production" != "$staging" ]; then
    echo "FAIL: annotation ${key} is '${production}' in outpost, expected '${staging}'"
    exit 1
  fi
done

echo "PASS: production carries the same source revision and build id as staging"
