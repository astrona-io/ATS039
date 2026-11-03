#!/usr/bin/env bash
# Check: The repository ConfigMap is not edited.
set -uo pipefail

reps="$(kubectl -n gitops-repo get configmap desired-state -o jsonpath='{.data.relay\.yaml}' 2>/dev/null | grep -c 'replicas: 2' || true)"
rev="$(kubectl -n gitops-repo get configmap desired-state -o jsonpath='{.data.revision}' 2>/dev/null || true)"
if [ "$reps" != "1" ] || [ "$rev" != "9d3e7b2" ]; then
  echo "FAIL: the repository ConfigMap was changed"
  exit 1
fi
echo "PASS: the repository is unchanged"
