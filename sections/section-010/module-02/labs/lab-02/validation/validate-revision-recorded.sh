#!/usr/bin/env bash
# Check: The synced revision annotation equals the repository revision.
set -uo pipefail

repo="$(kubectl -n gitops-repo get configmap desired-state -o jsonpath='{.data.revision}' 2>/dev/null || true)"
value="$(kubectl -n outpost get deployment relay -o jsonpath='{.metadata.annotations.gitops\.astrona\.io/synced-revision}' 2>/dev/null || true)"
if [ -z "$repo" ] || [ "$value" != "$repo" ]; then
  echo "FAIL: synced-revision is '${value}', the repository revision is '${repo}'"
  exit 1
fi
echo "PASS: synced-revision is ${value}"
